import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class EditGroup extends StatefulWidget {
  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  //Data Holder
  static Map<String, dynamic> data;
  final Firestore _firestore = Firestore.instance;
  Future<DocumentSnapshot> singleUserDoc;
  List<Map> users = [];

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
    double targetAmount = data["goalAmount"];
    String targetAmountString = targetAmount.toInt().toString();

    double savedAmount = data["goalAmountSaved"];
    String savedAmountString = savedAmount.toInt().toString();

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
                '$targetAmountString',
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
                '$savedAmountString',
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
          Text('Objective',
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
              child: Text('${data["groupObjective"]}',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(fontWeight: FontWeight.normal))),
            ),
          )
        ],
      ),
    );
  }

  void _updateBtnPressed() {}

  Widget _updateBtn() {
    //Check if member is admin
    String userId = data["uid"];
    String groupAdmin = data["groupAdmin"];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: userId == groupAdmin ? () => _updateBtnPressed : null,
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

  Widget _getUserDetails(dynamic value) {
    //access user details
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '$value',
        style: labelStyleBlack,
      ),
    );
  }

  Widget _groupMembers() {
    List<dynamic> membersArray = data["members"];
    // int listLength = membersArray.length;
    // //Loop through list to get uids
    // for (int i = 0; i < listLength ; i++) {
    //   print('Members: ${membersArray[i]}');
    //   //Retrieve data for each
    //   singleUserDoc = _firestore.collection("users").document(membersArray[i]).get().then((value) {
    //     Map<String, dynamic> singleUserMap = {'name': value.data["fullName"],'email':value.data["email"]};
    //     users.add(singleUserMap);
    //   });
    // }

    return Card(
      child: ExpansionTile(
        leading: Icon(
          Icons.people,
        ),
        title: Text('Members',
            style: GoogleFonts.muli(
                textStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
        children: membersArray.map((map) => _getUserDetails(map)).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Retrieve data
    data = ModalRoute.of(context).settings.arguments;
    print('Single Group Data: $data');

    return Scaffold(
        appBar: AppBar(
          backgroundColor: commonColor,
          title: Text('${data["goalName"]}',
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
                    //_updateBtn()
                  ],
                ),
              ),
            ),
            value: SystemUiOverlayStyle.light));
  }
}
