import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/models/captureModel.dart';
import 'package:wealth/utilities/styles.dart';

class ManualCapture extends StatefulWidget {
  final String uid;

  ManualCapture({@required this.uid});
  @override
  _ManualCaptureState createState() => _ManualCaptureState();
}

class _ManualCaptureState extends State<ManualCapture> {
  String _itemType;
  final _formKey = GlobalKey<FormState>();
  Color color = Colors.blue;
  String amount;

  Helper helper = new Helper();

  void _handleAmountField(String value) {
    amount = value + ".00";
    print('Amount: $amount');
  }

  List<DropdownMenuItem> entryTypes = [
    DropdownMenuItem(
      value: 'received',
      child: Text(
        'Income',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'sent',
      child: Text(
        'Expense',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  Widget _typeEntry() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: entryTypes,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: _itemType,
        hint: Text(
          'Type',
          style: GoogleFonts.muli(textStyle: TextStyle()),
        ),
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _itemType = value;
            if (value == 'sent') {
              color = Colors.red;
            }
            if (value == 'received') {
              color = Colors.green;
            }
          });
          print(_itemType);
        },
      ),
    );
  }

  Future _promptUser(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              '$message',
              textAlign: TextAlign.center,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(color: Colors.black, fontSize: 20)),
            ),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  //Pop the dialog
                  Navigator.of(context).pop();
                },
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.muli(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.red),
                )),
          );
        });
  }

  Future _promptUserSuccess() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.done,
                  size: 50,
                  color: Colors.green,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Your entry has been captured successfully',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  Future _showUserProgress() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Capturing your data...',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                SizedBox(
                  height: 10,
                ),
                SpinKitDualRing(
                  color: Colors.greenAccent[700],
                  size: 100,
                )
              ],
            ),
          );
        });
  }

  void _capturePressed() {
    if (_itemType == null) {
      _promptUser('Please select the type');
    }
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      Navigator.of(context).pop();

      CaptureModel model = new CaptureModel(
          transactionAmount: amount,
          transactionType: _itemType,
          transactionUser: widget.uid);

      helper.manualCapture(model).catchError((error) {
        _promptUser(error.toString());
      });
      _promptUserSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _typeEntry(),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              textInputAction: TextInputAction.done,
              onSaved: _handleAmountField,
              style:
                  GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'KES',
                suffixStyle: hintStyleBlack,
                labelText: 'Amount',
                labelStyle: hintStyleBlack,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              },
            ),
            SizedBox(
              height: 10,
            ),
            RaisedButton(
              onPressed: _capturePressed,
              color: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              child: Text(
                'Capture',
                style: GoogleFonts.muli(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            )
          ],
        ));
  }
}
