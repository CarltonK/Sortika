import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class EditGroup extends StatefulWidget {
  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  void _deleteGroup() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Are you sure you want to leave?',
              style: GoogleFonts.muli(textStyle: TextStyle()),
            ),
            actions: [
              FlatButton(
                  onPressed: () {},
                  child: Text(
                    'YES',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.red)),
                  )),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'NO',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.green)),
                  ))
            ],
          );
        });
  }

  Widget _groupSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
              color: commonColor, borderRadius: BorderRadius.circular(12)),
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Target',
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '100,000',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: commonColor, borderRadius: BorderRadius.circular(12)),
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current',
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '8,000',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _objectiveWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Objectives',
              style: GoogleFonts.muli(
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          SizedBox(
            height: 5,
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: Text('We want to open a business',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(fontWeight: FontWeight.normal))),
            ),
          )
        ],
      ),
    );
  }

  Widget _updateBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
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

  Widget _groupMembers() {
    return Card(
      child: ExpansionTile(
          leading: Icon(
            Icons.people,
            color: Colors.black,
          ),
          title: Text('Members',
              style: GoogleFonts.muli(
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: commonColor,
          title: Text('Manchester',
              style: GoogleFonts.muli(textStyle: TextStyle())),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              color: Colors.red,
              onPressed: _deleteGroup,
            )
          ],
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _groupSummary(),
                    SizedBox(
                      height: 30,
                    ),
                    _objectiveWidget(),
                    SizedBox(
                      height: 30,
                    ),
                    _groupMembers(),
                    _updateBtn()
                  ],
                ),
              ),
            ),
            value: SystemUiOverlayStyle.light));
  }
}
