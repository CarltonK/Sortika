import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:wealth/utilities/styles.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Helper helper = Helper();
  //Form Key
  final _formKey = GlobalKey<FormState>();

  DateTime _date;
  String _dateDay = '04';
  int _dateMonth = 7;
  String _dateYear = '2020';

  String filePath, urlResult;
  String _natId;

  String _nameKin, _phoneKin, _idKin;
  String _gender;

  final focusPhoneKin = FocusNode();
  final focusIdKin = FocusNode();

  static String uid;
  User user;

  final Firestore _firestore = Firestore.instance;
  Future<DocumentSnapshot> userData;

  StorageUploadTask storageUploadTask;
  StorageTaskSnapshot taskSnapshot;

  /// Active image file
  File _imageFile;
  File _idFile;
  File _kraFile;
  File _kinImageFile;
  File _kinIDFile;
  File _kinKraFile;

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

  @override
  void dispose() {
    super.dispose();
    focusPhoneKin.dispose();
    focusIdKin.dispose();
  }

  //Handle Phone Input
  void _handleSubmittedID(String value) {
    _natId = value.trim();
    print('ID: ' + _natId);
  }

  //Handle Phone Input
  void _handleSubmittedNameKin(String value) {
    _nameKin = value.trim();
    print('Name Kin: ' + _nameKin);
  }

//Handle Phone Input
  void _handleSubmittedPhoneKin(String value) {
    _phoneKin = value.trim();
    print('Phone Kin: ' + _phoneKin);
  }

//Handle Phone Input
  void _handleSubmittedIdKin(String value) {
    _idKin = value.trim();
    print('ID Kin: ' + _idKin);
  }

  Widget _nameWidget() {
    //Retrieve the fullName
    String fullName = user.fullName;
    //Split by the whitespace to form a list of strings
    List<String> names = fullName.split(' ');
    //First name is index 0
    String fname = names[0];
    //Iterate through the list to get the rest of the names
    String otherNames = '';
    for (int i = 1; i < names.length; i++) {
      otherNames = otherNames + names[i] + ' ';
    }

    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Name',
                    style: labelStyle,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          hintText: '$fname',
                          hintStyle: hintStyle))
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Other Name(s)',
                    style: labelStyle,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          hintText: '$otherNames',
                          hintStyle: hintStyle))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  //Full Names Widget
  Widget _nameKinWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Full Name',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        user.kinName == null
            ? TextFormField(
                autofocus: false,
                keyboardType: TextInputType.text,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.white,
                )),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(focusPhoneKin);
                },
                validator: (value) {
                  //Check if full name is available
                  if (value.isEmpty) {
                    return 'Full Name is required';
                  }

                  //Check if a space is available
                  if (!value.contains(' ')) {
                    return 'Please separate your individual names with a space';
                  }

                  return null;
                },
                textInputAction: TextInputAction.next,
                onSaved: _handleSubmittedNameKin,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red[900])),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    labelText: 'Enter their Full Name',
                    labelStyle: hintStyle))
            : TextFormField(
                enabled: false,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.white,
                )),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    hintText: '${user.kinName}',
                    hintStyle: hintStyle))
      ],
    );
  }

  Widget _phoneWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: labelStyle,
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                        hintText: '${user.phone}',
                        hintStyle: hintStyle))
              ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: labelStyle,
                ),
                SizedBox(
                  height: 10,
                ),
                user.kinPhone == null
                    ? TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                          color: Colors.white,
                        )),
                        focusNode: focusPhoneKin,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(focusIdKin);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Phone Number is required';
                          }
                          if (!value.startsWith('07')) {
                            return 'Phone number should start with 07';
                          }
                          if (value.length != 10) {
                            return 'Phone number should be 10 digits';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onSaved: _handleSubmittedPhoneKin,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red[900])),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            prefixIcon: Icon(Icons.phone, color: Colors.white),
                            labelText: 'Enter their Phone Number',
                            labelStyle: hintStyle))
                    : TextFormField(
                        enabled: false,
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                          color: Colors.white,
                        )),
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            prefixIcon: Icon(Icons.person, color: Colors.white),
                            hintText: '${user.kinPhone}',
                            hintStyle: hintStyle))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _natIdWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'National ID',
            style: labelStyle,
          ),
          SizedBox(
            height: 10,
          ),
          user.natId == null
              ? TextFormField(
                  autofocus: false,
                  enabled: user.natId == null ? true : false,
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                    color: Colors.white,
                  )),
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'ID/Passport Number is required';
                    }

                    if (value.length < 7) {
                      return 'ID/Passport number should be 7 or more digits';
                    }

                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onSaved: _handleSubmittedID,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[900])),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      labelText: 'Enter your ID / Passport Number',
                      labelStyle: hintStyle))
              : TextFormField(
                  enabled: false,
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                    color: Colors.white,
                  )),
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      hintText: '${user.natId}',
                      hintStyle: hintStyle))
        ],
      ),
    );
  }

  Widget _natIdKinWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'National ID',
            style: labelStyle,
          ),
          SizedBox(
            height: 10,
          ),
          user.kinID == null
              ? TextFormField(
                  autofocus: false,
                  focusNode: focusIdKin,
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                    color: Colors.white,
                  )),
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: (value) {
                    //Check if value is empty
                    if (value.isEmpty) {
                      return 'ID/Passport Number is required';
                    }

                    //Check if @ is in email
                    if (value.length < 7) {
                      return 'ID/Passport number should be 7 or more digits';
                    }

                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onSaved: _handleSubmittedIdKin,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[900])),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      labelText: 'Enter their ID / Passport Number',
                      labelStyle: hintStyle))
              : TextFormField(
                  enabled: false,
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                    color: Colors.white,
                  )),
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      hintText: '${user.kinID}',
                      hintStyle: hintStyle))
        ],
      ),
    );
  }

  Widget _dateOfBirthWidget() {
    if (user.dob != null) {
      //Retrieve the date
      Timestamp retrievedDate = user.dob;
      //Convert to datetime
      DateTime convertedDate = retrievedDate.toDate();
      _date = convertedDate;
      _dateDay = _date.day.toString();
      _dateMonth = _date.month;
      _dateYear = _date.year.toString();
    }

    return Container(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date of Birth',
              style: labelStyle,
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
                        firstDate:
                            DateTime.now().subtract(Duration(days: 22000)),
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

  Future _promptUser(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(
              '$message',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(color: Colors.black, fontSize: 16)),
            ),
          );
        });
  }

  Future _promptUserSuccess(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.done,
                  size: 100,
                  color: Colors.green,
                ),
                Text(
                  '$message',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  Future _showUserProgress(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$message...',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                SpinKitDualRing(
                  color: Colors.greenAccent[700],
                  size: 100,
                )
              ],
            ),
          );
        });
  }

  List<DropdownMenuItem> itemsGenders = [
    DropdownMenuItem(
      value: 'male',
      child: Text(
        'Male',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'female',
      child: Text(
        'Female',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  Widget _genderWidget() {
    if (user.gender != null) {
      _gender = user.gender;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your Gender',
          style: GoogleFonts.muli(
              textStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          height: 10,
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
          child: DropdownButton(
            items: itemsGenders,
            underline: Divider(
              color: Colors.transparent,
            ),
            value: _gender,
            hint: Text(
              user.gender == null ? 'Select your Gender' : '${user.gender}',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
            ),
            icon: Icon(
              CupertinoIcons.down_arrow,
              color: Colors.black,
            ),
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                _gender = value;
                //print(_gender);
              });
            },
          ),
        ),
      ],
    );
  }

  Future _updateUserProfile(Map user) async {
    final String _collectionUpper = 'users';
    var document = _firestore.collection(_collectionUpper).document(uid);
    await document.updateData(user);
  }

  void _updateProfile() {
    if (_date == null) {
      _promptUser("Please select your date of birth");
    } else if (_gender == null) {
      _promptUser("Please select your gender");
    } else {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();

        //Assign to a USER
        Map<String, dynamic> updatedUser = {
          "natId": _natId,
          "dob": Timestamp.fromDate(_date),
          "gender": _gender,
          "kinName": _nameKin,
          "kinPhone": _phoneKin,
          "kinID": _idKin
        };

        //Show a dialog
        _showUserProgress("Updating your profile");

        _updateUserProfile(updatedUser).whenComplete(() {
          //Pop that dialog
          //Show a success message for two seconds
          Timer(Duration(seconds: 2), () => Navigator.of(context).pop());

          //Show a success message for two seconds
          Timer(
              Duration(seconds: 3),
              () => _promptUserSuccess(
                  "Your profile has been updated successfully"));

          //Show a success message for two seconds
          Timer(Duration(seconds: 4), () => Navigator.of(context).pop());
        }).catchError((error) {
          _promptUser(error);
        });
      }
    }
  }

  Widget _updateBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: user.gender == null ? _updateProfile : null,
        padding: EdgeInsets.all(15),
        disabledColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'UPDATE',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  letterSpacing: 1.5,
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  /// Starts an upload task
  Future<String> _startUpload(File file) async {
    /// Unique file name for the file
    filePath = 'profiles/$uid/displayPic.png';
    //Create a storage reference
    StorageReference reference = FirebaseStorage.instance.ref().child(filePath);
    //Create a task that will handle the upload
    storageUploadTask = reference.putFile(
      file,
    );
    taskSnapshot = await storageUploadTask.onComplete;

    urlResult = await taskSnapshot.ref.getDownloadURL();
    //print('URL is $urlResult');
    return urlResult;
  }

  Future<String> _startIDUpload(File file) async {
    /// Unique file name for the file
    filePath = 'profiles/$uid/natID.png';
    //Create a storage reference
    StorageReference reference = FirebaseStorage.instance.ref().child(filePath);
    //Create a task that will handle the upload
    storageUploadTask = reference.putFile(
      file,
    );
    taskSnapshot = await storageUploadTask.onComplete;

    urlResult = await taskSnapshot.ref.getDownloadURL();
    //print('URL is $urlResult');
    return urlResult;
  }

  Future<String> _startKRAUpload(File file) async {
    /// Unique file name for the file
    filePath = 'profiles/$uid/KRA.png';
    //Create a storage reference
    StorageReference reference = FirebaseStorage.instance.ref().child(filePath);
    //Create a task that will handle the upload
    storageUploadTask = reference.putFile(
      file,
    );
    taskSnapshot = await storageUploadTask.onComplete;

    urlResult = await taskSnapshot.ref.getDownloadURL();
    //print('URL is $urlResult');
    return urlResult;
  }

  /// Starts an upload task
  Future<String> _startUploadKinImage(File file) async {
    /// Unique file name for the file
    filePath = 'profiles/$uid/kin/displayPic.png';
    //Create a storage reference
    StorageReference reference = FirebaseStorage.instance.ref().child(filePath);
    //Create a task that will handle the upload
    storageUploadTask = reference.putFile(
      file,
    );
    taskSnapshot = await storageUploadTask.onComplete;

    urlResult = await taskSnapshot.ref.getDownloadURL();
    //print('URL is $urlResult');
    return urlResult;
  }

  /// Starts an upload task
  Future<String> _startUploadKinID(File file) async {
    /// Unique file name for the file
    filePath = 'profiles/$uid/kin/displayPic.png';
    //Create a storage reference
    StorageReference reference = FirebaseStorage.instance.ref().child(filePath);
    //Create a task that will handle the upload
    storageUploadTask = reference.putFile(
      file,
    );
    taskSnapshot = await storageUploadTask.onComplete;

    urlResult = await taskSnapshot.ref.getDownloadURL();
    //print('URL is $urlResult');
    return urlResult;
  }

  /// Starts an upload task
  Future<String> _startUploadKinKra(File file) async {
    /// Unique file name for the file
    filePath = 'profiles/$uid/kin/displayPic.png';
    //Create a storage reference
    StorageReference reference = FirebaseStorage.instance.ref().child(filePath);
    //Create a task that will handle the upload
    storageUploadTask = reference.putFile(
      file,
    );
    taskSnapshot = await storageUploadTask.onComplete;

    urlResult = await taskSnapshot.ref.getDownloadURL();
    //print('URL is $urlResult');
    return urlResult;
  }

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    await ImagePicker.pickImage(source: source).then((value) {
      if (value != null) {
        setState(() {
          _imageFile = value;
        });
        _changePic();
      }
    });
  }

  Future<void> _pickIdDocuments(ImageSource source) async {
    await ImagePicker.pickImage(source: source).then((value) {
      if (value != null) {
        setState(() {
          _idFile = value;
        });
        _setNatIdPic();
      }
    });
  }

  Future<void> _pickKraDocuments(ImageSource source) async {
    await ImagePicker.pickImage(source: source).then((value) {
      if (value != null) {
        setState(() {
          _kraFile = value;
        });
        _setKraDocPic();
      }
    });
  }

  Future<void> _pickKinImage(ImageSource source) async {
    await ImagePicker.pickImage(source: source).then((value) {
      if (value != null) {
        setState(() {
          _kinImageFile = value;
        });
        _setKinImagePic();
      }
    });
  }

  Future<void> _pickKinId(ImageSource source) async {
    await ImagePicker.pickImage(source: source).then((value) {
      if (value != null) {
        setState(() {
          _kinIDFile = value;
        });
        _setKinIdFile();
      }
    });
  }

  Future<void> _pickKinKra(ImageSource source) async {
    await ImagePicker.pickImage(source: source).then((value) {
      if (value != null) {
        setState(() {
          _kinKraFile = value;
        });
        _setKinKraFile();
      }
    });
  }

  Future _changePic() async {
    //Action sheet to show upload status
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              'Updating your profile picture',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            message: SpinKitDualRing(
              color: Colors.red,
              size: 50,
            ),
          );
        });

    //Try save credentials using shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _startUpload(_imageFile).then((value) {
      //Change value in firebase users collection

      Firestore.instance
          .collection("users")
          .document(uid)
          .updateData({"photoURL": value});

      prefs.setString('dp', value);
    }).whenComplete(() {
      Navigator.of(context).pop();
      //Show a success message
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: Text(
                'Your profile picture has been updated',
                style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                )),
              ),
            );
          });
    });
  }

  Future _setNatIdPic() async {
    //Action sheet to show upload status
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              'Updating your identity document picture',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            message: SpinKitDualRing(
              color: Colors.red,
              size: 50,
            ),
          );
        });

    _startIDUpload(_idFile).then((value) {
      //Change value in firebase users collection

      Firestore.instance
          .collection("users")
          .document(uid)
          .updateData({"natIDURL": value});
    }).whenComplete(() {
      Navigator.of(context).pop();
      //Show a success message
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: Text(
                'Your profile has been updated',
                style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                )),
              ),
            );
          });
    });
  }

  Future _setKraDocPic() async {
    //Action sheet to show upload status
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              'Updating your KRA document picture',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            message: SpinKitDualRing(
              color: Colors.red,
              size: 50,
            ),
          );
        });

    _startKRAUpload(_kraFile).then((value) {
      //Change value in firebase users collection

      Firestore.instance
          .collection("users")
          .document(uid)
          .updateData({"kraURL": value});
    }).whenComplete(() {
      Navigator.of(context).pop();
      //Show a success message
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: Text(
                'Your profile has been updated',
                style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                )),
              ),
            );
          });
    });
  }

  Future _setKinImagePic() async {
    //Action sheet to show upload status
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              'Updating your Next of Kin Information',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            message: SpinKitDualRing(
              color: Colors.red,
              size: 50,
            ),
          );
        });

    _startUploadKinImage(_kinImageFile).then((value) {
      //Change value in firebase users collection

      Firestore.instance
          .collection("users")
          .document(uid)
          .updateData({"kinPhotoURL": value});
    }).whenComplete(() {
      Navigator.of(context).pop();
      //Show a success message
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: Text(
                'Your profile has been updated',
                style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                )),
              ),
            );
          });
    });
  }

  Future _setKinIdFile() async {
    //Action sheet to show upload status
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              'Updating your Next of Kin Information',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            message: SpinKitDualRing(
              color: Colors.red,
              size: 50,
            ),
          );
        });

    _startUploadKinID(_kinIDFile).then((value) {
      //Change value in firebase users collection

      Firestore.instance
          .collection("users")
          .document(uid)
          .updateData({"kinNatIdURL": value});
    }).whenComplete(() {
      Navigator.of(context).pop();
      //Show a success message
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: Text(
                'Your profile has been updated',
                style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                )),
              ),
            );
          });
    });
  }

  Future _setKinKraFile() async {
    //Action sheet to show upload status
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              'Updating your Next of Kin Information',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            message: SpinKitDualRing(
              color: Colors.red,
              size: 50,
            ),
          );
        });

    _startUploadKinKra(_kinKraFile).then((value) {
      //Change value in firebase users collection

      Firestore.instance
          .collection("users")
          .document(uid)
          .updateData({"kinKraUrl": value});
    }).whenComplete(() {
      Navigator.of(context).pop();
      //Show a success message
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: Text(
                'Your profile has been updated',
                style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                )),
              ),
            );
          });
    });
  }

  Future _showIdSelection() {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            title: Text(
              'Select a source',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickIdDocuments(ImageSource.camera);
                  },
                  child: Text(
                    'CAMERA',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  )),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickIdDocuments(ImageSource.gallery);
                  },
                  child: Text(
                    'GALLERY',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ))
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                )));
      },
    );
  }

  Future _showKraSelection() {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            title: Text(
              'Select a source',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickKraDocuments(ImageSource.camera);
                  },
                  child: Text(
                    'CAMERA',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  )),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickKraDocuments(ImageSource.gallery);
                  },
                  child: Text(
                    'GALLERY',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ))
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                )));
      },
    );
  }

  Future _showSelection() {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            title: Text(
              'Select a source',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                  child: Text(
                    'CAMERA',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  )),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                  child: Text(
                    'GALLERY',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ))
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                )));
      },
    );
  }

  Future _showKinImageSelection() {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            title: Text(
              'Select a source',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickKinImage(ImageSource.camera);
                  },
                  child: Text(
                    'CAMERA',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  )),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickKinImage(ImageSource.gallery);
                  },
                  child: Text(
                    'GALLERY',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ))
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                )));
      },
    );
  }

  Future _showKinIdSelection() {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            title: Text(
              'Select a source',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickKinId(ImageSource.camera);
                  },
                  child: Text(
                    'CAMERA',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  )),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickKinId(ImageSource.gallery);
                  },
                  child: Text(
                    'GALLERY',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ))
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                )));
      },
    );
  }

  Future _showKinKraSelection() {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            title: Text(
              'Select a source',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              )),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickKinKra(ImageSource.camera);
                  },
                  child: Text(
                    'CAMERA',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  )),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickKinKra(ImageSource.gallery);
                  },
                  child: Text(
                    'GALLERY',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ))
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                )));
      },
    );
  }

  void _btnUploadDp() {
    //Show the selection panel
    _showSelection();
  }

  void _btnUploadKinDp() {
    //Show the selection panel
    _showKinImageSelection();
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
                backgroundImage:
                    user.photoURL == null ? null : NetworkImage(user.photoURL)),
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
                    onTap: _btnUploadDp,
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
                      child: user.natIDURL == null
                          ? Center(
                              child: IconButton(
                                icon: Icon(Icons.add_a_photo,
                                    color: Colors.white),
                                onPressed: () => _showIdSelection(),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                user.natIDURL,
                                fit: BoxFit.fill,
                              )),
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
                      child: user.kraURL == null
                          ? Center(
                              child: IconButton(
                                icon: Icon(Icons.add_a_photo,
                                    color: Colors.white),
                                onPressed: () => _showKraSelection(),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                user.kraURL,
                                fit: BoxFit.fill,
                              )),
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

  Widget _documentsKinUpload() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Next of Kin Documents',
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
                      child: user.kinNatIdURL == null
                          ? Center(
                              child: IconButton(
                                icon: Icon(Icons.add_a_photo,
                                    color: Colors.white),
                                onPressed: () => _showKinIdSelection(),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                user.kinNatIdURL,
                                fit: BoxFit.fill,
                              )),
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
                      child: user.kinKraUrl == null
                          ? Center(
                              child: IconButton(
                                icon: Icon(Icons.add_a_photo,
                                    color: Colors.white),
                                onPressed: () => _showKinKraSelection(),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                user.kinKraUrl,
                                fit: BoxFit.fill,
                              )),
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

  Widget _kinDp() {
    return Center(
      child: Container(
        height: 140,
        width: 140,
        child: Stack(
          children: <Widget>[
            CircleAvatar(
                radius: 70,
                backgroundImage: user.kinPhotoURL == null
                    ? null
                    : NetworkImage(user.kinPhotoURL)),
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
                    onTap: _btnUploadKinDp,
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
            height: 20,
          ),
          _nameKinWidget(),
          SizedBox(
            height: 30,
          ),
          _phoneKinWidget(),
          SizedBox(
            height: 30,
          ),
          _natIdKinWidget(),
          SizedBox(
            height: 30,
          ),
          _documentsKinUpload(),
          SizedBox(
            height: 30,
          ),
          _kinDp(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Retrieve UID
    uid = ModalRoute.of(context).settings.arguments;
    //print('PROFILE UID: $uid');

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
              StreamBuilder(
                stream: helper.getUser(uid),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {}
                  if (snapshot.hasData) {
                    //Convert to user
                    user = User.fromJson(snapshot.data.data);
                    //print(snapshot.data.data);

                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Form(
                          key: _formKey,
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
                      ),
                    );
                  }
                  return Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 200,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
