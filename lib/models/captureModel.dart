import 'package:cloud_firestore/cloud_firestore.dart';

class CaptureModel {
  String transactionAmount;
  final Timestamp transactionRecorded = Timestamp.now();
  final bool transactionFulfilled = true;
  String transactionType;
  String transactionUser;

  CaptureModel(
      {this.transactionAmount, this.transactionType, this.transactionUser});

  Map<String, dynamic> toJson() => {
        "transaction_amount": transactionAmount,
        "transaction_type": transactionType,
        'transaction_fulfilled': transactionFulfilled,
        "transaction_user": transactionUser,
        'transaction_date': transactionRecorded
      };
}
