import 'package:cloud_firestore/cloud_firestore.dart';

class Helper {
  //create instance of Firestore
  final Firestore _firestore = Firestore.instance;

  //Initialize class
  Helper() {
    print("An instance of Database Helper has started");
  }

  //Retrieve Investment data to populate graph
  Future<QuerySnapshot> getInvestmentGraphData(String uid) async {
    QuerySnapshot queries = await _firestore
        .collection('users')
        .document(uid)
        .collection('goals')
        .where('goalCategory', isEqualTo: 'Investment')
        .getDocuments();
    return queries;
  }

  //Retrieve Investment data to populate pie chart
  Future<QuerySnapshot> getPieChartData(String uid) async {
    QuerySnapshot queries = await _firestore
        .collection("users")
        .document(uid)
        .collection("goals")
        .where("goalCategory", isEqualTo: 'Investment')
        .getDocuments();
    //print(queries.documents[0].data);
    return queries;
  }
}
