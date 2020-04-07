import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class Deposit extends StatefulWidget {
  @override
  _DepositState createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  //Identifiers
  String _phone, _amount;

  FocusNode focusAmount = FocusNode();

  //Handle Phone Input
  void _handleSubmittedPhone(String value) {
    _phone = value;
    print('Phone: ' + _phone);
  }

  //Handle Password Input
  void _handleSubmittedAmount(String value) {
    _amount = value;
    print('Amount: ' + _amount);
  }

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
                decoration: TextDecoration.underline,
                textStyle: TextStyle(fontWeight: FontWeight.bold))),
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
                      height: 10,
                    ),
                    Text('but you can change that',
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    _depositPhone(),
                    SizedBox(
                      height: 30,
                    ),
                    _depositAmount(),
                    _proceedBtn(),
                    _depositManual()
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
