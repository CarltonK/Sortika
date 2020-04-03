import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class AchievePreference extends StatefulWidget {
  @override
  _AchievePreferenceState createState() => _AchievePreferenceState();
}

class _AchievePreferenceState extends State<AchievePreference> {
  //PageView Controller
  final PageController _pageController = PageController(initialPage: 0);
  //Define number of screens
  final int _numPages = 3;
  //Placeholder for current page
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  //Color Changer
  Color color = Colors.blue;

  //Page Indicator i.e Slider
  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: 8,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
          color: isActive ? Colors.white : Color(0xFF73AEF5),
          borderRadius: BorderRadius.circular(12)),
    );
  }


  TextStyle _subtitleStyle() {
    return GoogleFonts.muli(
        textStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
        letterSpacing: 0.5));
  }

  //Final Dropdown item
  String goal;

  //Define Dropdown Menu Items
  List<DropdownMenuItem> items = [
    DropdownMenuItem(
      value: 'Borrow Money',
      child: Text(
        'Borrow Money',
        style: GoogleFonts.muli(
            textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'Save Money',
      child: Text(
        'Save Money',
        style: GoogleFonts.muli(
            textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'Invest Money',
      child: Text(
        'Invest Money',
        style: GoogleFonts.muli(
            textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'Group Savings',
      child: Text(
        'Group Savings',
        style: GoogleFonts.muli(
            textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600)),
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: double.infinity,
              width: double.infinity,
              color: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(top: 30),
                    child: FlatButton(
                        onPressed: () {
                          print('I want to skip and go home page');
                        },
                        child: Text(
                          'Skip',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600)),
                        )),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    padding: EdgeInsets.all(40),
                    child: PageView(
                      physics: ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Image(
                                fit: BoxFit.fitHeight,
                                image: AssetImage('assets/images/borrow.png'),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Tell us what you want to achieve with Sortika',
                              textAlign: TextAlign.center,
                              style: _subtitleStyle(),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              height: 60,
                              child: DropdownButton(
                                  items: items,
                                  underline: Divider(
                                    color: Colors.transparent,
                                  ),
                                  value: goal,
                                  hint: Text(
                                    'Goal',
                                    style: GoogleFonts.muli(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  icon: Icon(CupertinoIcons.down_arrow, color: Colors.black,),
                                  isExpanded: true,
                                  onChanged: (value) {
                                    setState(() {
                                      goal = value;
                                      if (value == 'Borrow Money') {
                                        color = Colors.brown;
                                      }
                                      if (value == 'Save Money') {
                                        color = Colors.green;
                                      }
                                      if (value == 'Invest Money') {
                                        color = Colors.red[600];
                                      }
                                      if (value == 'Group Savings') {
                                        color = Colors.purple;
                                      }
                                    });
                                    print(goal);
                                  },),
                            )
                          ],
                        ),
                        Column(),
                        Column()],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                  Row(
                    children: <Widget>[
                      _currentPage + 3 != _numPages
                          ? Expanded(
                              child: Align(
                              alignment: FractionalOffset.bottomLeft,
                              child: FlatButton(
                                  onPressed: () {
                                    _pageController.previousPage(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 20, top: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(CupertinoIcons.back,
                                            color: Colors.white),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('Back',
                                            style: GoogleFonts.muli(
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600))),
                                      ],
                                    ),
                                  )),
                            ))
                          : Text(''),
                      _currentPage != _numPages - 1
                          ? Expanded(
                              child: Align(
                              alignment: FractionalOffset.bottomRight,
                              child: FlatButton(
                                  onPressed: () {
                                    _pageController.nextPage(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 20, top: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text('Next',
                                            style: GoogleFonts.muli(
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600))),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(CupertinoIcons.forward,
                                            color: Colors.white)
                                      ],
                                    ),
                                  )),
                            ))
                          : Text(''),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}