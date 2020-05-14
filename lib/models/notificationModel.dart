import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String message;
  Timestamp time;

  NotificationModel({this.message, this.time});

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(message: json["message"], time: json["time"]);

  Map<String, dynamic> toJson() => {"message": message, "time": time};
}
