import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class FinancialRatios extends StatefulWidget {
  @override
  _FinancialRatiosState createState() => _FinancialRatiosState();
}

class _FinancialRatiosState extends State<FinancialRatios> {
  //Placeholders
  int _age;
  double _annualIncome;
  double _networthValue;

  //FocusNodes
  final focusIncome = FocusNode();

  //Form Key
  final _formKey = GlobalKey<FormState>();

  void _handleSubmittedAge(String value) {
    _age = int.parse(value);
    print('Age: ' + _age.toString());
  }

  void _handleSubmittedAnnualIncome(String value) {
    _annualIncome = double.parse(value);
    print('Annual Income: ' + _annualIncome.toString());
  }

  Future _showNetworth() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            'Target Networth',
            style: GoogleFonts.quicksand(
              fontSize: 20,
            ),
          ),
          message: Text(
            '${_networthValue.toStringAsFixed(2)} KES',
            style: GoogleFonts.quicksand(
                fontSize: 25, fontWeight: FontWeight.w800, color: Colors.black),
          ),
        );
      },
    );
  }

  void _calculateTargetNetworthBtnPressed() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      //Actual Calculation
      _networthValue = _age * (_annualIncome / 10);
      print('Target Networth: $_networthValue');
      _showNetworth();
    }
  }

  Widget _ageWidget() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
              keyboardType: TextInputType.number,
              maxLength: 2,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.black,
              )),
              onFieldSubmitted: (value) =>
                  FocusScope.of(context).requestFocus(focusIncome),
              textInputAction: TextInputAction.next,
              onSaved: _handleSubmittedAge,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your age';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black54,
                  ),
                  labelText: 'How old are you?',
                  labelStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                    color: Colors.black,
                  )))),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              keyboardType: TextInputType.number,
              focusNode: focusIncome,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.black,
              )),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your annual income in KES';
                }
                return null;
              },
              onFieldSubmitted: (value) => FocusScope.of(context).unfocus(),
              textInputAction: TextInputAction.done,
              onSaved: _handleSubmittedAnnualIncome,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black54,
                  ),
                  labelText: 'What is your annual income?',
                  suffixText: 'KES',
                  suffixStyle: hintStyleBlack,
                  labelStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                    color: Colors.black,
                  )))),
          SizedBox(
            height: 20,
          ),
          RaisedButton(
            onPressed: _calculateTargetNetworthBtnPressed,
            color: commonColor,
            padding: EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Text(
              'CALCULATE',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  Widget _targetNetworthWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Networth',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
          ),
          SizedBox(
            height: 10,
          ),
          _ageWidget()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Text(
              'Networth Calculator',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 30,
            ),
            _targetNetworthWidget(),
          ],
        ),
      ),
    );
  }
}
