import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/errorMessage.dart';
import 'package:wealth/global/progressDialog.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/utilities/rateArc.dart';
import 'package:wealth/utilities/smile.dart';
import 'package:wealth/models/reviewModel.dart';

class Rate extends StatefulWidget {
  final String uid;
  Rate({@required this.uid});
  @override
  _RateState createState() => _RateState();
}

class _RateState extends State<Rate> with TickerProviderStateMixin {
  final PageController pageControl = new PageController(
    initialPage: 2,
    keepPage: false,
    viewportFraction: 0.2,
  );

  int slideValue = 200;
  int lastAnimPosition = 2;

  AnimationController animation;

  List<ArcItem> arcItems = List<ArcItem>();

  ArcItem badArcItem;
  ArcItem ughArcItem;
  ArcItem okArcItem;
  ArcItem goodArcItem;

  Color startColor;
  Color endColor;

  String title;
  String review;

  Helper helper = new Helper();

  @override
  void initState() {
    super.initState();

    badArcItem = ArcItem("BAD", [Color(0xFFfe0944), Color(0xFFfeae96)], 0.0);
    ughArcItem = ArcItem("UGH", [Color(0xFFF9D976), Color(0xfff39f86)], 0.0);
    okArcItem = ArcItem("OK", [Color(0xFF21e1fa), Color(0xff3bb8fd)], 0.0);
    goodArcItem = ArcItem("GOOD", [Color(0xFF3ee98a), Color(0xFF41f7c7)], 0.0);

    arcItems.add(badArcItem);
    arcItems.add(ughArcItem);
    arcItems.add(okArcItem);
    arcItems.add(goodArcItem);

    startColor = Color(0xFF21e1fa);
    endColor = Color(0xff3bb8fd);

    animation = new AnimationController(
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 400.0,
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(() {
        setState(() {
          slideValue = animation.value.toInt();

          double ratio;

          if (slideValue <= 100) {
            ratio = animation.value / 100;
            startColor =
                Color.lerp(badArcItem.colors[0], ughArcItem.colors[0], ratio);
            endColor =
                Color.lerp(badArcItem.colors[1], ughArcItem.colors[1], ratio);
          } else if (slideValue <= 200) {
            ratio = (animation.value - 100) / 100;
            startColor =
                Color.lerp(ughArcItem.colors[0], okArcItem.colors[0], ratio);
            endColor =
                Color.lerp(ughArcItem.colors[1], okArcItem.colors[1], ratio);
          } else if (slideValue <= 300) {
            ratio = (animation.value - 200) / 100;
            startColor =
                Color.lerp(okArcItem.colors[0], goodArcItem.colors[0], ratio);
            endColor =
                Color.lerp(okArcItem.colors[1], goodArcItem.colors[1], ratio);
          } else if (slideValue <= 400) {
            ratio = (animation.value - 300) / 100;
            startColor =
                Color.lerp(goodArcItem.colors[0], badArcItem.colors[0], ratio);
            endColor =
                Color.lerp(goodArcItem.colors[1], badArcItem.colors[1], ratio);
          }
        });
      });

    animation.animateTo(slideValue.toDouble());
  }

  void submitBtnPressed(String text) {
    //print(text);
    //Show a Progress Dialog
    showCupertinoModalPopup(
      context: context,
      builder: (context) =>
          CustomProgressDialog(message: 'Sending your review...'),
    );
    if (text == 'OK') {
      title = 'OK';
      review = "It is okay. I can live with it";
    }
    if (text == 'GOOD') {
      title = 'GOOD';
      review = "I am satisfied i made the right choice. I like it";
    }
    if (text == 'BAD') {
      title = 'BAD';
      review = "I do not like it. I will uninstall immediately";
    }
    if (text == 'UGH') {
      title = 'UGH';
      review = "I am not satisfied. Please do something about it";
    }

    ReviewModel model =
        new ReviewModel(title: title, review: review, uid: widget.uid);

    helper.createReview(model).catchError((error) {
      //Pop the dialog
      Navigator.of(context).pop();
      //Show the error message after a second
      Timer(Duration(seconds: 1), () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => ErrorMessage(
              message:
                  'There was an error sending your review. This is the error: $error'),
        );
      });
    }).then((value) {
      //Pop the dialog
      Navigator.of(context).pop();
      //Show a success message after a second
      Timer(Duration(seconds: 1), () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) =>
              SuccessMessage(message: 'Thank you for your review'),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text(
          'How was your experience on Sortika ?',
          style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(children: [
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 20,
          ),
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                (MediaQuery.of(context).size.width / 2) + 60),
            painter: SmilePainter(slideValue),
          ),
          Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: <Widget>[
                ArcChooser()
                  ..arcSelectedCallback = (int pos, ArcItem item) {
                    int animPosition = pos - 2;
                    if (animPosition > 3) {
                      animPosition = animPosition - 4;
                    }

                    if (animPosition < 0) {
                      animPosition = 4 + animPosition;
                    }

                    if (lastAnimPosition == 3 && animPosition == 0) {
                      animation.animateTo(4 * 100.0);
                    } else if (lastAnimPosition == 0 && animPosition == 3) {
                      animation.forward(from: 4 * 100.0);
                      animation.animateTo(animPosition * 100.0);
                    } else if (lastAnimPosition == 0 && animPosition == 1) {
                      animation.forward(from: 0.0);
                      animation.animateTo(animPosition * 100.0);
                    } else {
                      animation.animateTo(animPosition * 100.0);
                    }

                    lastAnimPosition = animPosition;
                  },
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: () =>
                        submitBtnPressed(arcItems[lastAnimPosition].text),
                    child: Material(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)),
                        elevation: 8.0,
                        child: Container(
                          width: 150.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [startColor, endColor]),
                              borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text(
                            'SUBMIT',
                            style: GoogleFonts.muli(
                                textStyle: TextStyle(
                              color: Colors.white,
                            )),
                          ),
                        )),
                  ),
                ),
              ])
        ]),
      ),
    );
  }
}
