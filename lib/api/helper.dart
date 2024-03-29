import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wealth/analytics/analytics_funnels.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/captureModel.dart';
import 'package:wealth/models/depositModel.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/models/investmentModel.dart';
import 'package:wealth/models/loanPayModel.dart';
import 'package:wealth/models/reviewModel.dart';
import 'package:wealth/models/phoneVerificationModel.dart';
import 'package:wealth/models/lotteryModel.dart';

class Helper {
  //create instance of Firestore
  final Firestore _firestore = Firestore.instance;
  //Instance of authentication
  AuthService authService = new AuthService();
  //Instance of Analytics
  AnalyticsFunnel funnel = new AnalyticsFunnel();

  //Initialize class
  Helper() {
    print("An instance of Database Helper has started");
  }

  //Retrieve User
  Stream<DocumentSnapshot> getUser(String uid) {
    Stream<DocumentSnapshot> stream =
        _firestore.collection('users').document(uid).snapshots();
    return stream;
  }

  //Retrieve all user goals
  Future<QuerySnapshot> getAllGoals(String uid) async {
    QuerySnapshot queries = await _firestore
        .collection('users')
        .document(uid)
        .collection('goals')
        .getDocuments();
    return queries;
  }

  //Retrieve Investment data to populate graph
  Future<QuerySnapshot> getInvestmentData(String uid) async {
    QuerySnapshot queries = await _firestore
        .collection('users')
        .document(uid)
        .collection('goals')
        .where('goalCategory', isEqualTo: 'Investment')
        .limit(12)
        .getDocuments();
    return queries;
  }

  //Loan Lender Update Document
  Future updateLoanDoc(
      Map<String, dynamic> loanData, num amount, num interest) async {
    String docId = loanData['docId'];
    String token = loanData['tokenMe'];
    String name = loanData['nameMe'];
    String uid = loanData['uid'];
    var interestAmt = amount * (interest / 100);
    var sortikaInterest = interestAmt * 0.2;
    var clientInterest = interestAmt * 0.8;
    var totalAmount = amount + interestAmt;
    await _firestore.collection('loans').document(docId).updateData({
      'loanStatus': 'Revised',
      'loanAmountTaken': amount,
      'loanInterest': interest,
      'totalAmountToPay': totalAmount,
      'sortikaInterestComputed': sortikaInterest,
      'clientInterestComputed': clientInterest,
      'lfrepaymentAmount': amount,
      'loanBalance': totalAmount,
      'loanInvitees': null,
      'loanInviteeName': null,
      'tokenInvitee': null,
      'loanLender': uid,
      'loanLenderName': name,
      'loanLenderToken': token
    });
  }

  //Loan Borrower Revise Loan
  Future reviseLoanDoc(String docId, num amount, num interest) async {
    var interestAmt = amount * (interest / 100);
    var sortikaInterest = interestAmt * 0.2;
    var clientInterest = interestAmt * 0.8;
    var totalAmount = amount + interestAmt;
    await _firestore.collection('loans').document(docId).updateData({
      'loanStatus': 'Revised2',
      'loanAmountTaken': amount,
      'loanInterest': interest,
      'totalAmountToPay': totalAmount,
      'sortikaInterestComputed': sortikaInterest,
      'clientInterestComputed': clientInterest,
      'lfrepaymentAmount': amount,
      'loanBalance': totalAmount,
    });
  }

  //Loan Rejection
  Future rejectLoanDoc(String docId) async {
    await _firestore
        .collection('loans')
        .document(docId)
        .updateData({'loanStatus': 'Rejected'});
  }

  //Fetch user notifications
  Future<QuerySnapshot> getUserNotification(String uid) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .document(uid)
        .collection('notifications')
        .orderBy('time', descending: true)
        .getDocuments();
    return snapshot;
  }

  //Get Group Goal
  Future<DocumentSnapshot> getGroupGoal(String uid, String code) async {
    QuerySnapshot queries = await _firestore
        .collection('users')
        .document(uid)
        .collection('goals')
        .where('goalCategory', isEqualTo: 'Group')
        .where('groupCode', isEqualTo: code)
        .getDocuments();

    if (queries.documents.first != null) {
      return queries.documents.first;
    } else {
      return null;
    }
  }

  //Get Loan + IC
  Future getLoanInterestCover(String uid, double loanAmount) async {
    //Retrieve all goals
    QuerySnapshot queries = await _firestore
        .collection('users')
        .document(uid)
        .collection('goals')
        .getDocuments();
    //Keep a count of all amount
    double totalAmount = 0;
    //Iterate through the goals and convert to a Goal Model
    queries.documents.forEach((element) {
      GoalModel goal = GoalModel.fromJson(element.data);
      if (goal.goalCategory == 'Saving' || goal.goalCategory == 'Investment') {
        totalAmount += goal.goalAmountSaved;
      }
    });
    double cover = ((totalAmount / loanAmount) * 100);
    return cover;
  }

  //Get Loan Limits
  Future getLoanLimit(String uid) async {
    QuerySnapshot query = await _firestore
        .collection("users")
        .document(uid)
        .collection("goals")
        .where("goalCategory", isEqualTo: "Loan Fund")
        .getDocuments();
    return query.documents.first;
  }

  //Deposit Money
  Future depositMoney(String uid, DepositModel model) async {
    await _firestore.collection('deposits').document().setData(model.toJson());
  }

  //Deposit Money
  Future withdrawMoney(String uid, String phone, double amount) async {
    ActivityModel withdrawAct = new ActivityModel(
        activity: 'You have submitted a request to withdraw',
        activityDate: Timestamp.now());
    await authService.postActivity(uid, withdrawAct);

    await _firestore
        .collection('withdrawals')
        .document(uid)
        .setData({'uid': uid, 'phone': phone, 'amount': amount});

    await funnel.logEvent('Withdrawal', uid);
  }

  //Get Wallet Balance
  Stream<DocumentSnapshot> getWalletBalance(String uid) {
    Stream<DocumentSnapshot> doc = _firestore
        .collection('users')
        .document(uid)
        .collection('wallet')
        .document(uid)
        .snapshots();
    return doc;
  }

  Future<num> getWalletBalanceNumber(String uid) async {
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .document(uid)
        .collection('wallet')
        .document(uid)
        .get();

    num amount = doc.data['amount'];
    return amount;
  }

  //Get Redeemables
  Future<QuerySnapshot> getRedeemables() async {
    QuerySnapshot queries =
        await _firestore.collection('redeemables').getDocuments();
    return queries;
  }

  //Return data for Plotting graph
  Future<List<Map<String, dynamic>>> getInvestmentGraphData(String uid) async {
    List<Map<String, dynamic>> dataList = [];
    QuerySnapshot queries = await _firestore
        .collection('users')
        .document(uid)
        .collection('goals')
        .where('goalCategory', isEqualTo: 'Investment')
        .getDocuments();

    queries.documents.forEach((element) async {
      QuerySnapshot queriesTrans = await _firestore
          .collection('transactions')
          .where('transactionUid', isEqualTo: uid)
          .where('transactionCategory', isEqualTo: 'Investment')
          .where('transactionGoal', isEqualTo: element.data['goalName'])
          .getDocuments();

      Map<String, dynamic> data = {
        'name': element.data['goalName'],
        'endDate': element.data['goalEndDate'],
        'documents': queriesTrans.documents,
        'total': element.data['goalAmount']
      };
      print(data);
      dataList.add(data);
    });

    return dataList;
  }

  //Get transaction documents
  Future<QuerySnapshot> getTransactions(String uid, String category) async {
    QuerySnapshot queries = await _firestore
        .collection('transactions')
        .where('transactionUid', isEqualTo: uid)
        .where('transactionCategory', whereIn: ['General', category])
        .orderBy('transactionTime', descending: true)
        .getDocuments();
    //print(queries.documents);
    return queries;
  }

  //Retrieve transactions pertaining to a single goal
  Future<QuerySnapshot> getSingleGoalTransactions(
      String uid, String category, String goal) async {
    QuerySnapshot queries = await _firestore
        .collection('transactions')
        .where('transactionUid', isEqualTo: uid)
        .where('transactionCategory', isEqualTo: category)
        .where('transactionGoal', isEqualTo: goal)
        .getDocuments();
    return queries;
  }

  //Get wallet transaction documents
  Future<QuerySnapshot> getWalletTransactions(String uid, String action) async {
    QuerySnapshot queries = await _firestore
        .collection('transactions')
        .where('transactionUid', isEqualTo: uid)
        .where('transactionCategory', isEqualTo: 'Wallet')
        .where('transactionAction', isEqualTo: action)
        .orderBy('transactionTime', descending: true)
        .getDocuments();
    //print(queries.documents);
    return queries;
  }

  //Retrieve user investment summary
  Future<List<Map<String, dynamic>>> goalSummaryData(
      String category, String uid) async {
    try {
      //All investments
      QuerySnapshot queryInvestments =
          await _firestore.collection('investments').getDocuments();
      List<DocumentSnapshot> investmentDocs = queryInvestments.documents;

      //All user goals
      QuerySnapshot userGoalQuery = await _firestore
          .collection('users')
          .document(uid)
          .collection('goals')
          .where('goalCategory', isEqualTo: category)
          .getDocuments();
      List<DocumentSnapshot> goalDocs = userGoalQuery.documents;

      List<Map<String, dynamic>> superData = [];
      for (int i = 0; i < investmentDocs.length; i++) {
        DocumentSnapshot currentInvestDoc = investmentDocs[i];
        String title = currentInvestDoc.data['title'];
        List<dynamic> types = currentInvestDoc.data['types'];
        // print('$title - $types');
        for (int index = 0; index < goalDocs.length; index++) {
          DocumentSnapshot currentGoalDoc = goalDocs[index];
          GoalModel singleGoal = GoalModel.fromJson(currentGoalDoc.data);
          num amtSaved = singleGoal.goalAmountSaved;
          if (singleGoal.goalClass == title) {
            String type = singleGoal.goalType;
            Map<String, dynamic> one = {'title': title};
            List<Map<String, dynamic>> two = [];
            for (int ind = 0; ind < types.length; ind++) {
              if (type == types[ind]['name']) {
                print(
                    '$title - $type - $amtSaved KES - ${types[ind]['booking']}');
                Map<String, dynamic> three = {
                  'name': type,
                  'booking': types[ind]['booking'],
                  'amountSaved': amtSaved
                };
                two.add(three);
              }
            }
            one.putIfAbsent('data', () => two);
            superData.add(one);
          }
        }
      }
      print(superData);
      return superData;
    } catch (e) {
      print(
        'Error ${e.toString()}',
      );
      return null;
    }
  }

  //Retrieve Active Savings vs Incomes
  Future<Map<String, dynamic>> getPassiveVExpense(String uid) async {
    //Active Savings - (collection == transactions)
    QuerySnapshot queriesPassive = await _firestore
        .collection('transactions')
        .where('transactionUid', isEqualTo: uid)
        .where('transactionAction', isEqualTo: 'Passive')
        .getDocuments();
    //Income - (transaction_type == 'received')
    QuerySnapshot queriesSent = await _firestore
        .collection('captures')
        .where('transaction_user', isEqualTo: uid)
        .where('transaction_type', isEqualTo: 'sent')
        .orderBy('transaction_date', descending: true)
        .getDocuments();
    // print('Expenses count: ${queriesSent.documents.length}');

    int totalDocs =
        queriesPassive.documents.length + queriesSent.documents.length;

    //Retrieve total amount
    //expect string eg 10.00
    //split by '.'
    //convert to double then add
    //1) Sent
    //2) Received

    double passiveAmount = 0;
    queriesPassive.documents.forEach((element) {
      num amount = element.data['transactionAmount'];
      passiveAmount += amount;
    });

    double sentAmount = 0;
    queriesSent.documents.forEach((element) {
      String amount = element.data['transaction_amount'];
      String amountNeeded = amount.split('.')[0];
      sentAmount += double.parse(amountNeeded);
    });

    return {
      'passive': queriesPassive,
      'expenses': queriesSent,
      'total': totalDocs,
      'passiveAmount': passiveAmount,
      'sentAmount': sentAmount
    };
  }

  //Retrieve Active Savings vs Incomes
  Future<Map<String, dynamic>> getActiveVIncome(String uid) async {
    //Active Savings - (collection == transactions)
    QuerySnapshot queriesActive = await _firestore
        .collection('transactions')
        .where('transactionUid', isEqualTo: uid)
        .where('transactionAction', isEqualTo: 'Deposit')
        .getDocuments();
    //Income - (transaction_type == 'received')
    QuerySnapshot queriesReceived = await _firestore
        .collection('captures')
        .where('transaction_user', isEqualTo: uid)
        .where('transaction_type', isEqualTo: 'received')
        .orderBy('transaction_date', descending: true)
        .getDocuments();
    // print('Incomes count: ${queriesReceived.documents.length}');

    int totalDocs =
        queriesActive.documents.length + queriesReceived.documents.length;

    //Retrieve total amount
    //expect string eg 10.00
    //split by '.'
    //convert to double then add
    //1) Sent
    //2) Received

    double activeAmount = 0;
    queriesActive.documents.forEach((element) {
      num amount = element.data['transactionAmount'];
      activeAmount += amount;
    });

    double receivedAmount = 0;
    queriesReceived.documents.forEach((element) {
      String amount = element.data['transaction_amount'];
      String amountNeeded = amount.split('.')[0];
      receivedAmount += double.parse(amountNeeded);
    });

    return {
      'active': queriesActive,
      'incomes': queriesReceived,
      'total': totalDocs,
      'activeAmount': activeAmount,
      'receivedAmount': receivedAmount
    };
  }

  //Retrieve Incomes vs Expenses
  Future<Map<String, dynamic>> getIncomeVExpenses(String uid) async {
    //Expenses - (transaction_type == 'sent')
    QuerySnapshot queriesSent = await _firestore
        .collection('captures')
        .where('transaction_user', isEqualTo: uid)
        .where('transaction_type', isEqualTo: 'sent')
        .orderBy('transaction_date', descending: true)
        .getDocuments();
    print('Expenses count: ${queriesSent.documents.length}');
    //Income - (transaction_type == 'received')
    QuerySnapshot queriesReceived = await _firestore
        .collection('captures')
        .where('transaction_user', isEqualTo: uid)
        .where('transaction_type', isEqualTo: 'received')
        .orderBy('transaction_date', descending: true)
        .getDocuments();
    print('Incomes count: ${queriesReceived.documents.length}');
    int totalDocs =
        queriesSent.documents.length + queriesReceived.documents.length;

    //Retrieve total amount
    //expect string eg 10.00
    //split by '.'
    //convert to double then add
    //1) Sent
    //2) Received

    double sentAmount = 0;
    queriesSent.documents.forEach((element) {
      String amount = element.data['transaction_amount'];
      String amountNeeded = amount.split('.')[0];
      sentAmount += double.parse(amountNeeded);
    });

    double receivedAmount = 0;
    queriesReceived.documents.forEach((element) {
      String amount = element.data['transaction_amount'];
      String amountNeeded = amount.split('.')[0];
      receivedAmount += double.parse(amountNeeded);
    });

    return {
      'expenses': queriesSent,
      'incomes': queriesReceived,
      'total': totalDocs,
      'sentAmount': sentAmount,
      'receivedAmount': receivedAmount
    };
  }

  //Fetch Investments
  Stream<QuerySnapshot> fetchInvestmentTypes(String title) {
    Stream<QuerySnapshot> queries = _firestore
        .collection('investments')
        .document(title)
        .collection('types')
        .snapshots();
    return queries;
  }

  Future<List<InvestmentModel>> getInvestmentddData() async {
    List<InvestmentModel> data = [];
    QuerySnapshot queries =
        await _firestore.collection('investments').getDocuments();
    queries.documents.forEach((element) {
      InvestmentModel model = InvestmentModel.fromJson(element.data);
      //print(model.types);
      data.add(model);
    });
    //print(data);
    return data;
  }

  Future<List<InvestmentModel>> getSavingsddData() async {
    List<InvestmentModel> data = [];
    QuerySnapshot queries =
        await _firestore.collection('savings').getDocuments();
    queries.documents.forEach((element) {
      InvestmentModel model = InvestmentModel.fromJson(element.data);
      print(model.types);
      data.add(model);
    });
    print(data);
    return data;
  }

  //Manual Capture
  Future manualCapture(CaptureModel model) async {
    await _firestore.collection('captures').document().setData(model.toJson());
  }

  //Change Passive Savings Rate
  Future changePassiveRate(String uid, double value) async {
    await _firestore
        .collection('users')
        .document(uid)
        .updateData({'passiveSavingsRate': value});
  }

  //Creat a review
  Future createReview(ReviewModel model) async {
    await _firestore
        .collection('reviews')
        .document(model.uid)
        .setData(model.toJson());
  }

  //Request Phone Verification
  Future phoneVerify(PhoneVerificationModel model) async {
    await _firestore
        .collection('verifications')
        .document(model.uid)
        .setData(model.toJson());
  }

  //Verify OTP
  Future<dynamic> verifyOtp(PhoneVerificationModel model) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('verifications').document(model.uid).get();
    String code = snapshot.data['gen_code'];
    if (code == model.genCode) {
      await _firestore
          .collection('verifications')
          .document(snapshot.documentID)
          .delete();
      await _firestore
          .collection('users')
          .document(model.uid)
          .updateData({'phoneVerified': true});
      return true;
    }
    return false;
  }

  //Pay a p2p Loan
  Future<void> payP2pLoan(LoanPaymentModel model) async {
    await _firestore
        .collection('loanpayments')
        .document()
        .setData(model.toJson());
  }

  //Join the Lottery
  Future joinLottery(String club, String uid, String ticket, String name,
      var total, String token) async {
    await _firestore
        .collection('lottery')
        .document(club)
        .collection('participants')
        .document(uid)
        .setData({
      'uid': uid,
      'ticket': ticket,
      'name': name,
      'club': club,
      'fee': total,
      'token': token
    });
  }

  //Get Lottery Club Members
  Future<QuerySnapshot> getLottery() async {
    QuerySnapshot queries =
        await _firestore.collection('lottery').getDocuments();
    return queries;
  }

  Stream getSingleLottery(String docID) {
    Stream<DocumentSnapshot> lotDoc =
        _firestore.collection('lottery').document(docID).snapshots();
    return lotDoc;
  }

  Future redeemItem(String docID, String uid) async {
    await _firestore
        .collection('redeemables')
        .document(docID)
        .collection('requests')
        .document(uid)
        .setData({'uid': uid, 'redeemableID': docID});
  }

  //Redeem Goal
  Future redeemMyGoal(
      String uid, String docId, String token, var amount) async {
    await _firestore
        .collection('users')
        .document(uid)
        .collection('redeem')
        .document()
        .setData({
      'uid': uid,
      'goal': docId,
      'amount': amount,
      'token': token,
      'time': Timestamp.now()
    });

    ActivityModel redeemAct = new ActivityModel(
        activity: 'You have submitted a redeem request of $amount KES',
        activityDate: Timestamp.now());

    await authService.postActivity(uid, redeemAct);
  }

  Future<void> updateToken(String uid, String token) async {
    return await _firestore
        .collection('users')
        .document(uid)
        .updateData({'token': token});
  }
}
