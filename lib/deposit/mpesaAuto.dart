import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class MpesaAuto extends StatelessWidget {
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

  Widget _depositPhone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Phone',
          style: labelStyle,
        ),
        SizedBox(
          height: 5,
        ),
        Container(
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
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.phone,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.black,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(focusAmount);
              },
              textInputAction: TextInputAction.next,
              onSaved: _handleSubmittedPhone,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.phone, color: Colors.black),
                  hintText: '07XXXXXXXX',
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black)))),
        )
      ],
    );
  }

  Widget _depositAmount(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Amount',
          style: labelStyle,
        ),
        SizedBox(
          height: 5,
        ),
        Container(
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
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.number,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.black,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
              focusNode: focusAmount,
              onSaved: _handleSubmittedAmount,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(MaterialCommunityIcons.cash_multiple,
                      color: Colors.black),
                  hintText: 'Enter amount',
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black)))),
        )
      ],
    );
  }

  Widget _btnMpesaAuto() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: () {},
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'DEPOSIT',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
            letterSpacing: 1.5,
            color: Colors.black,
            fontSize: 20,
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _depositPhone(context),
          SizedBox(
            height: 20,
          ),
          _depositAmount(context),
          _btnMpesaAuto()
        ],
      ),
    );
  }
}
