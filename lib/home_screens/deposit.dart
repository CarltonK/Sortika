import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/deposit/bankcard.dart';
import 'package:wealth/deposit/mpesaAuto.dart';
import 'package:wealth/deposit/mpesaManual.dart';
import 'package:wealth/models/depositmethods.dart';
import 'package:wealth/utilities/styles.dart';

class Deposit extends StatefulWidget {
  @override
  _DepositState createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  PageController _controller;
  PageController _controllerPages;

  // Identifiers
  int _currentPage = 0;
  String _destination;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
    _controllerPages = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _controllerPages.dispose();
  }

  //Define Dropdown Menu Items
  List<DropdownMenuItem> destinations = [
    //Send Money to Wallet
    DropdownMenuItem(
      value: 'wallet',
      child: Text(
        'Wallet',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),

    //General topup
    DropdownMenuItem(
      value: 'general',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'General',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
          ),
          Text('Divide between goals based on allocation',
              style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 10),
              )),
        ],
      ),
    ),

    //Send to a specific goal
    DropdownMenuItem(
      value: 'specific',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Specific',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
          ),
          Text(
            'Deposit to a specific goal',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 10)),
          ),
        ],
      ),
    ),
  ];

  Widget _depositInfo() {
    return Container(
      child: RichText(
          text: TextSpan(children: [
        TextSpan(
            text:
                'Based on your savings target, we recommend that you deposit ',
            style: GoogleFonts.muli(textStyle: TextStyle(color: Colors.white))),
        TextSpan(
            text: '100 KES',
            style: GoogleFonts.muli(
                textStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      ])),
    );
  }

  Widget _depositDestination() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: destinations,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: _destination,
        hint: Text(
          '',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
        ),
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _destination = value;

            if (value == 'wallet') {}
            if (value == 'general') {}
            if (value == 'specific') {
              //Show a list of all goals
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ListView(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              color: Colors.grey[200],
                              child: ListTile(
                                title: Text('Buy a house',
                                    style: GoogleFonts.muli(
                                      textStyle: TextStyle(color: Colors.black),
                                    )),
                                subtitle: Text('Current: 20,000 KES',
                                    style: GoogleFonts.muli(
                                      textStyle: TextStyle(color: Colors.black),
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }
          });
        },
      ),
    );
  }

  Widget _depositMethodWidget() {
    return Container(
      height: 80,
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        onPageChanged: (value) {
          setState(() {
            _currentPage = value;
            _controllerPages.animateToPage(value,
                duration: Duration(milliseconds: 100), curve: Curves.ease);
          });
        },
        children: methods
            .map((map) => _depositMethod(map.title, map.subtitle))
            .toList(),
      ),
    );
  }

  //Budget Item
  Widget _depositMethod(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: Colors.white),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              child: Icon(
                MaterialCommunityIcons.cash_multiple,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Color(0xFF73AEF5))),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$title',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '$subtitle',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }

  //List of pages
  List<Widget> _pages = [MpesaAuto(), MpesaManual(), MpesaAuto(), BankCard()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text(
          'Deposit',
          style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            backgroundWidget(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _depositInfo(),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Where do you want to deposit?',
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    _depositDestination(),
                    SizedBox(
                      height: 20,
                    ),
                    Text('How do you want to deposit?',
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    _depositMethodWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    LimitedBox(
                      maxHeight: double.maxFinite,
                      child: PageView(
                          controller: _controllerPages,
                          physics: NeverScrollableScrollPhysics(),
                          onPageChanged: (value) {},
                          children: _pages),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
