import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SortikaLottery extends StatefulWidget {
  @override
  _SortikaLotteryState createState() => _SortikaLotteryState();
}

class _SortikaLotteryState extends State<SortikaLottery> {
  String _selectedClub = '100';

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
                onPressed: () {},
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
          'Club',
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
            _depositMoney();
          });
          //print(goal);
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
              )),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
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
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
