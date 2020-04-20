import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wealth/models/goalmodel.dart';
import 'dart:convert';

GroupModel groupmodelFromJson(String str) =>
    GroupModel.fromJson(json.decode(str));

String groupmodelToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel extends GoalModel {
  //Properties specific to this group
  String groupObjective;
  String groupAdmin;
  List<dynamic> members;
  int groupMembersTargeted;
  int groupMembers;
  bool isGroupRegistered;
  //Group Settings
  double targetAmountPerp;
  bool shouldMemberSeeSavings;

  GroupModel(
      {
      //Inherited properties
      String goalCategory,
      String goalName,
      double goalAmount,
      double goalAmountSaved,
      Timestamp goalCreateDate,
      Timestamp goalEndDate,
      bool isGoalDeletable,
      double goalAllocation,
      this.groupObjective,
      this.groupAdmin,
      this.members,
      this.groupMembersTargeted,
      this.groupMembers,
      this.isGroupRegistered,
      this.targetAmountPerp,
      this.shouldMemberSeeSavings})
      : super(
            goalCategory: goalCategory,
            goalName: goalName,
            goalAmount: goalAmount,
            goalCreateDate: goalCreateDate,
            goalEndDate: goalEndDate,
            goalAmountSaved: goalAmountSaved,
            isGoalDeletable: isGoalDeletable,
            goalAllocation: goalAllocation);

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final model = GoalModel.fromJson(json);
    return GroupModel(
        goalCategory: model.goalCategory,
        goalName: model.goalName,
        goalAmount: model.goalAmount,
        goalAmountSaved: model.goalAmountSaved,
        goalCreateDate: model.goalCreateDate,
        goalEndDate: model.goalEndDate,
        isGoalDeletable: model.isGoalDeletable,
        groupObjective: json["groupObjective"],
        groupAdmin: json["groupAdmin"],
        members: json["members"],
        groupMembersTargeted: json["groupMembersTargeted"],
        groupMembers: json["groupMembers"],
        isGroupRegistered: json["isGroupRegistered"],
        targetAmountPerp: json["targetAmountPerp"],
        shouldMemberSeeSavings: json["shouldMemberSeeSavings"],
        goalAllocation: model.goalAllocation);
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
        "groupAdmin": groupAdmin,
        "members": members,
        "groupMembersTargeted": groupMembersTargeted,
        "groupMembers": groupMembers,
        "isGroupRegistered": isGroupRegistered,
        "targetAmountPerp": targetAmountPerp,
        "shouldMemberSeeSavings": shouldMemberSeeSavings,
        "goalAllocation": goalAllocation
      };
}
