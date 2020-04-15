import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: commonColor,
          title: Text('Notifications',
              style: GoogleFonts.muli(textStyle: TextStyle())),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpansionTile(
                      leading: Icon(
                        Icons.trending_up,
                      ),
                      title: Text(
                        'Income',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      subtitle: Text(
                        'Apr 12, 2020',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(fontSize: 12)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            value: SystemUiOverlayStyle.light));
  }
}
