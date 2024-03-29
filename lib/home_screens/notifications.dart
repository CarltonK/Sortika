import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/utilities/styles.dart';

class NotificationsPage extends StatefulWidget {
  final String uid;
  NotificationsPage({@required this.uid});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsPage> {
  Helper _helper = new Helper();

  Widget noDocuments() {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.sentiment_neutral,
          size: 100,
          color: commonColor,
        ),
        Text(
          'You have not received any notifications',
          style: GoogleFonts.muli(
              textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ],
    ));
  }

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
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder<QuerySnapshot>(
                future: _helper.getUserNotification(widget.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.documents.length == 0) {
                      return noDocuments();
                    }
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data.documents[index];
                        String message = doc.data['message'];
                        Timestamp time = doc.data['time'];

                        //Date Parsing and Formatting
                        var formatter = new DateFormat('d MMM y HH:MM');
                        String date = formatter.format(time.toDate());

                        DateTime now = DateTime.now();
                        Timestamp dateRetrieved = time;
                        DateTime retrieved = dateRetrieved.toDate();

                        int timeDiff = now.difference(retrieved).inDays;
                        String elapsed;

                        if (timeDiff < 1) {
                          int hours = now.difference(retrieved).inHours;
                          if (hours < 1) {
                            int minutes = now.difference(retrieved).inMinutes;
                            elapsed = '$minutes minutes ago at ';
                          } else if (hours == 1) {
                            elapsed = '$hours hour ago at ';
                          } else {
                            elapsed = '$hours hours ago at ';
                          }
                        } else {
                          if (timeDiff == 1) {
                            elapsed = '$timeDiff day ago on ';
                          } else {
                            elapsed = '$timeDiff days ago on ';
                          }
                        }

                        return ListTile(
                          leading: Icon(
                            Icons.notifications,
                          ),
                          title: Text(
                            message,
                            style: GoogleFonts.muli(
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          subtitle: Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 8.0),
                            child: Text(
                              elapsed + date,
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(fontSize: 12)),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sentiment_neutral,
                          size: 100,
                          color: commonColor,
                        ),
                        Text(
                          'You have not received any notifications',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ],
                    ));
                  }
                  return SpinKitDoubleBounce(
                    color: commonColor,
                    size: MediaQuery.of(context).size.height * 0.25,
                  );
                },
              ),
            ),
            value: SystemUiOverlayStyle.light));
  }
}
