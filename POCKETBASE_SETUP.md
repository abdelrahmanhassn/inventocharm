# PocketBase setup

Start PocketBase on an address reachable by the device running Flutter:

```text
pocketbase serve --http=0.0.0.0:8090
```

Run the app with:

```text
flutter run --dart-define=POCKETBASE_URL=http://192.168.1.21:8090
```

Use `http://127.0.0.1:8090` for desktop when PocketBase runs locally. Use `http://10.0.2.2:8090` for an Android emulator. A physical phone must use the computer's LAN address and both devices must be on the same network.

Create these collections in the PocketBase admin dashboard:

- `users`: built-in Auth collection with `email`, `password`, `passwordConfirm`, and `name`.
- `items`: `name`, `price`, `quantity`, `image` file, `description`, `cost`, and `code`.
- `sales`: `date`, `customerName`, `phoneNumber`, `total`, and `items` JSON.

Allow authenticated users to list, view, create, update, and delete `items` and `sales`. Allow authenticated users to view and update their own `users` record.