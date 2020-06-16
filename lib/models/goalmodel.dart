import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

GoalModel goalmodelFromJson(String str) => GoalModel.fromJson(json.decode(str));

String goalmodelToJson(GoalModel data) => json.encode(data.toJson());

class GoalModel {
  String goalCategory;
  String goalName;
  String goalClass;
  String goalType;
  String uid;
  var interest;
  var growth;
  var goalAmount;
  var goalAmountSaved;
  Timestamp goalCreateDate;
  Timestamp goalEndDate;
  var goalAllocation;
  bool isGoalDeletable;

  GoalModel(
      {this.goalCategory,
      this.goalName,
      this.goalClass,
      this.goalType,
      this.uid,
      this.interest,
      this.growth,
      this.goalAmount,
      this.goalAmountSaved,
      this.goalCreateDate,
      this.goalEndDate,
      this.goalAllocation,
      this.isGoalDeletable});

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
      goalCategory: json["goalCategory"],
      goalName: json["goalName"],
      goalClass: json["goalClass"],
      goalType: json["goalType"],
      uid: json["uid"],
      interest: json['interest'],
      growth: json['growth'],
      goalAmount: json["goalAmount"],
      goalAmountSaved: json["goalAmountSaved"],
      goalCreateDate: json["goalCreateDate"],
      goalEndDate: json["goalEndDate"],
      goalAllocation: json["goalAllocation"],
      isGoalDeletable: json["isGoalDeletable"]);

  Map<String, dynamic> toJson() => {
        "goalCategory": goalCategory,
        "goalName": goalName,
        "goalClass": goalClass,
        "goalType": goalType,
        "uid": uid,
        "goalAmount": goalAmount,
        "interest": interest,
        "growth": growth,
        "goalAmountSaved": goalAmountSaved,
        "goalCreateDate": goalCreateDate,
        "goalEndDate": goalEndDate,
        "goalAllocation": goalAllocation,
        "isGoalDeletable": isGoalDeletable
      };
}
