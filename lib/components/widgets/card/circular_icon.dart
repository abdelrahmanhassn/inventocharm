import 'package:flutter/material.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/helpers/helper_functions.dart';
import 'package:inventocharm/components/constants/sizes.dart';

class CustomCircularIcon extends StatelessWidget {
  const CustomCircularIcon(
      {super.key,
      this.width,
      this.height,
      this.size = CustomSizes.large,
      required this.icon,
      this.color,
      this.backgroundColor,
      this.onPressed});

  final double? width, height, size;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor != null
            ? backgroundColor!
            : HelperFunctions.isDarkMode(context)
                ? CustomColors.black.withOpacity(0.4)
                : CustomColors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(100),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }
}
