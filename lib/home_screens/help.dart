import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatelessWidget {
  final Future<PackageInfo> future;
  Help({@required this.future});

  Widget _helpItem(
      IconData data, String title, String subtitle, GestureTapCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(data),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('$title',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18))),
                    Text('$subtitle',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(fontSize: 12))),
                  ],
                )
              ],
            ),
            Icon(CupertinoIcons.forward)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String version;
    future.then((value) {
      version = value.version;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text(
          'Help',
          style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.white, fontSize: 20)),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => showAboutDialog(
                  context: context,
                applicationVersion: version,
                applicationIcon: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.asset('assets/logos/app.png'),
                ),
                children: [
                  Image.network(
                      'https://images.unsplash.com/photo-1559067096-49ebca3406aa?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1489&q=80',
                    fit: BoxFit.cover,
                  )
                ]
              ),
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            _helpItem(AntDesign.question, 'FAQ', 'Frequently Asked Questions',
                () async {
              //Launch this url
              final String faqUrl =
                  'http://www.sortika.com/wordpress/frequently-asked-questions/';

              if (await canLaunch(faqUrl)) {
                await launch(faqUrl);
              } else {
                throw 'Could not launch $faqUrl';
              }
            }),
            _helpItem(FontAwesome.whatsapp, 'Contact Us', 'Reach out to us',
                () async {
              //Send Whatsapp Message
              try {
                //Launch whatsapp with no message
                FlutterOpenWhatsapp.sendSingleMessage("254705599442", "");
              } catch (e) {
                print('This is the exception $e');
              }
            }),
            _helpItem(FontAwesome.legal, 'Legal', 'Terms and Conditions',
                () async {
              //Launch this Url
              final String termsUrl =
                  'http://www.sortika.com/wordpress/terms-and-conditions/';

              if (await canLaunch(termsUrl)) {
                await launch(termsUrl);
              } else {
                throw 'Could not launch $termsUrl';
              }
            }),
//            _helpItem(Feather.info, 'Goal Descriptions',
//                'A walkthrough of Sortika', () {})
          ],
        ),
      ),
      floatingActionButton: MaterialButton(
        color: Colors.grey[200],
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Developer',
                  style: GoogleFonts.muli(textStyle: TextStyle())),
              SizedBox(
                width: 5,
              ),
              Icon(FontAwesome.whatsapp, size: 14, color: Colors.green)
            ],
          ),
        ),
        onPressed: () {
          try {
            //Launch whatsapp with no message
            FlutterOpenWhatsapp.sendSingleMessage(
                "254727286123", "Hello. I would like to have an app developed for me");
          } catch (e) {
            print('This is the exception $e');
          }
        },
      ),
    );
  }
}
