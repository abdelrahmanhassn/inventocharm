import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.showIconButton = false,
    this.leadingIcon,
    this.leadingOnPressed,
    this.leadingColor = Colors.white,
  });

  final Widget? title;
  final bool showIconButton;
  final List<Widget>? actions;
  final IconData? leadingIcon;
  final VoidCallback? leadingOnPressed;
  final Color? leadingColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppBar(
        forceMaterialTransparency: true,
        title: title,
        actions: actions,
        automaticallyImplyLeading: false,
        leading: showIconButton
            ? leadingIcon != null
                ? IconButton(
                    onPressed: leadingOnPressed,
                    icon: Icon(
                      leadingIcon,
                      color: leadingColor,
                    ),
                  )
                : null
            : null,
      ),
    );
  }
}
