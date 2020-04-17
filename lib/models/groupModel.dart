import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wealth/models/goalmodel.dart';
import 'dart:convert';

GroupModel groupmodelFromJson(String str) =>
    GroupModel.fromJson(json.decode(str));

String groupmodelToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel extends GoalModel {
  //Properties specific to this group
  String groupObjective;
  int groupMembersTargeted;
  int groupMembers;
  bool isGroupRegistered;
  //Group Settings
  double targetAmountPerp;
  bool shouldMemberSeeSavings;

  GroupModel(
      {
      //Inherited properties
      final String goalCategory,
      String goalName,
      double targetAmount,
      double amountSaved,
      Timestamp goalCreateDate,
      Timestamp goalEndDate,
      bool isDeletable,
      this.groupObjective,
      this.groupMembersTargeted,
      this.groupMembers,
      this.isGroupRegistered,
      this.targetAmountPerp,
      this.shouldMemberSeeSavings})
      : super(
            goalCategory: goalCategory,
            goalName: goalName,
            goalAmount: targetAmount,
            goalCreateDate: goalCreateDate,
            goalEndDate: goalEndDate,
            goalAmountSaved: amountSaved,
            isGoalDeletable: isDeletable);

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final model = GoalModel.fromJson(json);
    return GroupModel(
        goalCategory: model.goalCategory,
        goalName: model.goalName,
        targetAmount: model.goalAmount,
        amountSaved: model.goalAmountSaved,
        goalCreateDate: model.goalCreateDate,
        goalEndDate: model.goalEndDate,
        isDeletable: model.isGoalDeletable,
        groupObjective: json["groupObjective"],
        groupMembersTargeted: json["groupMembersTargeted"],
        groupMembers: json["groupMembers"],
        isGroupRegistered: json["isGroupRegistered"],
        targetAmountPerp: json["targetAmountPerp"],
        shouldMemberSeeSavings: json["shouldMemberSeeSavings"]);
  }
  Map<String, dynamic> toJson() => {
        "goalCategory": goalCategory,
        "goalName": goalName,
        "goalAmount": goalAmount,
        "goalAmountSaved": goalAmountSaved,
        "goalCreateDate": goalCreateDate,
        "goalEndDate": goalEndDate,
        "isGoalDeletable": isGoalDeletable,
        "groupObjective": groupObjective,
        "groupMembersTargeted": groupMembersTargeted,
        "groupMembers": groupMembers,
        "isGroupRegistered": isGroupRegistered,
        "targetAmountPerp": targetAmountPerp,
        "shouldMemberSeeSavings": shouldMemberSeeSavings
      };
}
