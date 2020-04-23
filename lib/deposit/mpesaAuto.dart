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
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(focusAmount);
            },
            validator: (value) {
              //Check if phone is available
              if (value.isEmpty) {
                return 'Phone number is required';
              }

              //Check if phone number has 10 digits
              if (value.length != 10) {
                return 'Phone number should be 10 digits';
              }

              //Check if phone number starts with 07
              if (!value.startsWith('07')) {
                return 'Phone number should start with 07';
              }

              return null;
            },
            textInputAction: TextInputAction.next,
            onSaved: _handleSubmittedPhone,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon: Icon(Icons.phone, color: Colors.white),
                labelText: 'Enter your Phone Number',
                labelStyle: hintStyle))
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
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.number,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).unfocus();
            },
            validator: (value) {
              //Check if phone is available
              if (value.isEmpty) {
                return 'Amount is required';
              }
              return null;
            },
            focusNode: focusAmount,
            textInputAction: TextInputAction.done,
            onSaved: _handleSubmittedAmount,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon:
                    Icon(FontAwesome5.money_bill_alt, color: Colors.white),
                labelText: 'Enter the amount',
                labelStyle: hintStyle))
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
