import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/goal.dart';
import 'package:wealth/utilities/styles.dart';
import 'package:wealth/widgets/group_savings.dart';
import 'package:wealth/widgets/investment_goal.dart';
import 'package:wealth/widgets/savings_goal.dart';

class CreateGoal extends StatefulWidget {
  @override
  _CreateGoalState createState() => _CreateGoalState();
}

class _CreateGoalState extends State<CreateGoal> {
  // //FocusNodes
  // final focusAmount = FocusNode();

  // //Identifiers
  // String _name, _amount;
  // int _currentPage = 0;

  // //Handle Phone Input
  // void _handleSubmittedName(String value) {
  //   _name = value;
  //   print('Name: ' + _name);
  // }

  // //Handle Password Input
  // void _handleSubmittedAmount(String value) {
  //   _amount = value;
  //   print('Amount: ' + _amount);
  // }

  DateTime _date;
  String _dateDay = '04';
  int _dateMonth = 7;
  String _dateYear = '2020';

  //Month Names
  List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  // Identifier
  int _currentPage = 0;

  //Goal Pages
  List<Widget> goalPages = [SavingsGoal(), InvestmentGoal(), GroupSavings()];

  PageController _controller = PageController(viewportFraction: 0.85);
  PageController _controllerMainPage = PageController(viewportFraction: 1);

  Widget _goalCategoryWidget() {
    return Container(
      height: 80,
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        onPageChanged: (value) {
          setState(() {
            _currentPage = value;
            //Change to next page
            _controllerMainPage.animateToPage(_currentPage,
                duration: Duration(milliseconds: 200), curve: Curves.ease);
          });
        },
        children:
            goals.map((map) => _categoryItem(map.title, map.subtitle)).toList(),
      ),
    );
  }

  //Budget Item
  Widget _categoryItem(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: Colors.purple),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              child: Icon(
                Icons.label,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.purple[200])),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$title',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '$subtitle',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }

  // Widget _goalName() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Container(
  //         alignment: Alignment.centerLeft,
  //         decoration: BoxDecoration(
  //           color: Colors.purple,
  //           borderRadius: BorderRadius.circular(10.0),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black12,
  //               blurRadius: 6.0,
  //               offset: Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         height: 60,
  //         child: TextFormField(
  //             keyboardType: TextInputType.text,
  //             style: GoogleFonts.muli(
  //                 textStyle: TextStyle(
  //               color: Colors.white,
  //             )),
  //             onFieldSubmitted: (value) {
  //               FocusScope.of(context).requestFocus(focusAmount);
  //             },
  //             textInputAction: TextInputAction.next,
  //             onSaved: _handleSubmittedName,
  //             decoration: InputDecoration(
  //                 border: InputBorder.none,
  //                 contentPadding: EdgeInsets.only(top: 14),
  //                 prefixIcon: Icon(Icons.label, color: Colors.white),
  //                 hintText: 'Make it creative',
  //                 hintStyle: hintStyle)),
  //       )
  //     ],
  //   );
  // }

  // Widget _goalAmount() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Container(
  //         alignment: Alignment.centerLeft,
  //         decoration: BoxDecoration(
  //           color: Colors.purple,
  //           borderRadius: BorderRadius.circular(10.0),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black12,
  //               blurRadius: 6.0,
  //               offset: Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         height: 60,
  //         child: TextFormField(
  //             keyboardType: TextInputType.number,
  //             style: GoogleFonts.muli(
  //                 textStyle: TextStyle(
  //               color: Colors.white,
  //             )),
  //             onFieldSubmitted: (value) {
  //               FocusScope.of(context).unfocus();
  //             },
  //             onSaved: _handleSubmittedAmount,
  //             focusNode: focusAmount,
  //             decoration: InputDecoration(
  //                 border: InputBorder.none,
  //                 contentPadding: EdgeInsets.only(top: 14),
  //                 prefixIcon: Icon(Icons.label, color: Colors.white),
  //                 hintText: 'Make it realistic',
  //                 hintStyle: hintStyle)),
  //       )
  //     ],
  //   );
  // }

  // Widget _goalDateWidget() {
  //   return Container(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Finally, set a target date',
  //           style: GoogleFonts.muli(textStyle: TextStyle(color: Colors.white)),
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         Container(
  //           child: Row(
  //             children: [
  //               Expanded(
  //                   child: Container(
  //                 padding: EdgeInsets.all(10),
  //                 decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(12),
  //                     color: Color(0xFF73AEF5)),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     Text(
  //                       '$_dateDay',
  //                       style: GoogleFonts.muli(
  //                           textStyle: TextStyle(color: Colors.white)),
  //                     ),
  //                     Text(
  //                       '--',
  //                       style: GoogleFonts.muli(
  //                           textStyle: TextStyle(color: Colors.white)),
  //                     ),
  //                     Text(
  //                       '${monthNames[_dateMonth - 1]}',
  //                       style: GoogleFonts.muli(
  //                           textStyle: TextStyle(color: Colors.white)),
  //                     ),
  //                     Text(
  //                       '--',
  //                       style: GoogleFonts.muli(
  //                           textStyle: TextStyle(color: Colors.white)),
  //                     ),
  //                     Text(
  //                       '$_dateYear',
  //                       style: GoogleFonts.muli(
  //                           textStyle: TextStyle(color: Colors.white)),
  //                     ),
  //                   ],
  //                 ),
  //               )),
  //               IconButton(
  //                 icon: Icon(
  //                   Icons.calendar_today,
  //                   color: Colors.white,
  //                 ),
  //                 onPressed: () {
  //                   showDatePicker(
  //                     context: context,
  //                     initialDate: DateTime.now(),
  //                     firstDate: DateTime.now(),
  //                     lastDate: DateTime.now().add(Duration(days: 1000)),
  //                   ).then((value) {
  //                     setState(() {
  //                       if (value != null) {
  //                         _date = value;
  //                         _dateDay = _date.day.toString();
  //                         _dateMonth = _date.month;
  //                         _dateYear = _date.year.toString();
  //                       }
  //                     });
  //                   });
  //                 },
  //               )
  //             ],
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget _proceedBtn() {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: () {
          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) {
                return CupertinoActionSheet(
                  message: Text(
                    'You have set a target of XXXX KES by ${monthNames[_dateMonth - 1]} $_dateYear',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  actions: [
                    CupertinoActionSheetAction(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'SET GOAL',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple)),
                        ))
                  ],
                  cancelButton: CupertinoActionSheetAction(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      )),
                );
              });
        },
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.purple,
        child: Text(
          'PROCEED',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text(
          'Create a goal',
          style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            backgroundWidget(),
            Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let\'s start by choosing a category',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                      color: Colors.white,
                    )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _goalCategoryWidget(),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: PageView(
                        controller: _controllerMainPage,
                        physics: NeverScrollableScrollPhysics(),
                        onPageChanged: (value) {},
                        children: goalPages),
                  ),
                  _proceedBtn()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
