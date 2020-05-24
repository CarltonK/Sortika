import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsFunnel {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  AnalyticsFunnel() {
    print("An instance of Firebase Analytics has started");
  }

  //Log a SIGN UP
  Future<void> logSignUp(String uid) async {
    await analytics.logSignUp(signUpMethod: 'Firebase (Email & Password)');
    await analytics.setUserId(uid);
  }

  //Log an Event
  Future logEvent(String name, String identifier) async {
    await analytics.logEvent(
      name: name,
      parameters: <String, dynamic>{
        'user': identifier,
      },
    );
  }

  //log when On-Boarding process begins
  Future logOnBoardingStart() async {
    await analytics.logTutorialBegin();
  }

  //log when On-Boarding process ends
  Future logOnBoardingEnd() async {
    await analytics.logTutorialComplete();
  }

  //Log a borrow request as both an 'Add to Cart' and present offer
  Future logBorrowRequest(double amount, String loanType, String startDate,
      String endDate, String borrower) async {
    await analytics.logAddToCart(
      currency: 'KES',
      value: amount,
      itemId: borrower,
      itemName: loanType,
      itemCategory: 'Loan',
      quantity: 1,
      price: null,
      startDate: startDate,
      endDate: endDate,
    );
  }

  //Log when a loan is rejected
  Future logLoanRejection(
      double amount, String startDate, String endDate) async {
    await analytics.logRemoveFromCart(
        itemId: null,
        itemName: null,
        itemCategory: 'Loan',
        quantity: 1,
        currency: 'KES',
        value: amount,
        startDate: startDate,
        endDate: endDate);
  }

  //Track virtual currency
  Future logVirtualCurrency(double value) async {
    await analytics.logEarnVirtualCurrency(
      virtualCurrencyName: 'Sortikas',
      value: value,
    );
  }

  //Join a Group
  Future logJoinGroup(String code) async {
    await analytics.logJoinGroup(
      groupId: code,
    );
  }

  //Preferred Payment Method
  Future logLogin() async {
    await analytics.logLogin(loginMethod: 'Firebase (Email & Password)');
  }

  //Group Sharing action
  Future logShareGroup(String groupCode) async {
    await analytics.logShare(
        contentType: 'Group', itemId: groupCode, method: 'ACTION_SEND');
  }
}
