import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/models/depositModel.dart';
import 'package:wealth/utilities/styles.dart';
import 'package:wealth/global/progressDialog.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/global/errorMessage.dart';

class MpesaAuto extends StatefulWidget {
  //Identifiers
  @override
  _MpesaAutoState createState() => _MpesaAutoState();
}

class _MpesaAutoState extends State<MpesaAuto> {
  String _phone;
  double _amount;

  final Helper _helper = new Helper();

  final _formKey = GlobalKey<FormState>();

  final FocusNode focusAmount = FocusNode();

  void _handleSubmittedPhone(String value) {
    _phone = value;
    print('Phone: ' + _phone);
  }

  void _handleSubmittedAmount(String value) {
    _amount = double.parse(value.trim());
    print('Amount: ' + _amount.toString());
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
            autovalidate: true,
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

  void _mpesaAutoBtnPressed() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      //Dismiss the keyboard
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      //Show a Progress Dialog
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CustomProgressDialog(
              message: 'Processing your deposit request',
            );
          });

      //Deposit Model PlaceHolder
      DepositModel depositModel = new DepositModel(
          amount: _amount,
          destination: DepositAncestor.of(context).destination,
          goalName: DepositAncestor.of(context).goalName,
          method: DepositAncestor.of(context).method,
          phone: _phone);
      //print(depositModel.toJson());
      _helper
          .depositMoney(DepositAncestor.of(context).uid, depositModel)
          .catchError((error) {
        //Dismiss the dialog
        Navigator.of(context).pop();

        //Show the success message
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return ErrorMessage(
                message: error,
              );
            });
      }).whenComplete(() {
        //Dismiss the dialog
        Navigator.of(context).pop();

        //Show the success message
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return SuccessMessage(
                message: 'Your deposit has been received successfully',
              );
            });
      });
    }
  }

  Widget _btnMpesaAuto() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: _mpesaAutoBtnPressed,
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
      child: Form(
        key: _formKey,
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
      ),
    );
  }
}

//Inherited Widget
class DepositAncestor extends InheritedWidget {
  //Fields
  final String uid;
  final String destination;
  final String method;
  final String goalName;

  DepositAncestor(this.uid, this.destination, this.method, this.goalName,
      {Widget child})
      : super(child: child);

  static DepositAncestor of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(DepositAncestor) as DepositAncestor;

  @override
  bool updateShouldNotify(DepositAncestor oldWidget) {
    return destination != oldWidget.destination ||
        method != oldWidget.method ||
        goalName != oldWidget.goalName;
  }
}
