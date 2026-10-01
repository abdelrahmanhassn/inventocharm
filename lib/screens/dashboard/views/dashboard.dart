import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/app_bar/custom_app_bar.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/helpers/helper_functions.dart';
import 'package:inventocharm/components/widgets/primary_header.dart';
import 'package:inventocharm/screens/dashboard/dashboard_data.dart';
import 'package:inventocharm/screens/dashboard/widgets/dashboard_item.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<Map<String, String>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardData.fetchData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardData = DashboardData.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool dark = HelperFunctions.isDarkMode(context);
    final screenSize = MediaQuery.sizeOf(context);
    final headerHeight = (screenSize.height * 0.53).clamp(330.0, 500.0);
    return Scaffold(
      backgroundColor: dark ? CustomColors.black : CustomColors.lightestGrey,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              CustomPrimaryHeader(
                height: headerHeight,
                child: Column(
                  children: [
                    CustomAppBar(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Inventocharm',
                            style:
                                Theme.of(context).textTheme.labelMedium!.apply(
                                      color: dark
                                          ? CustomColors.black
                                          : CustomColors.white,
                                    ),
                          ),
                          Text(
                            'Dashboard',
                            style:
                                Theme.of(context).textTheme.titleMedium!.apply(
                                      color: dark
                                          ? CustomColors.black
                                          : CustomColors.white,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<Map<String, String>>(
                      future: _dashboardData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching data');
                        } else {
                          final data = snapshot.data!;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                GridView.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1.6,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _buildDashboardButton(
                                      title: 'Total Products',
                                      icon: FontAwesomeIcons.boxesStacked,
                                      iconColor: CustomColors.darkerGrey,
                                      number: data['totalProducts'] ?? '0',
                                      itemColor: Colors.deepOrange[300]!,
                                      textColor: CustomColors.darkerGrey,
                                    ),
                                    _buildDashboardButton(
                                      title: 'Total Item Cost',
                                      icon: FontAwesomeIcons.fileInvoiceDollar,
                                      iconColor: CustomColors.darkerGrey,
                                      leading: "\$  ",
                                      number: data['totalItemCost'] ?? '0',
                                      itemColor: Colors.deepOrange[300]!,
                                      textColor: CustomColors.darkerGrey,
                                    ),
                                    _buildDashboardButton(
                                      title: 'Total Prices',
                                      icon: FontAwesomeIcons.circleDollarToSlot,
                                      iconColor: CustomColors.darkerGrey,
                                      leading: "\$  ",
                                      number: data['totalPrices'] ?? '0',
                                      itemColor: Colors.greenAccent,
                                      textColor: CustomColors.darkerGrey,
                                    ),
                                    _buildDashboardButton(
                                      title: 'Profit',
                                      icon: FontAwesomeIcons.moneyBillWave,
                                      iconColor: CustomColors.darkerGrey,
                                      leading: "\$  ",
                                      number: data['profit'] ?? '0',
                                      itemColor: Colors.deepOrange[300]!,
                                      textColor: CustomColors.darkerGrey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      },
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

  Widget _buildDashboardButton({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String number,
    required Color itemColor,
    required Color textColor,
    String leading = "",
  }) {
    return DashboardItem(
      title: title,
      icon: icon,
      iconColor: iconColor,
      leading: leading,
      number: number,
      itemColor: itemColor,
      textColor: textColor,
    );
  }
}
