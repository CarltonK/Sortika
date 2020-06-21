import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/errorMessage.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/models/loanPayModel.dart';
import 'package:wealth/utilities/styles.dart';

class PayLoan extends StatefulWidget {
  @override
  _PayLoanState createState() => _PayLoanState();
}

class _PayLoanState extends State<PayLoan> {
  Map<String, dynamic> loanData;
  num totalAmount;
  final _formKey = GlobalKey<FormState>();

  Helper helper = new Helper();

  final FocusNode focusAmount = FocusNode();

  void _handleSubmittedAmount(String value) {
    submittedAmount = double.parse(value.trim());
    print('Amount: ' + submittedAmount.toString());
  }

  double submittedAmount;

  Stream<DocumentSnapshot> walletDoc;

  Future payLoan;

  Widget _balanceText() {
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
                text: '${totalAmount.ceilToDouble()} KES',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    decoration: TextDecoration.underline)),
            TextSpan(
                text: '\nOverpayments will be credited back to you',
                style: GoogleFonts.muli(
                    fontSize: 11, textStyle: TextStyle(color: Colors.white)))
          ])),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _loanAmount(var amount) {
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
        TextFormField(
            autofocus: false,
            autovalidate: true,
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
              if (double.parse(value) > totalAmount.ceil()) {
                return 'The loan balance is ${totalAmount.ceil()} KES';
              }
              if (double.parse(value) > amount) {
                return 'You have insuffient funds, please deposit your wallet';
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
                suffixText: 'KES',
                suffixStyle: hintStyle,
                prefixIcon:
                    Icon(FontAwesome5.money_bill_alt, color: Colors.white),
                labelText: 'Enter the amount',
                labelStyle: hintStyle))
      ],
    );
  }

  void _payBtnPressed() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      LoanPaymentModel model = new LoanPaymentModel(
          borrowerUid: loanData['loanBorrower'],
          lenderUid: loanData['loanLender'],
          amount: submittedAmount,
          loanDoc: loanData['docId']);

      helper
          .payP2pLoan(model)
          .then((value) => {
                showCupertinoModalPopup(
                    context: context,
                    builder: (context) => SuccessMessage(
                        message: 'We are processing your request'))
              })
          .catchError((error) => {
                showCupertinoModalPopup(
                    context: context,
                    builder: (context) =>
                        ErrorMessage(message: error.toString()))
              });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Retrieve Loan Data
    loanData = ModalRoute.of(context).settings.arguments;
    totalAmount = loanData["loanBalance"];
    walletDoc = helper.getWalletBalance(loanData['loanBorrower']);
    // print('Retrieved Loan Data: $loanData');

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
                        StreamBuilder<DocumentSnapshot>(
                          stream: walletDoc,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              num amount = snapshot.data.data['amount'];
                              print(amount);
                              //Check if amount can pay the current loan
                              return Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    _loanAmount(amount),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    RaisedButton(
                                      padding: EdgeInsets.all(10),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      color: Colors.white,
                                      child: Text(
                                        'Pay',
                                        style: GoogleFonts.muli(fontSize: 20),
                                      ),
                                      onPressed: _payBtnPressed,
                                    )
                                  ],
                                ),
                              );
                            }
                            return SpinKitDoubleBounce(
                              size: 200,
                              color: Colors.greenAccent[700],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            value: SystemUiOverlayStyle.light));
  }
}
