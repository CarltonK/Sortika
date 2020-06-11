import 'package:cloud_firestore/cloud_firestore.dart';

class LoanPaymentModel {
  num amount;
  String lenderUid;
  String borrowerUid;
  String loanDoc;
  Timestamp date = Timestamp.now();

  LoanPaymentModel(
      {this.amount, this.borrowerUid, this.lenderUid, this.loanDoc});

  factory LoanPaymentModel.fromJson(Map<String, dynamic> json) =>
      LoanPaymentModel(
        amount: json['amount'],
        borrowerUid: json['borrowerUid'],
        lenderUid: json['lenderUid'],
        loanDoc: json['loanDoc'],
      );

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'borrowerUid': borrowerUid,
        'lenderUid': lenderUid,
        'loanDoc': loanDoc,
        'date': date
      };
}
