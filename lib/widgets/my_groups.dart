import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyGroups extends StatefulWidget {
  @override
  _MyGroupsState createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
  String _groupName = 'Manchester';
  String _groupMembership = '8';
  String _myContribution = '2000';
  String _totalContribution = '8000';
  String _endDate = 'Dec 25, 2020';
  String _targetContribution = '100,000';

  Widget _singleGroup() {
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
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(20)),
                  color: Colors.white),
              child: Text(
                '$_groupName',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                // showCupertinoModalPopup(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return CupertinoActionSheet(
                //         title: Text(
                //           'Goal Options',
                //           style: GoogleFonts.muli(
                //               textStyle: TextStyle(
                //                   fontWeight:
                //                       FontWeight.bold,
                //                   color: Colors.black)),
                //         ),
                //         actions: [
                //           CupertinoActionSheetAction(
                //               onPressed: () {},
                //               child: Text(
                //                 'Edit',
                //                 style: GoogleFonts.muli(
                //                     textStyle: TextStyle(
                //                         fontWeight:
                //                             FontWeight
                //                                 .bold)),
                //               )),
                //           CupertinoActionSheetAction(
                //               onPressed: () {},
                //               child: Text(
                //                 'Redeem',
                //                 style: GoogleFonts.muli(
                //                     textStyle: TextStyle(
                //                         fontWeight:
                //                             FontWeight
                //                                 .bold)),
                //               )),
                //         ],
                //         cancelButton:
                //             CupertinoActionSheetAction(
                //                 onPressed: () {},
                //                 child: Text(
                //                   'Delete',
                //                   style: GoogleFonts.muli(
                //                       textStyle: TextStyle(
                //                           fontWeight:
                //                               FontWeight
                //                                   .bold,
                //                           color:
                //                               Colors.red)),
                //                 )),
                //       );
                //     });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(20)),
                    color: Colors.transparent),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('$_groupMembership',
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.white),
                        ))
                  ],
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
                        text: '$_myContribution KES ',
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
                        text: '$_totalContribution KES ',
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )),
                    TextSpan(
                        text: 'total contributions ',
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
                    '$_targetContribution KES',
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
                    '$_endDate',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Here are your groups',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(fontSize: 16, letterSpacing: 0.5)),
            ),
          ),
          Expanded(
            child: ListView(
              children: [_singleGroup(), _singleGroup()],
            ),
          ),
        ],
      ),
    );
  }
}
