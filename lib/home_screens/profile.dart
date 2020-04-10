import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime _date;
  String _dateDay = '04';
  int _dateMonth = 7;
  String _dateYear = '2020';

  //Month Names
  List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  //Toggle Selections
  List<bool> _isSelected = [false, false];

  Widget _nameWidget() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Name',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: TextFormField(
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                        decoration: InputDecoration(
                          hintText: 'Jon',
                          hintStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ))
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Name',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: TextFormField(
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                        decoration: InputDecoration(
                          hintText: 'Snow',
                          hintStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _nameKinWidget() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Name',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: TextFormField(
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                        decoration: InputDecoration(
                          hintText: 'Sansa',
                          hintStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ))
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Name',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: TextFormField(
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                        decoration: InputDecoration(
                          hintText: 'Stark',
                          hintStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _phoneWidget() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Number',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: TextFormField(
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '07xxxxxxxx',
                          hintStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneKinWidget() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Number',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: TextFormField(
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '07xxxxxxxx',
                          hintStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _natIdWidget() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'National ID',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: TextFormField(
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Passport number is valid',
                          hintStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _natIdKinWidget() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'National ID',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: TextFormField(
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Passport number is valid',
                          hintStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateOfBirthWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date of Birth',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '$_dateDay',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        '--',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        '${monthNames[_dateMonth - 1]}',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        '--',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        '$_dateYear',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )),
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 1000)),
                    ).then((value) {
                      setState(() {
                        if (value != null) {
                          _date = value;
                          _dateDay = _date.day.toString();
                          _dateMonth = _date.month;
                          _dateYear = _date.year.toString();
                        }
                      });
                    });
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _genderWidget() {
    return Container(
      child: Row(
        children: [
          Center(
            child: Text(
              'Gender',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          SizedBox(
            width: 30,
          ),
          ToggleButtons(
              selectedColor: Colors.white,
              color: Colors.greenAccent[400],
              borderColor: Colors.transparent,
              selectedBorderColor: Colors.white,
              onPressed: (int value) {
                setState(() {
                  _isSelected[value] = !_isSelected[value];
                });
              },
              children: [
                Icon(FontAwesome.male, size: 40),
                Icon(FontAwesome.female, size: 40),
              ],
              isSelected: _isSelected)
        ],
      ),
    );
  }

  Widget _backgroundWidget() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFF73AEF5),
            Color(0xFF61A4F1),
            Color(0xFF478DE0),
            Color(0xFF398AE5),
          ],
              stops: [
            0.1,
            0.4,
            0.7,
            0.9
          ])),
    );
  }

  Widget _updateBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: () {},
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'UPDATE',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
            letterSpacing: 1.5,
            color: Colors.black,
            fontSize: 20,
          )),
        ),
      ),
    );
  }

  Widget _userDp() {
    return Center(
      child: Container(
        height: 140,
        width: 140,
        child: Stack(
          children: <Widget>[
            CircleAvatar(
              radius: 70,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: 0.4,
                child: Card(
                  elevation: 20,
                  shadowColor: Colors.blue[300],
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.blue,
                    onTap: () {},
                    child: Container(
                      child: Icon(Icons.add_a_photo, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _documentsUpload() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Documents',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          Text(
            'A quick snap or a picture in your gallery will do',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.normal)),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ID/PASSPORT',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(12)),
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 150,
                      child: Center(
                        child: IconButton(
                          icon: Icon(Icons.add_a_photo, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'KRA PIN',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(12)),
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 150,
                      child: Center(
                        child: IconButton(
                          icon: Icon(Icons.add_a_photo, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _kinSectionWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next of Kin',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          Text(
            'Some classes of investments require this information',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.normal)),
          ),
          SizedBox(
            height: 10,
          ),
          _nameKinWidget(),
          SizedBox(
            height: 30,
          ),
          _phoneKinWidget(),
          SizedBox(
            height: 30,
          ),
          _natIdKinWidget()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text(
          'My Account',
          style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              _backgroundWidget(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _userDp(),
                      SizedBox(
                        height: 30,
                      ),
                      _nameWidget(),
                      SizedBox(
                        height: 30,
                      ),
                      _phoneWidget(),
                      SizedBox(
                        height: 30,
                      ),
                      _natIdWidget(),
                      SizedBox(
                        height: 30,
                      ),
                      _dateOfBirthWidget(),
                      SizedBox(
                        height: 30,
                      ),
                      _genderWidget(),
                      SizedBox(
                        height: 30,
                      ),
                      _documentsUpload(),
                      SizedBox(
                        height: 30,
                      ),
                      _kinSectionWidget(),
                      _updateBtn()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
