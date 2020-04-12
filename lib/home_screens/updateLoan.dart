import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class UpdateLoan extends StatefulWidget {
  @override
  _UpdateLoanState createState() => _UpdateLoanState();
}

class _UpdateLoanState extends State<UpdateLoan> {
  Widget _receiptText() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: 'You have received a loan request from  ',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black))),
              TextSpan(
                  text: 'Sansa Stark',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      decoration: TextDecoration.underline)),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _containerAmount() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Amount',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextFormField(
                keyboardType: TextInputType.number,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.black,
                )),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  suffixText: 'KES',
                  hintText: '20,000',
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                  suffixStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                    color: Colors.black,
                  )),
                  border: InputBorder.none,
                )),
          )
        ],
      ),
    );
  }

  Widget _containerInterest() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Interest',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextFormField(
                keyboardType: TextInputType.number,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.black,
                )),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  suffixText: '%',
                  hintText: '8 %',
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                  suffixStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                    color: Colors.black,
                  )),
                  border: InputBorder.none,
                )),
          )
        ],
      ),
    );
  }

  Widget _containerDuration() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ending',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextFormField(
                keyboardType: TextInputType.number,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.black,
                )),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  hintText: 'Dec 25, 2020',
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                  border: InputBorder.none,
                )),
          )
        ],
      ),
    );
  }

  Widget _cardTerms() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _containerAmount(),
            _containerInterest(),
            _containerDuration()
          ],
        ),
      ),
    );
  }

  Widget _lIc() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Loan + Interest Cover',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        Text('XXXX',
            style: GoogleFonts.muli(
              textStyle:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
            ))
      ],
    );
  }

  Widget _btnUpdate() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: () {},
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: commonColor,
        child: Text(
          'UPDATE',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: commonColor,
        title: Text('Update Request',
            style: GoogleFonts.muli(textStyle: TextStyle())),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _receiptText(),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Terms',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _cardTerms(),
                  SizedBox(
                    height: 20,
                  ),
                  _lIc(),
                  _btnUpdate()
                ],
              ),
            ),
          ),
          value: SystemUiOverlayStyle.light),
    );
  }
}
