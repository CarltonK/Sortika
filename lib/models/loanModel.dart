import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

LoanModel loanmodelFromJson(String str) => LoanModel.fromJson(json.decode(str));

String loanmodelToJson(LoanModel data) => json.encode(data.toJson());

class LoanModel {
  //Lender Details
  String loanLender;
  String loanLenderName;
  String loanLenderToken;
  //Invitee Details
  var loanInvitees;
  String loanInviteeName;
  var tokenInvitee;
  //Borrower Details
  String loanBorrower;
  String tokenBorrower;
  String borrowerName;
  //Loan Details
  double loanAmountTaken;
  var loanAmountRepaid;
  double loanInterest;
  Timestamp loanEndDate;
  Timestamp loanTakenDate;
  var loanStatus;
  double loanIC;
  double totalAmountToPay;

  LoanModel(
      {this.loanLender,
      this.loanLenderName,
      this.loanLenderToken,
      this.loanInvitees,
      this.loanInviteeName,
      this.tokenInvitee,
      this.loanBorrower,
      this.tokenBorrower,
      this.borrowerName,
      this.loanAmountTaken,
      this.loanAmountRepaid,
      this.loanInterest,
      this.loanEndDate,
      this.loanTakenDate,
      this.loanStatus,
      this.loanIC,
      this.totalAmountToPay});

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
      loanLender: json["loanLender"],
      loanLenderName: json["loanLenderName"],
      loanLenderToken: json["loanLenderToken"],
      loanInvitees: json["loanInvitees"],
      loanInviteeName: json["loanInviteeName"],
      tokenInvitee: json["tokenInvitee"],
      loanBorrower: json["loanBorrower"],
      tokenBorrower: json["tokenBorrower"],
      borrowerName: json["borrowerName"],
      loanAmountTaken: json["loanAmountTaken"],
      loanAmountRepaid: json["loanAmountRepaid"],
      loanInterest: json["loanInterest"],
      loanEndDate: json["loanEndDate"],
      loanTakenDate: json["loanTakenDate"],
      loanStatus: json["loanStatus"],
      loanIC: json["loanIC"],
      totalAmountToPay: json["totalAmountToPay"]);

  Map<String, dynamic> toJson() => {
        "loanLender": loanLender,
        "loanLenderName": loanLenderName,
        "loanLenderToken": loanLenderToken,
        "loanInvitees": loanInvitees,
        "loanInviteeName": loanInviteeName,
        "tokenInvitee": tokenInvitee,
        "loanBorrower": loanBorrower,
        "tokenBorrower": tokenBorrower,
        "borrowerName": borrowerName,
        "loanAmountTaken": loanAmountTaken,
        "loanAmountRepaid": loanAmountRepaid,
        "loanInterest": loanInterest,
        "loanEndDate": loanEndDate,
        "loanTakenDate": loanTakenDate,
        "loanStatus": loanStatus,
        "loanIC": loanIC,
        "totalAmountToPay": totalAmountToPay,
      };
}
