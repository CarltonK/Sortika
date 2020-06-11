import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String uid;
  String title;
  String review;
  final Timestamp date = Timestamp.now();

  ReviewModel({this.uid, this.title, this.review});

  Map<String, dynamic> toJson() =>
      {"uid": uid, "title": title, "review": review, "date": date};
}
