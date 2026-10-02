import 'package:flutter/material.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:intl/intl.dart';

class DashboardItem extends StatelessWidget {
  const DashboardItem({
    super.key,
    required this.title,
    required this.icon,
    required this.number,
    required this.itemColor,
    required this.valueColor,
    required this.valueFontSize,
    this.isCurrency = false,
  });

  final String title;
  final String number;
  final IconData icon;
  final Color itemColor;
  final Color valueColor;
  final double valueFontSize;
  final bool isCurrency;

  static String formatNumber(String number, {required bool isCurrency}) {
    final value = double.tryParse(number);
    if (value == null) return number;
    if (isCurrency) {
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
        decimalDigits: 2,
      ).format(value);
    }
    return NumberFormat.decimalPattern('en_US').format(value);
  }

  String get _formattedNumber {
    return formatNumber(number, isCurrency: isCurrency);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: itemColor,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: valueColor.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: valueColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      softWrap: false,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: CustomColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formattedNumber,
                    maxLines: 1,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: valueFontSize,
                      color: valueColor,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
