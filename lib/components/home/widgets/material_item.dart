import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/screens/inventory/views/details_screen.dart';

class MaterialItemCard extends StatelessWidget {
  const MaterialItemCard({
    Key? key,
    required this.data,
    required this.onSalePressed,
  }) : super(key: key);

  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onSalePressed; // Updated callback type

  @override
  Widget build(BuildContext context) {
    String imageUrl = data['image'] ??
        'https://static.vecteezy.com/system/resources/previews/005/337/799/non_2x/icon-image-not-found-free-vector.jpg';
    int quantity = int.parse(data['quantity'] ?? '0');

    return Material(
      elevation: 3,
      color: CustomColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => DetailsScreen(data: data),
            ),
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 150,
                child: Image.network(imageUrl),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                data['name'],
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .apply(fontWeightDelta: 3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.check,
                    color: CustomColors.success,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 50,
                    decoration: BoxDecoration(
                      color: quantity > 0
                          ? CustomColors.primaryColor.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$quantity',
                      style: Theme.of(context).textTheme.labelLarge!,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    quantity > 0 ? 'In Stock' : 'Out of Stock',
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                          fontSizeFactor: 1.3,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Text(
                  '\$${data['price']}',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    onSalePressed(data); // Pass the item data to the callback
                  },
                  icon: Icon(
                    FontAwesomeIcons.circlePlus,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
