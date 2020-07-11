import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/admin/adminBooking.dart';
import 'package:wealth/admin/adminLottery.dart';
import 'package:wealth/api/auth.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  PageController _controller;
  int _selectedPage = 0;
  List<TabData> _tabs = [
    TabData(iconData: Icons.games, title: 'Lottery'),
    TabData(iconData: Icons.redeem, title: 'Bookings'),
  ];

  List<Widget> _pages = [
    LotteryView(),
    AdminBooking(),
  ];

  AuthService service = new AuthService();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            tooltip: 'Exit',
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Text(
                        'Are you sure',
                        style: GoogleFonts.muli(textStyle: TextStyle()),
                      ),
                      actions: [
                        FlatButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await service.logout();
                              Navigator.of(context).popAndPushNamed('/login');
                            },
                            child: Text(
                              'YES',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold)),
                            )),
                        FlatButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'NO',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ))
                      ],
                    );
                  });
            },
          )
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          index = _selectedPage;
          return _pages[index];
        },
      ),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: _tabs,
        activeIconColor: Colors.white,
        circleColor: Colors.blue,
        inactiveIconColor: Colors.blue[200],
        onTabChangedListener: (position) {
          setState(() {
            _selectedPage = position;
            _controller.animateToPage(_selectedPage,
                duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
          });
        },
      ),
    );
  }
}
