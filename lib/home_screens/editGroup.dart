import 'dart:async';
import 'package:intl/intl.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/models/groupModel.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
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
  Helper _helper = new Helper();

  Future _leaveGroup() async {
    if (data["groupAdmin"] == data["uid"]) {
      await _firestore.collection("groups").document(data["docId"]).delete();

      //Delete the goal
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .document(data["uid"])
          .collection("goals")
          .where("groupCode", isEqualTo: data["groupCode"])
          .limit(1)
          .getDocuments();

      String docId = snapshot.documents.first.documentID;
      print(docId);

      await _firestore
          .collection("users")
          .document(data["uid"])
          .collection("goals")
          .document(docId)
          .delete();
    } else {
      //Leave group
      await _firestore
          .collection("groups")
          .document(data["docId"])
          .get()
          .then((value) async {
        List<dynamic> members = value.data["members"];
        members.remove(data["uid"]);
        //Write the document
        await _firestore
            .collection("groups")
            .document(value.documentID)
            .updateData({"members": members});
      });

      //Delete User Document from members subcollection
      //DocumentID is userID
      await _firestore
          .collection('groups')
          .document(data["docId"])
          .collection('members')
          .document(data["uid"])
          .delete();

      //Delete the goal
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .document(data["uid"])
          .collection("goals")
          .where("groupCode", isEqualTo: data["groupCode"])
          .limit(1)
          .getDocuments();

      String docId = snapshot.documents.first.documentID;
      print(docId);

      await _firestore
          .collection("users")
          .document(data["uid"])
          .collection("goals")
          .document(docId)
          .delete();
    }
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
                  'Processing your request...',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
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

  Future _showleftGroup() {
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
                  Icons.sentiment_dissatisfied,
                  size: 100,
                  color: Colors.red,
                ),
                Text(
                  'We\'re sorry to see you go',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  void _deleteGroup() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              data["groupAdmin"] == data["uid"]
                  ? 'Are you sure you want to delete this group?'
                  : 'Are you sure you want to leave?',
              textAlign: TextAlign.center,
              style: GoogleFonts.muli(textStyle: TextStyle()),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    //Pop initial doalog
                    Navigator.of(context).pop();
                    _leaveGroup().whenComplete(() {
                      _showleftGroup();
                    });
                  },
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
    var targetAmount = data["goalAmount"];
    String targetAmountString = targetAmount.toInt().toString();

    var savedAmount = data["goalAmountSaved"];
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
                height: 5,
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
                height: 5,
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

  Widget _endDateWidget() {
    //Date Parsing and Formatting
    Timestamp dateRetrieved = data['goalEndDate'];
    var formatter = new DateFormat('d MMM y');
    String date = formatter.format(dateRetrieved.toDate());

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('End Date',
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
              child: Text(date,
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

  Future<QuerySnapshot> _getMemberDetails(String gID) async {
    QuerySnapshot queries = await _firestore
        .collection('groups')
        .document(gID)
        .collection('members')
        .getDocuments();
    return queries;
  }

  // void _nudgeMember(int index, User user) async {
  //   await _firestore
  //       .collection("nudges")
  //       .document()
  //       .setData({'token': user.token});
  // }

  Future showMemberStats(String uid) async {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Center(
            child: Text('Member Details',
                style: GoogleFonts.muli(textStyle: TextStyle())),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.25,
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder<DocumentSnapshot>(
              future: _helper.getGroupGoal(uid, data['groupCode']),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  GroupModel model = GroupModel.fromJson(snapshot.data.data);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Target:',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))),
                          Text('${model.goalAmount} KES',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Contributed:',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))),
                          Text('${model.goalAmountSaved} KES',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  );
                }
                return SpinKitDoubleBounce(
                  color: commonColor,
                  size: MediaQuery.of(context).size.height * 0.2,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _groupMembers() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      height: 200,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Members',
              style: GoogleFonts.muli(
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          SizedBox(
            height: 5,
          ),
          FutureBuilder<QuerySnapshot>(
            future: _getMemberDetails(data["docId"]),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.documents.length == 0) {
                  return Center(
                    child: Text(
                      'This group has no members (yet)',
                      style:
                          GoogleFonts.muli(textStyle: TextStyle(fontSize: 16)),
                    ),
                  );
                }
                return Container(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      User user =
                          User.fromJson(snapshot.data.documents[index].data);

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          width: 240,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              user.photoURL != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Opacity(
                                        opacity: 0.3,
                                        child: Image(
                                            fit: BoxFit.cover,
                                            width: 240,
                                            image: NetworkImage(user.photoURL)),
                                      ),
                                    )
                                  : Container(),
                              Text(
                                user.fullName.split(' ')[0],
                                style: GoogleFonts.muli(
                                    textStyle: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Positioned(
                                right: 1,
                                top: 1,
                                child: IconButton(
                                    icon: Icon(
                                        MaterialCommunityIcons.human_greeting),
                                    tooltip: 'Stats',
                                    onPressed: () => showMemberStats(snapshot
                                        .data.documents[index].documentID)
                                    // data["uid"] == data['members'][index]
                                    //     ? null
                                    //     : _nudgeMember(index, user),
                                    ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return Center(child: LinearProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  void _sendInvite() {
    var groupName = data["goalName"];
    var groupCode = data["groupCode"];
    try {
      Share.share(
          'Please join my group ($groupName) on Sortika using this code $groupCode');
    } catch (error) {
      print('INVITE ERROR: $error');
    }
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
            data["groupAdmin"] == data["uid"]
                ? IconButton(
                    icon: Icon(Icons.share),
                    color: Colors.red,
                    onPressed: _sendInvite,
                  )
                : Container(),
            IconButton(
              icon: Icon(Icons.delete),
              color: Colors.red,
              onPressed: _deleteGroup,
            ),
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
                    _endDateWidget(),
                    SizedBox(
                      height: 30,
                    ),
                    data['groupAdmin'] == data['uid']
                        ? _groupMembers()
                        : Container(),
                    //_updateBtn()
                  ],
                ),
              ),
            ),
            value: SystemUiOverlayStyle.light));
  }
}
