import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/home_screens/autoCreate.dart';
import 'package:wealth/utilities/styles.dart';

class AutoCreateHolder extends StatefulWidget {
  final String uid;
  AutoCreateHolder({@required this.uid});
  @override
  _AutoCreateHolderState createState() => _AutoCreateHolderState();
}

class _AutoCreateHolderState extends State<AutoCreateHolder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text(
          'Autocreate Goals',
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
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: AutoCreate(uid: widget.uid))
          ],
        ),
      ),
    );
    ;
  }
}
