import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

LoanModel loanmodelFromJson(String str) => LoanModel.fromJson(json.decode(str));

String loanmodelToJson(LoanModel data) => json.encode(data.toJson());

class LoanModel {
  String loanLender;
  var loanInvitees;
  String loanInviteeName;
  String loanBorrower;
  double loanAmountTaken;
  double loanAmountRepaid;
  double loanInterest;
  Timestamp loanEndDate;
  Timestamp loanTakenDate;
  String tokenInvitee;
  String tokenBorrower;
  bool loanStatus;
  double loanIC;
  double totalAmountToPay;

  LoanModel(
      {this.loanLender,
      this.loanInvitees,
      this.loanInviteeName,
      this.loanBorrower,
      this.loanAmountTaken,
      this.loanAmountRepaid,
      this.loanInterest,
      this.tokenInvitee,
      this.tokenBorrower,
      this.loanStatus,
      this.loanEndDate,
      this.loanTakenDate,
      this.loanIC,
      this.totalAmountToPay});

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
      loanLender: json["loanLender"],
      loanInviteeName: json["loanInviteeName"],
      loanBorrower: json["loanBorrower"],
      loanAmountTaken: json["loanAmountTaken"],
      loanAmountRepaid: json["loanAmountRepaid"],
      loanInterest: json["loanInterest"],
      loanInvitees: json["loanInvitees"],
      loanStatus: json["loanStatus"],
      loanEndDate: json["loanEndDate"],
      loanTakenDate: json["loanTakenDate"],
      loanIC: json["loanIC"],
      tokenInvitee: json["tokenInvitee"],
      tokenBorrower: json["tokenBorrower"],
      totalAmountToPay: json["totalAmountToPay"]);

  Map<String, dynamic> toJson() => {
        "loanLender": loanLender,
        "loanInviteeName": loanInviteeName,
        "loanBorrower": loanBorrower,
        "loanAmountTaken": loanAmountTaken,
        "loanAmountRepaid": loanAmountRepaid,
        "loanInterest": loanInterest,
        "loanEndDate": loanEndDate,
        "loanTakenDate": loanTakenDate,
        "loanStatus": loanStatus,
        "tokenInvitee": tokenInvitee,
        "tokenBorrower": tokenBorrower,
        "loanIC": loanIC,
        "totalAmountToPay": totalAmountToPay,
        "loanInvitees": loanInvitees
      };
}
