import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/goal.dart';
import 'package:wealth/widgets/group_savings.dart';
import 'package:wealth/widgets/investment_goal.dart';
import 'package:wealth/widgets/savings_goal.dart';

class CreateGoal extends StatefulWidget {
  final String uid;
  CreateGoal({@required this.uid});
  @override
  _CreateGoalState createState() => _CreateGoalState();
}

class _CreateGoalState extends State<CreateGoal> {
  // Identifier
  int _currentPage = 0;

  //Goal Pages
  List<Widget> goalPages;

  PageController _controller;
  PageController _controllerMainPage;

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
          borderRadius: BorderRadius.circular(16),
          color: Colors.greenAccent[400]),
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
                  color: Colors.greenAccent[700])),
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

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
    _controllerMainPage = PageController(viewportFraction: 1);
    goalPages = [
      SavingsGoal(
        uid: widget.uid,
      ),
      InvestmentGoal(
        uid: widget.uid,
      ),
      GroupSavings(
        uid: widget.uid,
      )
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerMainPage.dispose();
    super.dispose();
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
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color(0xFF73AEF5),
                    Color(0xFF73AEF5),
                    Color(0xFF73AEF5),
                    Color(0xFF73AEF5),
                  ],
                      stops: [
                    0.1,
                    0.4,
                    0.7,
                    0.9
                  ])),
            ),
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
