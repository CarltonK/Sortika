import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/deposit/bankcard.dart';
import 'package:wealth/deposit/mpesaAuto.dart';
import 'package:wealth/deposit/mpesaManual.dart';
import 'package:wealth/models/depositmethods.dart';
import 'package:wealth/utilities/styles.dart';

class PayLoan extends StatefulWidget {
  @override
  _PayLoanState createState() => _PayLoanState();
}

class _PayLoanState extends State<PayLoan> {
  Map<String, dynamic> loanData;

  Widget _balanceText() {
    double totalAmount = loanData["totalAmountToPay"];

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Your loan balance is  ',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.white))),
            TextSpan(
                text: '${totalAmount.toInt().toString()}',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    decoration: TextDecoration.underline)),
          ])),
        ],
      ),
    );
  }

  Widget _payMethodWidget() {
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
        children:
            methods.map((map) => _payMethod(map.title, map.subtitle)).toList(),
      ),
    );
  }

  //Budget Item
  Widget _payMethod(String title, String subtitle) {
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

  PageController _controller;
  PageController _controllerPages;

  // Identifiers
  int _currentPage = 0;

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

  //List of pages
  List<Widget> _pages = [MpesaAuto(), MpesaManual(), MpesaAuto(), BankCard()];

  @override
  Widget build(BuildContext context) {
    //Retrieve Loan Data
    loanData = ModalRoute.of(context).settings.arguments;
    print('Retrieved Loan Data: $loanData');

    return Scaffold(
        appBar: AppBar(
          backgroundColor: commonColor,
          elevation: 0,
          title: Text('Loan Payment',
              style: GoogleFonts.muli(textStyle: TextStyle())),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  child: backgroundWidget(),
                  onTap: () => FocusScope.of(context).unfocus(),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _balanceText(),
                        SizedBox(
                          height: 20,
                        ),
                        Text('How do you want to pay?',
                            style: GoogleFonts.muli(
                                textStyle: TextStyle(color: Colors.white))),
                        SizedBox(
                          height: 10,
                        ),
                        _payMethodWidget(),
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
                ),
              ],
            ),
            value: SystemUiOverlayStyle.light));
  }
}
