import 'package:cloud_firestore/cloud_firestore.dart';

class AutoCreateModel {
  double amount;
  Timestamp endDate;
  String returnRate;
  String uid;
  double returnInterestRate;
  double returnAmount;

  AutoCreateModel(
      {this.amount,
      this.endDate,
      this.returnRate,
      this.uid,
      this.returnInterestRate,
      this.returnAmount});

  factory AutoCreateModel.fromJson(Map<String, dynamic> json) =>
      AutoCreateModel(
        amount: json["amount"],
        endDate: json["endDate"],
        returnRate: json["returnRate"],
        uid: json["uid"],
        returnInterestRate: json["returnInterestRate"],
        returnAmount: json["returnAmount"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "endDate": endDate,
        "returnRate": returnRate,
        "uid": uid,
        "returnInterestRate": returnInterestRate,
        "returnAmount": returnAmount
      };
}
