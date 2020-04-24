import 'package:wealth/models/bankModel.dart';
import 'package:wealth/models/cardModel.dart';
import 'package:wealth/models/days.dart';

class UserPref {
  double passiveSavingsRate = 5;
  double loanLimit;
  String phone;
  //Reminders
  bool isReminderDaily;
  bool isReminderWeekly;
  List<Days> weeklyDays;
  String reminderTime;
  //Payments
  String preferredPaymentMethod;
  PaymentCard paymentCard;
  //Withdrawal
  String preferredWithdrawalMethod;
  BankModel bankDetails;


  UserPref(
      {this.passiveSavingsRate,
      this.loanLimit,
        this.phone,
      this.isReminderDaily,
      this.isReminderWeekly,
      this.weeklyDays,
      this.reminderTime,
      this.preferredPaymentMethod,
      this.paymentCard,
      this.preferredWithdrawalMethod,
      this.bankDetails});

  factory UserPref.fromJson(Map<String, dynamic> json) => UserPref(
        passiveSavingsRate: json["passiveSavingsRate"],
        loanLimit: json["loanLimit"],
        phone: json["phone"],
        isReminderDaily: json["isReminderDaily"],
        isReminderWeekly: json["isReminderWeekly"],
        weeklyDays: json["weeklyDays"],
        reminderTime: json["reminderTime"],
        preferredPaymentMethod: json["preferredPaymentMethod"],
        paymentCard: json["paymentCard"],
        preferredWithdrawalMethod: json["preferredWithdrawalMethod"],
        bankDetails: json["bankDetails"],
      );

  Map<String, dynamic> toJson() => {
        "passiveSavingsRate": passiveSavingsRate,
        "loanLimit": loanLimit,
        "isReminderDaily": isReminderDaily,
        "isReminderWeekly": isReminderWeekly,
        "weeklyDays": weeklyDays,
        "phone": phone,
        "reminderTime": reminderTime,
        "preferredPaymentMethod": preferredPaymentMethod,
        "paymentCard": paymentCard,
        "preferredWithdrawalMethod": preferredWithdrawalMethod,
        "bankDetails": bankDetails
      };
}
