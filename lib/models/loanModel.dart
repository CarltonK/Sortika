import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

LoanModel loanmodelFromJson(String str) => LoanModel.fromJson(json.decode(str));

String loanmodelToJson(LoanModel data) => json.encode(data.toJson());

class LoanModel {
  List<dynamic> loanLenders;
  String loanBorrower;
  double loanAmountTaken;
  double loanAmountRepaid;
  double loanInterest;
  Timestamp loanEndDate;
  Timestamp loanTakenDate;
  double loanIC;
  double totalAmountToPay;

  LoanModel(
      {this.loanLenders,
      this.loanBorrower,
      this.loanAmountTaken,
      this.loanAmountRepaid,
      this.loanInterest,
      this.loanEndDate,
      this.loanTakenDate,
      this.loanIC,
      this.totalAmountToPay});

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
      loanLenders: json["loanLenders"],
      loanBorrower: json["loanBorrower"],
      loanAmountTaken: json["loanAmountTaken"],
      loanAmountRepaid: json["loanAmountRepaid"],
      loanInterest: json["loanInterest"],
      loanEndDate: json["loanEndDate"],
      loanTakenDate: json["loanTakenDate"],
      loanIC: json["loanIC"],
      totalAmountToPay: json["totalAmountToPay"]);

  Map<String, dynamic> toJson() => {
        "loanLenders": loanLenders,
        "loanBorrower": loanBorrower,
        "loanAmountTaken": loanAmountTaken,
        "loanAmountRepaid": loanAmountRepaid,
        "loanInterest": loanInterest,
        "loanEndDate": loanEndDate,
        "loanTakenDate": loanTakenDate,
        "loanIC": loanIC,
        "totalAmountToPay": totalAmountToPay
      };
}
