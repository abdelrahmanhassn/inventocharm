import 'package:flutter/material.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/widgets/circular_widget.dart';
import 'package:inventocharm/components/widgets/curved_edges.dart';

class CustomPrimaryHeader extends StatelessWidget {
  const CustomPrimaryHeader({
    super.key,
    this.child,
    this.height = 400,
  });

  final Widget? child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomCurvedEdges(),
      child: Container(
        color: CustomColors.primaryColor,
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned(
                top: -150,
                right: -250,
                child: CustomCircularContainer(
                  backgroundColor: CustomColors.textWhite.withOpacity(0.1),
                ),
              ),
              Positioned(
                top: 100,
                right: -300,
                child: CustomCircularContainer(
                  backgroundColor: CustomColors.textWhite.withOpacity(0.1),
                ),
              ),
              Container(
                child: child,
              ) // Ensure child widget is added here
            ],
          ),
        ),
      ),
    );
  }
}
