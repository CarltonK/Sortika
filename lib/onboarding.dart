import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  //PageView Controller
  final PageController _pageController = PageController(initialPage: 0);
  //Define number of screens
  final int _numPages = 4;
  //Placeholder for current page
  int _currentPage = 0;

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    if (_seen) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      await prefs.setBool('seen', true);
    }
  }

  TextStyle _titleStyle() {
    return GoogleFonts.muli(
        textStyle: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold));
  }

  TextStyle _subtitleStyle() {
    return GoogleFonts.muli(
        textStyle: TextStyle(color: Colors.white, fontSize: 19));
  }

  //Image Urls
  //https://www.pinclipart.com/picdir/big/126-1268588_more-money-cliparts-25-buy-clip-art-save.png
  //https://i.dlpng.com/static/png/6859105_preview.png
  // String _pageOneImage =
  //     'https://gopeer.ca/wp-content/uploads/2019/10/Peer-to-peer-lending.png';
  // String _pageTwoImage =
  //     'https://openltv.com/wp-content/uploads/2019/04/invest-tree-800x400.png';
  // String _pageThreeImage =
  //     'https://www.pinclipart.com/picdir/big/126-1268588_more-money-cliparts-25-buy-clip-art-save.png';
  // String _pageFourImage =
  //     'https://cdn.shortpixel.ai/client/q_glossy,ret_img,w_649/https://chamasoft.com/wp-content/uploads/2020/02/group-concept-1.png';

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

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

  @override
  void initState() {
    super.initState();
    checkFirstSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                0.1,
                0.4,
                0.7,
                0.9
              ],
                  colors: [
                Color(0xFF73AEF5),
                Color(0xFF61A4F1),
                Color(0xFF478DE0),
                Color(0xFF398AE5),
              ])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 30),
                child: FlatButton(
                    onPressed: () {
                      setState(() {
                        _pageController.animateToPage(4,
                            duration: Duration(milliseconds: 3),
                            curve: Curves.ease);
                      });
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
                          height: 5,
                        ),
                        Text(
                          'You can Borrow from as low as 1%',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Place and price your loan request to thousands of lenders on Sortika and get an instant reply',
                          textAlign: TextAlign.center,
                          style: _subtitleStyle(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Image(
                            fit: BoxFit.fitHeight,
                            image: AssetImage('assets/images/invest.png'),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Invest in tens of investment asset classes',
                          textAlign: TextAlign.center,
                          style: _titleStyle(),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Create an investment portfolio that meets your return expectation and risk profile',
                          textAlign: TextAlign.center,
                          style: _subtitleStyle(),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Image(
                            fit: BoxFit.fitHeight,
                            image: AssetImage('assets/images/save.png'),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'You can create customized savings goals',
                          textAlign: TextAlign.center,
                          style: _titleStyle(),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Create your financial goals and we ensure you meet each and every one of them',
                          textAlign: TextAlign.center,
                          style: _subtitleStyle(),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Image(
                            fit: BoxFit.fitHeight,
                            image: AssetImage('assets/images/group.png'),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Create a savings group and invite friends to contribute',
                          textAlign: TextAlign.center,
                          style: _titleStyle(),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Your chama can now save remotely and ensure that members meet their targets',
                          textAlign: TextAlign.center,
                          style: _subtitleStyle(),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
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
                            padding: const EdgeInsets.only(bottom: 20, top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Next',
                                    style: GoogleFonts.muli(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600))),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(CupertinoIcons.forward,
                                    color: Colors.white)
                              ],
                            ),
                          )),
                    ))
                  : Text('')
            ],
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? Container(
              height: 70,
              width: double.infinity,
              color: Color(0xFF398AE5),
              child: GestureDetector(
                onTap: () {
                  //Go to Login Page
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Center(
                  child: Text(
                    'Get started'.toUpperCase(),
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          : Text(''),
    );
  }
}
