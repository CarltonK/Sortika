import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/depositmethods.dart';
import 'package:wealth/utilities/styles.dart';

class Deposit extends StatefulWidget {
  @override
  _DepositState createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  //Identifiers
  String _phone, _amount, _destination;

  PageController _controller;
  // Identifier
  int _currentPage = 0;

  FocusNode focusAmount = FocusNode();

  //Handle Phone Input
  void _handleSubmittedPhone(String value) {
    _phone = value;
    print('Phone: ' + _phone);
  }

  @override
  void initState() {
    super.initState();

    _controller = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  //Handle Password Input
  void _handleSubmittedAmount(String value) {
    _amount = value;
    print('Amount: ' + _amount);
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

  Widget _depositPhone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Phone',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.greenAccent[700],
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.phone,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(focusAmount);
              },
              textInputAction: TextInputAction.next,
              onSaved: _handleSubmittedPhone,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.phone, color: Colors.white),
                  hintText: '07XXXXXXXX',
                  hintStyle: hintStyle)),
        )
      ],
    );
  }

  Widget _proceedBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: () {},
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.greenAccent[700],
        child: Text(
          'SEND',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
            letterSpacing: 1.5,
            color: Colors.white,
            fontSize: 20,
          )),
        ),
      ),
    );
  }

  Widget _depositAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Amount',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.greenAccent[700],
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.number,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
              focusNode: focusAmount,
              onSaved: _handleSubmittedAmount,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.monetization_on, color: Colors.white),
                  hintText: 'Enter amount',
                  hintStyle: hintStyle)),
        )
      ],
    );
  }

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

  Widget _depositManual() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text('Manual Deposit',
            style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.black),
            )),
        children: [
          Text('Go to your M-PESA menu',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.black),
              )),
          SizedBox(
            height: 5,
          ),
          Text('Enter SORTIKA paybill number XXXXXX',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.black),
              )),
          SizedBox(
            height: 5,
          ),
          Text('Enter XXXX as account number',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.black),
              )),
          SizedBox(
            height: 5,
          ),
          Text('Enter the amount',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.black),
              )),
          SizedBox(
            height: 5,
          ),
          Text('Enter your M-PESA pin',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.black),
              ))
        ],
      ),
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
                                subtitle: Text('Current: 200,000 KES',
                                    style: GoogleFonts.muli(
                                      textStyle: TextStyle(color: Colors.green),
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
                    _depositMethodWidget()
                    // _depositPhone(),
                    // SizedBox(
                    //   height: 30,
                    // ),
                    // _depositAmount(),
                    // _proceedBtn(),
                    // _depositManual()
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
