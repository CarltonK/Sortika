import 'package:cloud_firestore/cloud_firestore.dart';

class LotteryModel {
  String name;
  int subscriptionFee;
  int ticketFee;
  Timestamp start;
  Timestamp end;
  String winner;
  int participants;

  LotteryModel(
      {this.name,
      this.subscriptionFee,
      this.ticketFee,
      this.start,
      this.end,
      this.winner,
      this.participants});

  factory LotteryModel.fromJson(Map<String, dynamic> json) => LotteryModel(
      name: json['name'],
      subscriptionFee: json['subscriptionFee'],
      ticketFee: json['ticketFee'],
      start: json['start'],
      end: json['end'],
      winner: json['winner'],
      participants: json['participants']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'subscriptionFee': subscriptionFee,
        'ticketFee': ticketFee,
        'start': start,
        'end': end,
        'winner': winner,
        'participants': participants
      };
}
