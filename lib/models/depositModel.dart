import 'package:cloud_firestore/cloud_firestore.dart';

class DepositModel {
  String destination;
  String goalName;
  String method;
  //Common for all methods
  double amount;
  //Somewhat common for all methods
  String phone;
  String uid;
  final Timestamp time = Timestamp.now();

  DepositModel(
      {this.destination, this.goalName, this.method, this.amount, this.phone, this.uid});

  factory DepositModel.fromJson(Map<String, dynamic> json) => DepositModel(
      amount: json['amount'],
      destination: json['destination'],
      goalName: json['goalName'],
      method: json['method'],
      uid: json['uid'],
      phone: json['phone']);

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'destination': destination,
        'goalName': goalName,
        'method': method,
        'phone': phone,
        'uid': uid,
        'time': time
      };
}
