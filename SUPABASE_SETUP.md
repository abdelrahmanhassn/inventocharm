# Supabase setup

Create a Supabase project, then run the SQL below in the project's SQL Editor.
It creates the profile, inventory, and sales tables; row-level security; the
public item-image bucket; and the transaction used to record a sale.

```sql
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null default '',
  name text not null default '',
  created_at timestamptz not null default now()
);

create table public.items (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  price numeric not null,
  quantity integer not null default 0 check (quantity >= 0),
  image text,
  description text not null default '',
  cost numeric not null default 0,
  code text,
  created_at timestamptz not null default now()
);

create unique index if not exists items_owner_code_unique
  on public.items (owner_id, code)
  where code is not null and btrim(code) <> '';

create table public.sales (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  date timestamptz not null default now(),
  "customerName" text not null,
  "phoneNumber" text not null,
  total numeric not null,
  items jsonb not null default '[]'::jsonb
);

alter table public.profiles enable row level security;
alter table public.items enable row level security;
alter table public.sales enable row level security;

create policy "Read own profile" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);
create policy "Update own profile" on public.profiles
  for update to authenticated using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "Manage own inventory" on public.items
  for all to authenticated using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);
create policy "Manage own sales" on public.sales
  for all to authenticated using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create or replace function public.sync_profile_from_auth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.profiles (id, email, name)
    values (
      new.id,
      coalesce(new.email, ''),
      coalesce(new.raw_user_meta_data ->> 'name', '')
    );
  else
    update public.profiles
    set email = coalesce(new.email, ''),
        name = coalesce(new.raw_user_meta_data ->> 'name', public.profiles.name)
    where id = new.id;
  end if;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.sync_profile_from_auth();
create trigger on_auth_user_updated
  after update on auth.users
  for each row execute function public.sync_profile_from_auth();

insert into storage.buckets (id, name, public)
values ('item-images', 'item-images', true)
on conflict (id) do update set public = excluded.public;

create policy "Public item images are readable" on storage.objects
  for select to public using (bucket_id = 'item-images');
create policy "Upload images to own folder" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'item-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
create policy "Manage images in own folder" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'item-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'item-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
create policy "Delete images in own folder" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'item-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create or replace function public.record_sale(
  p_customer_name text,
  p_phone_number text,
  p_items jsonb
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_requested jsonb;
  v_item public.items%rowtype;
  v_quantity integer;
  v_total numeric := 0;
  v_sale_items jsonb := '[]'::jsonb;
  v_sale_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required to record a sale.';
  end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'A sale must contain at least one item.';
  end if;

  for v_requested in select value from jsonb_array_elements(p_items)
  loop
    select * into v_item
    from public.items
    where id = (v_requested ->> 'id')::uuid
      and owner_id = auth.uid()
    for update;

    if not found then
      raise exception 'An item in this sale was not found.';
    end if;

    v_quantity := (v_requested ->> 'quantity')::integer;
    if v_quantity <= 0 or v_item.quantity < v_quantity then
      raise exception 'Sale quantity exceeds available inventory for %.', v_item.name;
    end if;

    update public.items
    set quantity = quantity - v_quantity
    where id = v_item.id;

    v_total := v_total + v_item.price * v_quantity;
    v_sale_items := v_sale_items || jsonb_build_array(jsonb_build_object(
      'itemName', v_item.name,
      'quantity', v_quantity::text,
      'price', v_item.price::text,
      'cost', v_item.cost::text
    ));
  end loop;

  insert into public.sales (
    owner_id, "customerName", "phoneNumber", total, items
  ) values (
    auth.uid(), p_customer_name, p_phone_number, v_total, v_sale_items
  ) returning id into v_sale_id;

  return v_sale_id;
end;
$$;

revoke all on function public.record_sale(text, text, jsonb) from public;
grant execute on function public.record_sale(text, text, jsonb) to authenticated;
```

For an existing Supabase project, run the updated `public.record_sale` function
definition and its `grant execute` statement above. New sales will then include
the item's unit cost snapshot. Older sales do not contain that historical cost,
so the dashboard reports realized sales profit as unavailable while those
records remain rather than estimating it from current item costs.

Run the app with the project's URL and publishable/anon key (never use the
service-role key in a client app):

```text
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

Email-confirmation behavior follows the project's Auth settings. Existing
backend records and image files are not copied by this setup; export/import them
into the matching Supabase tables and the `item-images` bucket if they need to
be retained.