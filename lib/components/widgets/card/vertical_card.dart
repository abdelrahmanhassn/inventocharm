// Import necessary packages and components
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/helpers/helper_functions.dart';
import 'package:inventocharm/components/constants/sizes.dart';
import 'package:inventocharm/components/text_widgets/product_title_text.dart';
import 'package:inventocharm/components/theme/shadows/product_shadow_style.dart';
import 'package:inventocharm/components/widgets/card/circular_icon.dart';
import 'package:inventocharm/components/widgets/card/rounded_container.dart';
import 'package:inventocharm/components/widgets/card/rounded_image.dart';
import 'package:inventocharm/screens/inventory/views/details_screen.dart';

// Define a custom vertical card widget
class CustomVerticalCard extends StatelessWidget {
  const CustomVerticalCard({Key? key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = HelperFunctions.isDarkMode(context);
    final double cardWidth = MediaQuery.of(context).size.width * 0.4;

    return Material(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          /*Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const DetailsScreen(),
            ),
          );*/
        },
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            boxShadow: [CustomShadowStyle.verticalProductShadow],
            borderRadius: BorderRadius.circular(CustomSizes.productImageRadius),
            color: isDarkMode ? CustomColors.darkerGrey : CustomColors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.2, // Set a fixed height for the image container
                child: CustomRoundedContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.all(CustomSizes.small),
                  backgroundColor:
                      isDarkMode ? CustomColors.darkerGrey : CustomColors.white,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: const CustomRoundedImage(
                          image: 'assets/images/jeansShoe.jpg',
                          applyImageRadius: true,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Positioned(
                        top: 0,
                        right: 0,
                        child: CustomCircularIcon(
                          icon: FontAwesomeIcons.solidHeart,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: CustomSizes.spaceBetweenItems),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: CustomSizes.small),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomProductTitle(
                      title: "Jeans Kid Shoes",
                      smallSize: true,
                    ),
                    const SizedBox(height: CustomSizes.spaceBetweenItems / 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Brand",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        '\$ 50.00',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: CustomColors.black,
                      borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(CustomSizes.borderRadiusMedium),
                        bottomRight:
                            Radius.circular(CustomSizes.productImageRadius),
                      ),
                    ),
                    child: const SizedBox(
                      width: CustomSizes.iconLarge * 1.2,
                      height: CustomSizes.iconLarge * 1.2,
                      child: Center(
                        child: Icon(
                          FontAwesomeIcons.plus,
                          color: CustomColors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
