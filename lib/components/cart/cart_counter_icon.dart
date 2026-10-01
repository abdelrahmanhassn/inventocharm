import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/constants/colors.dart';

class CustomCounterIcon extends StatelessWidget {
  const CustomCounterIcon({
    super.key,
    required this.iconColor,
    required this.onPressed,
  });

  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      IconButton(
        onPressed: onPressed,
        icon: Icon(
          FontAwesomeIcons.cartShopping,
          color: iconColor,
        ),
        iconSize: 20,
      ),
      Positioned(
        right: 0,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: CustomColors.black,
            borderRadius: BorderRadius.circular(100),
          ),
          // TODO: Add number of items in cart
          child: Center(
            child: Text(
              '2',
              style: Theme.of(context).textTheme.labelSmall!.apply(
                    color: CustomColors.white,
                  ),
            ),
          ),
        ),
      )
    ]);
  }
}
