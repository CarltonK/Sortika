import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/depositModel.dart';
import 'package:wealth/models/goalmodel.dart';

class Helper {
  //create instance of Firestore
  final Firestore _firestore = Firestore.instance;
  //Instance of authentication
  AuthService authService = new AuthService();

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
        .getDocuments();
    return queries;
  }

  //Loan Lender Update Document
  Future updateLoanDoc(String docId, num amount, num interest) async {
    double amountToPay = (amount * (1 + (interest / 100)));
    await _firestore.collection('loans').document(docId).updateData({
      'loanStatus': 'Revised',
      'loanAmountTaken': amount,
      'loanInterest': interest,
      'totalAmountToPay': amountToPay
    });
  }

  //Loan Borrower Revise Loan
  Future reviseLoanDoc(String docId, num amount, num interest) async {
    double amountToPay = (amount * (1 + (interest / 100)));
    await _firestore.collection('loans').document(docId).updateData({
      'loanStatus': 'Revised2',
      'loanAmountTaken': amount,
      'loanInterest': interest,
      'totalAmountToPay': amountToPay
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
    await _firestore
        .collection('deposits')
        .document(uid)
        .setData(model.toJson());
  }

    //Deposit Money
  Future withdrawMoney(String uid, String phone, double amount) async {
    await _firestore
        .collection('withdrawals')
        .document(uid)
        .setData({
          'uid': uid,
          'phone': phone,
          'amount': amount
        });
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

  //Get Redeemables
  Future<QuerySnapshot> getRedeemables() async {
    QuerySnapshot queries =
        await _firestore.collection('redeemables').getDocuments();
    return queries;
  }

  //Get transaction documents
  Future<QuerySnapshot> getTransactions(String uid, String category) async {
    QuerySnapshot queries = await _firestore
        .collection('users')
        .document(uid)
        .collection('transactions')
        .where('transactionCategory', isEqualTo: category)
        .getDocuments();
    return queries;
  }

  //Get wallet transaction documents
  Future<QuerySnapshot> getWalletTransactions(String uid, String action) async {
    QuerySnapshot queries = await _firestore
        .collection('users')
        .document(uid)
        .collection('transactions')
        .where('transactionCategory', isEqualTo: 'Wallet')
        .where('transactionAction', isEqualTo: action)
        .getDocuments();
    //print(queries.documents);
    return queries;
  }
}
