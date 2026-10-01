import 'package:flutter/material.dart';
import 'package:inventocharm/components/constants/colors.dart';

class DashboardItem extends StatelessWidget {
  const DashboardItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.number,
    this.leading = '',
    this.textColor = CustomColors.white,
    this.iconColor = CustomColors.white,
    this.itemColor = CustomColors.darkGrey,
    this.iconSize = 24,
    this.onTap,
    this.radius = 18,
  }) : super(key: key);

  final double iconSize;
  final String title, number, leading;
  final IconData icon;
  final Color textColor;
  final Color itemColor;
  final Color? iconColor;
  final void Function()? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: itemColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: CustomColors.black.withOpacity(0.5),
              offset: const Offset(3, 3),
              blurRadius: 5,
            ),
            BoxShadow(
              color: CustomColors.black.withOpacity(0.5),
              offset: const Offset(-3, -3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      title,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            leading,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            number,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
