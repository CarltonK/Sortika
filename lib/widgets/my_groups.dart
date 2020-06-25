import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wealth/analytics/analytics_funnels.dart';
import 'package:wealth/models/groupModel.dart';
import 'package:wealth/models/usermodel.dart';

class MyGroups extends StatefulWidget {
  final User user;
  MyGroups({Key key, @required this.user}) : super(key: key);
  @override
  _MyGroupsState createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
  AnalyticsFunnel funnel = AnalyticsFunnel();
  //Form Key
  final _formKey = GlobalKey<FormState>();

  Firestore _firestore = Firestore.instance;
  String relevantDocId;
  DocumentSnapshot retrievedDocument;

  String _code;
  void _handleSubmittedCode(String value) {
    _code = value.trim();
    print('Code: ' + _code);
  }

  Widget _singleGroup(DocumentSnapshot doc) {
    //Convert data to a group model
    GroupModel model = GroupModel.fromJson(doc.data);

    //Create a map from which you can add as argument to pass into edit goal page
    Map<String, dynamic> editData = doc.data;
    //Add uid to this map
    editData["uid"] = widget.user.uid;
    editData["docId"] = doc.documentID;
    editData['token'] = widget.user.token;

    //Date Parsing and Formatting
    Timestamp dateRetrieved = model.goalEndDate;
    var formatter = new DateFormat('d MMM y');
    String date = formatter.format(dateRetrieved.toDate());

    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
            tileMode: TileMode.clamp,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue[400], Colors.greenAccent[400]],
            stops: [0, 1.0]),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(20)),
                  color: Colors.white),
              child: Text(
                '${model.goalName}',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context)
                  .pushNamed('/edit-group', arguments: editData),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(20)),
                    color: Colors.transparent),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: 'You have contributed ',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white))),
                    TextSpan(
                        text:
                            '${model.goalAmountSaved.toInt().toString()} KES ',
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )),
                    TextSpan(
                        text: 'of ',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white))),
                    TextSpan(
                        text:
                            '${model.targetAmountPerp.toInt().toString()} KES ',
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )),
                    TextSpan(
                        text: 'individual target contributions ',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)))
                  ])),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 8),
                  //   child: Row(
                  //     children: <Widget>[
                  //       Text(
                  //         '0',
                  //         style: GoogleFonts.muli(
                  //             textStyle: TextStyle(
                  //                 color: Colors.white,
                  //                 fontWeight:
                  //                     FontWeight.bold)),
                  //       ),
                  //       Expanded(
                  //         child: Slider(
                  //             value: 2000,
                  //             min: 0,
                  //             max: 5000,
                  //             onChanged: (value) {}),
                  //       ),
                  //       Text(
                  //         '5000',
                  //         style: GoogleFonts.muli(
                  //             textStyle: TextStyle(
                  //                 color: Colors.white,
                  //                 fontWeight:
                  //                     FontWeight.bold)),
                  //       )
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(20)),
                  color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Target',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '${model.goalAmount.toInt().toString()} KES',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                  color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Ends on',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '$date',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _groupCodeTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).unfocus();
            },
            validator: (value) {
              //Check if password is empty
              if (value.isEmpty) {
                return 'Code is required';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onSaved: _handleSubmittedCode,
            obscureText: false,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue))))
      ],
    );
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
                SpinKitDualRing(
                  color: Colors.greenAccent[700],
                  size: 100,
                )
              ],
            ),
          );
        });
  }

  Future _promptGroup404() {
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
                  Icons.sentiment_very_dissatisfied,
                  size: 100,
                  color: Colors.red,
                ),
                Text(
                  'The code does not match any group',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  Future _promptGroupAlreadyIn() {
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
                  Icons.sentiment_neutral,
                  size: 100,
                  color: Colors.blue,
                ),
                Text(
                  'You are a member of the group',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  Future _promptGroupJoinSuccess(String name) {
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
                  Icons.sentiment_satisfied,
                  size: 100,
                  color: Colors.blue,
                ),
                Text(
                  'You have joined $name',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  Future<bool> _verifyCode() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("groups")
        .where("groupCode", isEqualTo: _code)
        .getDocuments();
    //Check if one result was returned
    if (querySnapshot.documents.length > 0) {
      //Join group
      relevantDocId = querySnapshot.documents.first.documentID;
      retrievedDocument = querySnapshot.documents.first;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _isMemberIn() async {
    DocumentSnapshot doc =
        await _firestore.collection("groups").document(relevantDocId).get();
    //Get members array
    List members = doc.data["members"];
    if (members.contains(widget.user.uid)) {
      return true;
    } else {
      return false;
    }
  }

  Future _showGroupPreview() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        //Convert documentsnapshot to group model
        GroupModel meinGruppe = GroupModel.fromJson(retrievedDocument.data);
        print(meinGruppe.goalCategory);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Center(
            child: Text(
              meinGruppe.goalName,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Group Objective',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.black.withOpacity(0.6))),
              ),
              Text(
                meinGruppe.groupObjective,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.black, fontSize: 16)),
              ),
              SizedBox(height: 5),
              Text(
                'Individual Contribution',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.black.withOpacity(0.6))),
              ),
              Text(
                '${meinGruppe.targetAmountPerp.toString()} KES',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  //Dismiss first dialog
                  Navigator.of(context).pop();
                  _addToGroup().then((value) async {
                    await funnel.logJoinGroup(meinGruppe.groupCode);
                    _promptGroupJoinSuccess(value);
                  });
                },
                child: Text(
                  'JOIN',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                )),
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ))
          ],
        );
      },
    );
  }

  Future<String> _addToGroup() async {
    //Add to group
    DocumentSnapshot doc = retrievedDocument;
    List members = doc.data["members"];
    members.add(widget.user.uid);
    await _firestore
        .collection("groups")
        .document(relevantDocId)
        .updateData({"members": members});
    //Add to user goals
    GroupModel model = GroupModel.fromJson(doc.data);
    await _firestore
        .collection("users")
        .document(widget.user.uid)
        .collection("goals")
        .document()
        .setData(model.toJson());

    return doc.data["goalName"];
  }

  void _joinBtnPressed() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      //Dismiss the keyboard
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      //Dismiss the dialog
      Navigator.of(context).pop();
      //Show a progress dialog
      _showUserProgress();
      //Check code
      _verifyCode().then((value) {
        Navigator.of(context).pop();
        if (value) {
          //Check if user is already a member
          _isMemberIn().then((value) {
            if (value) {
              _promptGroupAlreadyIn();
            } else {
              _showGroupPreview();
            }
          });
        } else {
          _promptGroup404();
        }
      });
    }
  }

  Future _joinGroup() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Enter Group Code',
              style: GoogleFonts.muli(textStyle: TextStyle()),
            ),
            content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [_groupCodeTF()],
                )),
            actions: [
              FlatButton(
                  onPressed: _joinBtnPressed,
                  child: Text(
                    'JOIN',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  )),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Join Group',
                icon: Icon(
                  FontAwesome.group,
                  color: Colors.black,
                ),
                onPressed: _joinGroup,
              )
            ],
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("groups")
                .where("members", arrayContains: widget.user.uid)
                .orderBy("goalCreateDate")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.documents.length == 0) {
                  return Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sentiment_neutral,
                        size: 100,
                        color: Colors.red,
                      ),
                      Text(
                        'You are not a member of any group(s)',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ));
                }
                return ListView(
                  children: snapshot.data.documents
                      .map((map) => _singleGroup(map))
                      .toList(),
                );
              }
              return SpinKitDoubleBounce(
                color: Colors.greenAccent[700],
                size: 100,
              );
            },
          )),
        ],
      ),
    );
  }
}
