import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedPage;
  List<TabData> _tabs = [
    TabData(iconData: Icons.save, title: 'Savings'),
    TabData(iconData: Icons.redeem, title: 'Redeemables'),
    TabData(iconData: Icons.account_balance, title: 'Investments')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FancyBottomNavigation(
        tabs: _tabs,
        activeIconColor: Colors.white,
        circleColor: Colors.blue,
        inactiveIconColor: Colors.blue[200],
        onTabChangedListener: (position) {
          _selectedPage = position;
        },
      ),
    );
  }
}
