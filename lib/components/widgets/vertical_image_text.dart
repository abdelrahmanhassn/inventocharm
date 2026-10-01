import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/helpers/helper_functions.dart';

class VerticalImageText extends StatelessWidget {
  const VerticalImageText({
    Key? key, // Corrected super keyword to Key?
    required this.icon,
    required this.title,
    this.textColor = CustomColors.white,
    this.iconColor,
    this.onTap,
    this.radius = 100,
    this.width = 56,
    this.height = 56,
  }) : super(key: key); // Added super constructor call with key parameter

  final double width, height;
  final String title;
  final IconData icon;
  final Color textColor;
  final Color? iconColor;
  final void Function()? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(children: [
          Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor ??
                  (dark
                      ? CustomColors.black
                      : CustomColors.white), // Corrected syntax
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor ??
                    (dark ? CustomColors.white : CustomColors.black),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 55,
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .apply(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      ),
    );
  }
}
