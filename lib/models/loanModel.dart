import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

LoanModel loanmodelFromJson(String str) => LoanModel.fromJson(json.decode(str));

String loanmodelToJson(LoanModel data) => json.encode(data.toJson());

class LoanModel {
  String loanLender;
  var loanInvitees;
  String loanBorrower;
  double loanAmountTaken;
  double loanAmountRepaid;
  double loanInterest;
  Timestamp loanEndDate;
  Timestamp loanTakenDate;
  bool loanStatus;
  double loanIC;
  double totalAmountToPay;

  LoanModel(
      {this.loanLender,
      this.loanInvitees,
      this.loanBorrower,
      this.loanAmountTaken,
      this.loanAmountRepaid,
      this.loanInterest,
      this.loanStatus,
      this.loanEndDate,
      this.loanTakenDate,
      this.loanIC,
      this.totalAmountToPay});

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
      loanLender: json["loanLender"],
      loanBorrower: json["loanBorrower"],
      loanAmountTaken: json["loanAmountTaken"],
      loanAmountRepaid: json["loanAmountRepaid"],
      loanInterest: json["loanInterest"],
      loanInvitees: json["loanInvitees"],
      loanStatus: json["loanStatus"],
      loanEndDate: json["loanEndDate"],
      loanTakenDate: json["loanTakenDate"],
      loanIC: json["loanIC"],
      totalAmountToPay: json["totalAmountToPay"]);

  Map<String, dynamic> toJson() => {
        "loanLender": loanLender,
        "loanBorrower": loanBorrower,
        "loanAmountTaken": loanAmountTaken,
        "loanAmountRepaid": loanAmountRepaid,
        "loanInterest": loanInterest,
        "loanEndDate": loanEndDate,
        "loanTakenDate": loanTakenDate,
        "loanStatus": loanStatus,
        "loanIC": loanIC,
        "totalAmountToPay": totalAmountToPay,
        "loanInvitees": loanInvitees
      };
}
