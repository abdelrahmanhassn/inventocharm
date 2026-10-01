import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/screens/inventory/views/details_screen.dart';

class MaterialItemCard extends StatelessWidget {
  const MaterialItemCard({
    Key? key,
    required this.data,
    required this.onSalePressed,
    this.clickable = true,
    this.showPlusButton = true,
  }) : super(key: key);

  final Map<String, dynamic> data;
  final VoidCallback onSalePressed;
  final bool showPlusButton;
  final bool clickable;

  @override
  Widget build(BuildContext context) {
    String imageUrl = data['image'] ??
        'https://static.vecteezy.com/system/resources/previews/005/337/799/non_2x/icon-image-not-found-free-vector.jpg';

    int quantity = 0;
    try {
      quantity = int.parse(data['quantity'] ?? '0');
    } catch (e) {
      print('Error parsing quantity: $e');
    }

    return Material(
      elevation: 3,
      color: CustomColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: clickable
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        DetailsScreen(data: data),
                  ),
                );
              }
            : () {},
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = (constraints.maxWidth * 0.6).clamp(72.0, 140.0);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: imageHeight,
                    child: Image.network(imageUrl, fit: BoxFit.contain),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: Text(
                    data['name']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .apply(fontWeightDelta: 2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        quantity > 0
                            ? FontAwesomeIcons.check
                            : FontAwesomeIcons.xmark,
                        color: quantity > 0
                            ? CustomColors.success
                            : CustomColors.error,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Visibility(
                        visible: quantity > 0,
                        child: Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: 50,
                          decoration: BoxDecoration(
                            color: quantity > 10
                                ? CustomColors.primaryColor.withOpacity(0.5)
                                : Colors.red.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$quantity',
                            style: Theme.of(context).textTheme.labelLarge!,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          quantity > 0
                              ? (quantity <= 10 ? 'Low Stock' : 'In Stock')
                              : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: CustomColors.black.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        '\$${data['price'] ?? '0'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (showPlusButton && quantity > 0)
                      IconButton(
                        onPressed: onSalePressed,
                        icon: const Icon(
                          FontAwesomeIcons.circlePlus,
                          color: CustomColors.success,
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
