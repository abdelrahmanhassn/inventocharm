import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/app_bar/custom_app_bar.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/widgets/primary_header.dart';
import 'package:inventocharm/screens/dashboard/widgets/dashboard_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _DashboardState();
}

class _DashboardState extends State<Search> {
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomPrimaryHeader(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomAppBar(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Inventocharm',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .apply(color: CustomColors.white),
                        ),
                        Text(
                          'Dashboard',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .apply(color: CustomColors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  //Cards
                  SizedBox(
                      width: 350,
                      height: 200,
                      child: PageView(
                          scrollDirection: Axis.horizontal,
                          controller: _controller,
                          children: const [
                            DashboardItem(
                              itemColor: CustomColors.white,
                              icon: FontAwesomeIcons.boxesStacked,
                              iconSize: 35,
                              iconColor: CustomColors.primaryColor,
                              title: 'Total Products',
                              number: '275',
                            ),
                            DashboardItem(
                              itemColor: CustomColors.white,
                              icon: FontAwesomeIcons.moneyBills,
                              iconSize: 35,
                              iconColor: CustomColors.primaryColor,
                              title: 'Total Sales',
                              leading: '\$',
                              number: '9,000',
                            ),
                          ])),
                  const SizedBox(height: 20),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 2,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Colors.blue[900]!,
                      dotColor: CustomColors.grey,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
