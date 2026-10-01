import 'package:flutter/material.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/sizes.dart';

class CustomRoundedImage extends StatelessWidget {
  const CustomRoundedImage(
      {super.key,
      this.width,
      this.height,
      required this.image,
      this.applyImageRadius = true,
      this.border,
      this.backgroundColor = CustomColors.lightestGrey,
      this.fit,
      this.padding,
      this.isNetworkImage = false,
      this.onPressed,
      this.radius = CustomSizes.medium});

  final double? width, height;
  final String image;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius
              ? BorderRadius.circular(radius)
              : BorderRadius.zero,
          child: Image(
            fit: fit,
            image: isNetworkImage
                ? NetworkImage(image)
                : AssetImage(image) as ImageProvider,
          ),
        ),
      ),
    );
  }
}
