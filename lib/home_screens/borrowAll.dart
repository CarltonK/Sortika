import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';
import 'package:wealth/widgets/borrow_page.dart';

class BorrowAll extends StatefulWidget {
  @override
  _BorrowAllState createState() => _BorrowAllState();
}

class _BorrowAllState extends State<BorrowAll> {
  static String uid;
  static String token;
  static String name;
  static String phone;
  @override
  Widget build(BuildContext context) {
    //Retrieve uid
    Map<String, dynamic> userData = ModalRoute.of(context).settings.arguments;
    uid = userData['uid'];
    token = userData['token'];
    name = userData["name"];
    phone = userData["phone"];
    //print('Borrow Page Uid: $uid');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text(
          'Borrow',
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
                child: BorrowPage(
                  uid: uid,
                  mytoken: token,
                  phone: phone,
                  name: name,
                ))
          ],
        ),
      ),
    );
  }
}
