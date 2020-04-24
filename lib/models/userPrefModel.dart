import 'package:flutter/material.dart';
import 'package:wealth/models/cardModel.dart';
import 'package:wealth/models/days.dart';

class UserPref {
  double passiveSavingsRate = 5;
  double loanLimit;
  //Reminders
  bool isReminderDaily;
  bool isReminderWeekly;
  List<Days> weeklyDays;
  TimeOfDay reminderTime;
  //Payments
  String preferredPaymentMethod;
  PaymentCard paymentCard;
  //Withdrawal
  String preferredWithdrawalMethod;
  String bankName;
  String bankBranch;
  int bankCode;
  String bankkSwiftCode;
  String bankAccountName;
  String bankAccountNumber;

  UserPref(
      {this.passiveSavingsRate,
      this.loanLimit,
      this.isReminderDaily,
      this.isReminderWeekly,
      this.weeklyDays,
      this.reminderTime,
      this.preferredPaymentMethod,
      this.paymentCard,
      this.preferredWithdrawalMethod,
      this.bankName,
      this.bankBranch,
      this.bankCode,
      this.bankkSwiftCode,
      this.bankAccountName,
      this.bankAccountNumber});

  factory UserPref.fromJson(Map<String, dynamic> json) => UserPref(
        passiveSavingsRate: json["passiveSavingsRate"],
        loanLimit: json["loanLimit"],
        isReminderDaily: json["isReminderDaily"],
        isReminderWeekly: json["isReminderWeekly"],
        weeklyDays: json["weeklyDays"],
        reminderTime: json["reminderTime"],
        preferredPaymentMethod: json["preferredPaymentMethod"],
        paymentCard: json["paymentCard"],
        preferredWithdrawalMethod: json["preferredWithdrawalMethod"],
        bankName: json["bankName"],
        bankBranch: json["bankBranch"],
        bankCode: json["bankCode"],
        bankkSwiftCode: json["bankkSwiftCode"],
        bankAccountName: json["bankAccountName"],
        bankAccountNumber: json["bankAccountNumber"],
      );

  Map<String, dynamic> toJSON() => {
        "passiveSavingsRate": passiveSavingsRate,
        "loanLimit": loanLimit,
        "isReminderDaily": isReminderDaily,
        "isReminderWeekly": isReminderWeekly,
        "weeklyDays": weeklyDays,
        "reminderTime": reminderTime,
        "preferredPaymentMethod": preferredPaymentMethod,
        "paymentCard": paymentCard,
        "preferredWithdrawalMethod": preferredWithdrawalMethod,
        "bankName": bankName,
        "bankBranch": bankBranch,
        "bankCode": bankCode,
        "bankkSwiftCode": bankkSwiftCode,
        "bankAccountName": bankAccountName,
        "bankAccountNumber": bankAccountNumber
      };
}
