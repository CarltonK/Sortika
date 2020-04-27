import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  String activity;
  Timestamp activityDate;

  ActivityModel({this.activity, this.activityDate});

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
      activity: json["activity"], activityDate: json["activityDate"]);

  Map<String, dynamic> toJson() =>
      {"activity": activity, "activityDate": activityDate};
}
