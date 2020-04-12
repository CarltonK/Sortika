import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class FinancialRatios extends StatefulWidget {
  @override
  _FinancialRatiosState createState() => _FinancialRatiosState();
}

class _FinancialRatiosState extends State<FinancialRatios> {
  int _age;

  void _handleSubmittedAge(String value) {
    _age = int.parse(value);
    print('Age: ' + _age.toString());
  }

  Widget _ageWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TextFormField(
            keyboardType: TextInputType.number,
            maxLength: 2,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
            onFieldSubmitted: (value) {},
            textInputAction: TextInputAction.next,
            onSaved: _handleSubmittedAge,
            decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.black54,
                ),
                hintText: 'How old are you?',
                hintStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.black,
                )))),
        RaisedButton(
          onPressed: () {},
          color: commonColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Text(
            'CALCULATE',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
            )),
          ),
        )
      ],
    );
  }

  Widget _calculateWidget() {
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
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              _calculateWidget(),
              SizedBox(
                height: 30,
              ),
              Text(
                'Networth Ratio',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.black,
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
