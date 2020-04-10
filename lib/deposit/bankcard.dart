import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BankCard extends StatelessWidget {
  Widget _singleBankCard(context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/logos/visa.png',
              height: 30,
              width: 50,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '1234 5678 8765 4321',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      wordSpacing: 1)),
            ),
            SizedBox(
              height: 20,
            ),
            Row(children: [
              Expanded(
                child: Text('Jon Snow',
                    style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black),
                    )),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Valid',
                      style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.black, fontSize: 12),
                      )),
                  Text('02/22',
                      style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.black, fontSize: 10),
                      ))
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CVV',
                      style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.black, fontSize: 12),
                      )),
                  Text('XXX',
                      style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.black, fontSize: 10),
                      ))
                ],
              )
            ])
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('Saved Cards',
                  style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.white),
                  )),
              RaisedButton(
                color: Colors.greenAccent[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                onPressed: () {},
                child: Row(
                  children: [
                    Text('Add',
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.white),
                        )),
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          _singleBankCard(context)
        ],
      ),
    );
    ;
  }
}
