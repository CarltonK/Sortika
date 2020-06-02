import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  //Initial Registration
  String fullName;
  String phone;
  String email;
  String password;
  Timestamp registerDate;
  String designation;
  var passiveSavingsRate;
  //Firebase user metadata
  String uid;
  //Account Page
  String photoURL;
  String natId;
  Timestamp dob;
  String gender;
  String natIDURL;
  String kraURL;
  String platform;
  String token;
  //Savings Targets
  var dailyTarget;
  var weeklyTarget;
  var monthlyTarget;
  var dailySavingsTarget;
  var loanLimitRatio;
  //Kin
  String kinName;
  String kinPhone;
  String kinID;
  String kinPhotoURL;
  String kinNatIdURL;
  String kinKraUrl;

  User(
      {this.fullName,
      this.phone,
      this.email,
      this.password,
      this.registerDate,
      this.designation,
      this.passiveSavingsRate,
      this.uid,
      this.photoURL,
      this.natId,
      this.dob,
      this.gender,
      this.natIDURL,
      this.kraURL,
      this.platform,
      this.token,
      this.dailyTarget,
      this.weeklyTarget,
      this.monthlyTarget,
      this.dailySavingsTarget,
      this.kinName,
      this.kinPhone,
      this.loanLimitRatio,
      this.kinID,
      this.kinPhotoURL,
      this.kinKraUrl,
      this.kinNatIdURL});

  factory User.fromJson(Map<String, dynamic> json) => User(
      fullName: json["fullName"],
      phone: json["phone"],
      email: json["email"],
      password: json["password"],
      registerDate: json["registerDate"],
      designation: json['designation'],
      uid: json["uid"],
      photoURL: json["photoURL"],
      natId: json["natId"],
      dob: json["dob"],
      gender: json["gender"],
      natIDURL: json["natIDURL"],
      kraURL: json["kraURL"],
      platform: json["platform"],
      token: json["token"],
      dailyTarget: json["dailyTarget"],
      weeklyTarget: json["weeklyTarget"],
      monthlyTarget: json["monthlyTarget"],
      kinName: json["kinName"],
      kinPhone: json["kinPhone"],
      kinID: json["kinID"],
      kinKraUrl: json["kinKraUrl"],
      kinNatIdURL: json["kinNatIdURL"],
      kinPhotoURL: json["kinPhotoURL"],
      dailySavingsTarget: json["dailySavingsTarget"],
      passiveSavingsRate: json['passiveSavingsRate'],
      loanLimitRatio: json['loanLimitRatio']);

  //Convert Dart object to JSON
  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "phone": phone,
        "email": email,
        "password": password,
        "registerDate": registerDate,
        'designation': designation,
        "uid": uid,
        "photoURL": photoURL,
        "natId": natId,
        "dob": dob,
        "gender": gender,
        "natIDURL": natIDURL,
        "kraURL": kraURL,
        "platform": platform,
        "token": token,
        "dailyTarget": dailyTarget,
        "weeklyTarget": weeklyTarget,
        "monthlyTarget": monthlyTarget,
        "passiveSavingsRate": passiveSavingsRate,
        "kinName": kinName,
        "kinPhone": kinPhone,
        "kinID": kinID,
        "kinKraUrl": kinKraUrl,
        "kinNatIdURL": kinNatIdURL,
        "kinPhotoURL": kinPhotoURL,
        "dailySavingsTarget": dailySavingsTarget,
        "loanLimitRatio": loanLimitRatio
      };
}
