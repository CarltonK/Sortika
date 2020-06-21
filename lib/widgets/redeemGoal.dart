import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/errorMessage.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/models/goalmodel.dart';

class RedeemGoal extends StatefulWidget {
  final GoalModel goalModel;
  final String docId;
  final String token;

  RedeemGoal({@required this.goalModel, @required this.docId, @required this.token});

  @override
  _RedeemGoalState createState() => _RedeemGoalState();
}

class _RedeemGoalState extends State<RedeemGoal> {
  final _formKey = GlobalKey<FormState>();

  double amount;
  var redeemableAmount;

  Helper helper = new Helper();

  _handleSavedAmount(String value) {
    amount = double.parse(value);
    print(amount);
  }

  Widget _amountWidget() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount',
              style: GoogleFonts.muli(
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                height: 50,
                child: TextFormField(
                  enabled: true,
                  autovalidate: true,
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black)),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please specify an amount';
                    }
                    if (double.parse(value) > redeemableAmount) {
                      return 'You can only redeem $redeemableAmount';
                    }
                    return null;
                  },
                  onSaved: _handleSavedAmount,
                  decoration: InputDecoration(
                    hintText: 'Please enter amount',
                    suffixText: ' KES',
                    suffixStyle: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.black)),
                    hintStyle: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w300)),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Future _promptSuccess() {
    return showCupertinoModalPopup(
          context: context, 
          builder: (context) => SuccessMessage(message: 'We have received your request to redeem $amount KES'),
        );
  }

  Future _promptError(String error) {
    return showCupertinoModalPopup(
          context: context, 
          builder: (context) => ErrorMessage(message: error),
        );
  }

  void redeemBtnPressed() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      //Dismiss the keyboard
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      //Dismiss the dialog
      Navigator.of(context).pop();
      helper.redeemMyGoal(widget.goalModel.uid, widget.docId, widget.token, amount)
        .whenComplete(() => print('success'))
        .catchError((error) => _promptError(error.toString()));
      _promptSuccess();
    }
  }

  Widget _redeemButton() {
    return MaterialButton(
      onPressed: redeemBtnPressed,
      color: Colors.greenAccent[700],
      padding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      child: Text('Redeem'),
    );
  }

  @override
  Widget build(BuildContext context) {
    redeemableAmount = widget.goalModel.goalCategory == 'Loan Fund' ? widget.goalModel.goalAmountSaved - 200 : widget.goalModel.goalAmountSaved;

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _amountWidget(),
            _redeemButton()
          ],
        ),
      ),
    );
  }
}
