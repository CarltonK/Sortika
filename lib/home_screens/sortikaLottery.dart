import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/errorMessage.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:wealth/utilities/styles.dart';
import 'package:wealth/widgets/unsuccessfull_error.dart';
import 'package:wealth/models/lotteryModel.dart';

class SortikaLottery extends StatefulWidget {
  final User user;

  SortikaLottery({@required this.user});

  @override
  _SortikaLotteryState createState() => _SortikaLotteryState();
}

class _SortikaLotteryState extends State<SortikaLottery> {
  final Helper helper = new Helper();
  num amount;
  String _selectedClub;
  Future getLottery;
  Future<LotteryModel> getSingleLottery;
  DocumentSnapshot myDoc;

  void _acceptBtnPressed(DocumentSnapshot doc) async {
    LotteryModel model = LotteryModel.fromJson(doc.data);
    //Dismiss the dialog first
    Navigator.of(context).pop();
    //Check if the wallet amount can cover the selcted club - 100 for subscription
    num walletAmount = await helper.getWalletBalanceNumber(widget.user.uid);
    int totalToJoin = model.subscriptionFee + model.ticketFee;
    if (walletAmount >= totalToJoin) {
      String ticket = codeGenerator();
      //Join the club
      helper
          .joinLottery(doc.documentID, widget.user.uid, ticket, model.name,
              totalToJoin, widget.user.token)
          .then((value) {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => SuccessMessage(
              message:
                  'You have successfully joined ${model.name}. Check your notifications for your ticket number'),
        );
      }).catchError((error) {
        print(error.toString());
        if (error.toString().contains('PERMISSION_DENIED')) {
          showCupertinoModalPopup(
            context: context,
            builder: (context) =>
                ErrorMessage(message: 'You are a participant in ${model.name}'),
          );
        } else {
          showCupertinoModalPopup(
            context: context,
            builder: (context) => ErrorMessage(
                message: 'There was an error joining ${model.name}'),
          );
        }
      });
    } else {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => ErrorMessage(
            message:
                'You do not have enough funds to join ${model.name}. Please topup.'),
      );
    }
  }

  Future _depositMoney(DocumentSnapshot doc) {
    LotteryModel model = LotteryModel.fromJson(doc.data);
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
              'The subscription fee is ${model.subscriptionFee} KES and a single ticket costs ${model.ticketFee} KES',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.normal))),
          message: Text(
              '${model.subscriptionFee + model.ticketFee} KES will be deducted from your wallet'),
          actions: [
            CupertinoActionSheetAction(
                onPressed: () => _acceptBtnPressed(doc),
                child: Text(
                  'ACCEPT',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                ))
          ],
          cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'DECLINE',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              )),
        );
      },
    );
  }

  Widget _lotClub(List<DocumentSnapshot> docs) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: docs
            .map(
              (club) => DropdownMenuItem(
                value: club.data['name'],
                child: Text(
                  club.data['name'],
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ),
            )
            .toList(),
        underline: Divider(
          color: Colors.transparent,
        ),
        value: _selectedClub,
        hint: Text(
          'Select a club to join',
          style: GoogleFonts.muli(textStyle: TextStyle()),
        ),
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _selectedClub = value;
            DocumentSnapshot doc = docs
                .where((element) => element.data['name'] == _selectedClub)
                .toList()[0];
            getSingleLottery = helper.getSingleLottery(doc.documentID);
            myDoc = doc;
          });
        },
      ),
    );
  }

  Widget _clubSelectWidget(List<DocumentSnapshot> docs) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Select a lottery club to get started',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
          ),
          SizedBox(
            height: 5,
          ),
          _lotClub(docs)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getLottery = helper.getLottery();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<QuerySnapshot>(
        future: getLottery,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.data.documents.length == 0) {
                return UnsuccessfullError(
                    message: 'There are no active lotteries running');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Lottery',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  _clubSelectWidget(snapshot.data.documents),
                  SizedBox(
                    height: 20,
                  ),
                  FutureBuilder<LotteryModel>(
                    future: getSingleLottery,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return UnsuccessfullError(
                            message: 'Please select a lottery club',
                          );
                        case ConnectionState.done:
                          DateTime now = DateTime.now();
                          DateTime end = snapshot.data.end.toDate();

                          String minRemaining =
                              end.difference(now).inMinutes.toString() +
                                  ' MINS';
                          if (end.difference(now).inMinutes < 1) {
                            minRemaining =
                                end.difference(now).inSeconds.toString() +
                                    ' SECS';
                          }

                          if (end.compareTo(now).isNegative) {
                            return UnsuccessfullError(
                              message: 'This lottery is not active',
                            );
                          }
                          return Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'How many people are playing ?',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                        color: Colors.black,
                                      )),
                                    ),
                                    Text(
                                      snapshot.data.participants.toString(),
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Possible Winnings',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                        color: Colors.black,
                                      )),
                                    ),
                                    Text(
                                      '${snapshot.data.participants * snapshot.data.subscriptionFee} KES',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Time remaining: ',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                        color: Colors.black,
                                      )),
                                    ),
                                    Text(
                                      minRemaining,
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                snapshot.data.winner == null
                                    ? Center(
                                        child: Text(
                                          'The winning ticket will be announced when the lottery ends',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.muli(
                                              textStyle: TextStyle(
                                            color: Colors.black,
                                          )),
                                        ),
                                      )
                                    : Container(),
                                Center(
                                  child: RaisedButton(
                                    elevation: 5,
                                    padding: EdgeInsets.all(8),
                                    child: Text('JOIN'),
                                    onPressed: () => _depositMoney(myDoc),
                                  ),
                                )
                              ],
                            ),
                          );
                        case ConnectionState.active:
                        case ConnectionState.waiting:
                          return SpinKitDoubleBounce(
                            color: Colors.greenAccent[700],
                            size: 150,
                          );
                        default:
                          return SpinKitDoubleBounce(
                            color: Colors.greenAccent[700],
                            size: 150,
                          );
                      }
                    },
                  )
                ],
              );
              break;
            default:
              return SpinKitDoubleBounce(
                color: Colors.greenAccent[700],
                size: 150,
              );
          }
        },
      ),
    );
  }
}
