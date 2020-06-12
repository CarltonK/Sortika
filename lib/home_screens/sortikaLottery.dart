import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/errorMessage.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/models/usermodel.dart';

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
  Stream<DocumentSnapshot> walletBalance;

  List<DropdownMenuItem> itemsClubs = [
    DropdownMenuItem(
      value: '100',
      child: Text(
        'Club 100',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: '500',
      child: Text(
        'Club 500',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: '1000',
      child: Text(
        'Club 1000',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  void _acceptBtnPressed() {
    //Dismiss the dialog first
    Navigator.of(context).pop();
    //Check if the wallet amount can cover the selcted club - 100 for subscription
    double club = double.parse(_selectedClub);
    //Minimum amount
    double minAmt = amount.toDouble() - 100;
    if (minAmt >= club) {
      //Join the club
      helper.joinLottery(_selectedClub, widget.user.uid, widget.user.phone)
        .whenComplete(() {
          showCupertinoModalPopup(
            context: context, 
            builder: (context) => SuccessMessage(message: 'You have successfully joined Club $_selectedClub'),
          );
        })
        .catchError((error) {
          showCupertinoModalPopup(
            context: context, 
            builder: (context) => ErrorMessage(message: 'There was an error joining Club $_selectedClub'),
          );
        });
    }
    else {
      showCupertinoModalPopup(
        context: context, 
        builder: (context) => ErrorMessage(message: 'You do not have enough funds to join Club $_selectedClub. Please topup to ensure you can cover the club fee plus subscription fee(100).'),
      );
    }
  }

  Future _depositMoney() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text('Request to deduct $_selectedClub KES from you wallet',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.normal))),
          actions: [
            CupertinoActionSheetAction(
                onPressed: _acceptBtnPressed,
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

  Widget _lotClub() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: itemsClubs,
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
            print(_selectedClub);
            _depositMoney();
          });
        },
      ),
    );
  }

  Widget _clubSlectWidget() {
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
          _lotClub()
        ],
      ),
    );
  }

  Widget _viewMembers() {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'See whos\'s playing',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
            color: Colors.black,
          )),
        ),
        SizedBox(
          height: 5,
        ),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ExpansionTile(
            leading: Icon(Icons.people),
            title: Text(
              'Members',
              style: GoogleFonts.muli(textStyle: TextStyle()),
            ),
          ),
        ),
      ],
    ));
  }

  @override
  void initState() {
    super.initState();
    walletBalance = helper.getWalletBalance(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<DocumentSnapshot>(
        stream: walletBalance,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            amount = snapshot.data.data['amount'];

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
                _clubSlectWidget(),
                SizedBox(
                  height: 30,
                ),
                _viewMembers(),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining Time',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                          color: Colors.black,
                        )),
                      ),
                      Text(
                        '02:24:30',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            );
          }
          return SpinKitDoubleBounce(size: 200, color: Colors.greenAccent[700]);
        },
      ),
    );
  }
}
