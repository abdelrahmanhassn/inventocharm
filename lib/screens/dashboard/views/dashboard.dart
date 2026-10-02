import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/app_bar/custom_app_bar.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/helpers/helper_functions.dart';
import 'package:inventocharm/components/widgets/primary_header.dart';
import 'package:inventocharm/screens/dashboard/dashboard_data.dart';
import 'package:inventocharm/screens/dashboard/widgets/dashboard_item.dart';
import 'package:inventocharm/screens/inventory/services/inventory_change_notifier.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  late Future<Map<String, String>> _dashboardData;
  late final StreamSubscription<void> _inventoryChangesSubscription;
  int _dashboardRequestId = 0;

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardData.fetchData();
    _inventoryChangesSubscription =
        InventoryChangeNotifier.changes.listen((_) => refresh());
  }

  @override
  void dispose() {
    _inventoryChangesSubscription.cancel();
    super.dispose();
  }

  Future<void> refresh() => _refreshData();

  Future<void> _refreshData() async {
    if (!mounted) return;
    final refresh = DashboardData.fetchData();
    setState(() {
      _dashboardData = refresh;
      _dashboardRequestId++;
    });
    try {
      await refresh;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Could not refresh dashboard: $error')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: dark ? CustomColors.black : CustomColors.lightestGrey,
      body: RefreshIndicator(
        color: CustomColors.primaryColor,
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: CustomPrimaryHeader(
                height: 150,
                child: Column(
                  children: [
                    CustomAppBar(
                      actions: [
                        IconButton(
                          tooltip: 'Refresh dashboard',
                          onPressed: _refreshData,
                          icon: const Icon(
                            Icons.refresh,
                            color: CustomColors.white,
                          ),
                        ),
                      ],
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Inventocharm',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: CustomColors.white,
                            ),
                          ),
                          Text(
                            'Dashboard',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: CustomColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Inventory overview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: CustomColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<Map<String, String>>(
                key: ValueKey(_dashboardRequestId),
                future: _dashboardData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Could not load dashboard: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: _refreshData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width < 350 ? 1 : 2;
                      final textScale = MediaQuery.textScalerOf(context)
                          .scale(1)
                          .clamp(1.0, 1.8);
                      final values = [
                        data['totalProducts'] ?? '0',
                        data['totalItemCost'] ?? '0',
                        data['totalPrices'] ?? '0',
                        data['profit'] ?? '0',
                        data['completedSales'] ?? '0',
                        data['salesRevenue'] ?? '0',
                        data['salesProfit'] ?? 'N/A',
                      ];
                      const currencyFlags = [
                        false,
                        true,
                        true,
                        true,
                        false,
                        true,
                        true,
                      ];
                      final gridWidth =
                          (width.clamp(0.0, 900.0) - 32).clamp(0.0, 900.0);
                      final cardWidth =
                          columns == 1 ? gridWidth : (gridWidth - 12) / columns;
                      final numberWidth = (cardWidth - 28).clamp(0.0, 900.0);
                      final baseNumberStyle = theme.textTheme.headlineSmall;
                      var widestNumber = 0.0;
                      for (var index = 0; index < values.length; index++) {
                        if (double.tryParse(values[index]) == null) continue;
                        final painter = TextPainter(
                          text: TextSpan(
                            text: DashboardItem.formatNumber(
                              values[index],
                              isCurrency: currencyFlags[index],
                            ),
                            style: baseNumberStyle,
                          ),
                          textDirection: Directionality.of(context),
                          textScaler: MediaQuery.textScalerOf(context),
                        )..layout();
                        if (painter.width > widestNumber) {
                          widestNumber = painter.width;
                        }
                      }
                      final baseFontSize = baseNumberStyle?.fontSize ?? 18.0;
                      final valueFontSize =
                          widestNumber <= numberWidth || widestNumber == 0
                              ? baseFontSize
                              : baseFontSize * numberWidth / widestNumber;

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _sectionTitle(context, 'Current inventory'),
                                const SizedBox(height: 4),
                                const SizedBox(height: 10),
                                _metricGrid(
                                  columns: columns,
                                  textScale: textScale,
                                  metrics: [
                                    _buildDashboardButton(
                                      title: 'Product Types',
                                      icon: FontAwesomeIcons.boxesStacked,
                                      number: values[0],
                                      itemColor: const Color(0xffffede5),
                                      valueColor: const Color(0xffa84212),
                                      valueFontSize: valueFontSize,
                                    ),
                                    _buildDashboardButton(
                                      title: 'Stock Cost',
                                      icon: FontAwesomeIcons.fileInvoiceDollar,
                                      number: values[1],
                                      isCurrency: true,
                                      itemColor: const Color(0xffffede5),
                                      valueColor: const Color(0xffa84212),
                                      valueFontSize: valueFontSize,
                                    ),
                                    _buildDashboardButton(
                                      title: 'Stock Selling Value',
                                      icon: FontAwesomeIcons.circleDollarToSlot,
                                      number: values[2],
                                      isCurrency: true,
                                      itemColor: const Color(0xffe3f5ec),
                                      valueColor: const Color(0xff187647),
                                      valueFontSize: valueFontSize,
                                    ),
                                    _buildDashboardButton(
                                      title: 'Potential Stock Profit',
                                      icon: FontAwesomeIcons.moneyBillWave,
                                      number: values[3],
                                      isCurrency: true,
                                      itemColor: const Color(0xffe9edff),
                                      valueColor: CustomColors.primaryColor,
                                      valueFontSize: valueFontSize,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _sectionTitle(context, 'Completed sales'),
                                const SizedBox(height: 10),
                                _metricGrid(
                                  columns: columns,
                                  textScale: textScale,
                                  metrics: [
                                    _buildDashboardButton(
                                      title: 'Sales Count',
                                      icon: FontAwesomeIcons.receipt,
                                      number: values[4],
                                      itemColor: const Color(0xffe9edff),
                                      valueColor: CustomColors.primaryColor,
                                      valueFontSize: valueFontSize,
                                    ),
                                    _buildDashboardButton(
                                      title: 'Sales Revenue',
                                      icon: FontAwesomeIcons.circleDollarToSlot,
                                      number: values[5],
                                      isCurrency: true,
                                      itemColor: const Color(0xffe3f5ec),
                                      valueColor: const Color(0xff187647),
                                      valueFontSize: valueFontSize,
                                    ),
                                    _buildDashboardButton(
                                      title: 'Realized Sales Profit',
                                      icon: FontAwesomeIcons.moneyBillWave,
                                      number: values[6],
                                      isCurrency: true,
                                      itemColor: const Color(0xffffede5),
                                      valueColor: const Color(0xffa84212),
                                      valueFontSize: valueFontSize,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton({
    required String title,
    required IconData icon,
    required String number,
    required Color itemColor,
    required Color valueColor,
    required double valueFontSize,
    bool isCurrency = false,
  }) {
    return DashboardItem(
      title: title,
      icon: icon,
      number: number,
      itemColor: itemColor,
      valueColor: valueColor,
      valueFontSize: valueFontSize,
      isCurrency: isCurrency,
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _metricGrid({
    required int columns,
    required double textScale,
    required List<Widget> metrics,
  }) {
    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: (columns == 1 ? 3.0 : 1.65) / textScale,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: metrics,
    );
  }
}
