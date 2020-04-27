import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wealth/models/groupModel.dart';

class MyGroups extends StatefulWidget {
  final String uid;
  MyGroups({Key key, @required this.uid}) : super(key: key);
  @override
  _MyGroupsState createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
  Widget _singleGroup(DocumentSnapshot doc) {
    //Convert data to a group model
    GroupModel model = GroupModel.fromJson(doc.data);

    //Create a map from which you can add as argument to pass into edit goal page
    Map<String, dynamic> editData = doc.data;
    //Add uid to this map
    editData["uid"] = widget.uid;
    editData["docId"] = doc.documentID;

    //Date Parsing and Formatting
    Timestamp dateRetrieved = model.goalEndDate;
    var formatter = new DateFormat('d MMM y');
    String date = formatter.format(dateRetrieved.toDate());

    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'My Groups',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("groups")
                .where("members", arrayContains: widget.uid)
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
