import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/screens/dashboard/views/dashboard.dart';
import 'package:inventocharm/screens/inventory/views/inventory.dart';
import 'package:inventocharm/screens/sales/views/sales.dart';
import 'package:inventocharm/screens/settings/views/settings.dart';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'constants/colors.dart';

class PersistentTabScreen extends StatefulWidget {
  const PersistentTabScreen({super.key});

  @override
  State<PersistentTabScreen> createState() => _PersistentTabScreenState();
}

class _PersistentTabScreenState extends State<PersistentTabScreen> {
  late PersistentTabController _controller;
  final _dashboardKey = GlobalKey<DashboardState>();

  List<Widget> _buildScreens() {
    return [
      Dashboard(key: _dashboardKey),
      const Inventory(),
      const SalesHistory(),
      const Settings()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.chartPie),
        title: ("Dashboard"),
        activeColorPrimary: CustomColors.primaryColor,
        inactiveColorPrimary: CustomColors.darkGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.boxesStacked),
        title: ('Inventory'),
        activeColorPrimary: CustomColors.primaryColor,
        inactiveColorPrimary: CustomColors.darkGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.clockRotateLeft),
        title: ("History"),
        activeColorPrimary: CustomColors.primaryColor,
        inactiveColorPrimary: CustomColors.darkGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.gear),
        title: ("Settings"),
        activeColorPrimary: CustomColors.primaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  void initState() {
    _controller = PersistentTabController(initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      onItemSelected: (index) {
        if (index == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _dashboardKey.currentState?.refresh();
          });
        }
      },
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardAppears:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
      ),
      navBarStyle:
          NavBarStyle.style1, // Choose the nav bar style with this property.
    );
  }
}
