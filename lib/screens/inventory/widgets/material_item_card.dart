import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/models/item.dart';
import 'package:inventocharm/screens/inventory/views/details_screen.dart';

class MaterialItemCard extends StatelessWidget {
  const MaterialItemCard({
    super.key,
    required this.item,
    required this.onSalePressed,
    this.clickable = true,
    this.showPlusButton = true,
    this.onItemChanged,
  });

  final Item item;
  final VoidCallback onSalePressed;
  final bool showPlusButton;
  final bool clickable;
  final Future<void> Function()? onItemChanged;

  static const _placeholderImage =
      'https://static.vecteezy.com/system/resources/previews/005/337/799/non_2x/icon-image-not-found-free-vector.jpg';

  static double itemNameLineHeight(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium;
    final painter = TextPainter(
      text: TextSpan(text: 'Ag', style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return painter.preferredLineHeight;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        (item.image?.isNotEmpty ?? false) ? item.image! : _placeholderImage;
    final quantity = item.quantity;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xfff1f3f8) : theme.colorScheme.surface;
    final nameStyle = theme.textTheme.titleMedium?.copyWith(
      color: CustomColors.textPrimary,
    );

    return Material(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark
              ? const Color(0xffdce1eb)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: clickable ? () => _openDetails(context) : null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight =
                ((constraints.maxWidth - 16) * 0.56).clamp(84.0, 132.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                  child: Container(
                    height: imageHeight.toDouble(),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 1, 12, 0),
                  child: SizedBox(
                    height: itemNameLineHeight(context) * 2,
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: nameStyle,
                    ),
                  ),
                ),
                _buildStockRow(context, quantity, constraints.maxWidth),
                _buildPriceRow(context, quantity),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockRow(
    BuildContext context,
    int quantity,
    double cardWidth,
  ) {
    final inStock = quantity > 0;
    final lowStock = quantity > 0 && quantity <= 10;
    final badgeColor = !inStock
        ? CustomColors.error
        : lowStock
            ? CustomColors.warning
            : CustomColors.success;
    final badgeWidth = (cardWidth * 0.34).clamp(40.0, 88.0).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
      child: Row(
        children: [
          Icon(
            inStock ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
            color: badgeColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Container(
            alignment: Alignment.center,
            height: 30,
            width: badgeWidth,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$quantity',
                maxLines: 1,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              !inStock ? 'Out of Stock' : (lowStock ? 'Low Stock' : 'In Stock'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CustomColors.textSecondary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, int quantity) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 2),
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                '\$${item.price.toStringAsFixed(2)}',
                maxLines: 1,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CustomColors.primaryColor,
                    ),
              ),
            ),
          ),
        ),
        if (showPlusButton && quantity > 0)
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Add item to sale',
            onPressed: onSalePressed,
            icon: const Icon(
              FontAwesomeIcons.circlePlus,
              color: CustomColors.success,
            ),
          ),
      ],
    );
  }

  Future<void> _openDetails(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetailsScreen(
          data: {
            'id': item.id,
            ...item.toJson(),
          },
          onItemChanged: onItemChanged,
        ),
      ),
    );
  }
}
