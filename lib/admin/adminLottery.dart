import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:wealth/admin/admin_api/admin_helper.dart';
import 'package:wealth/models/lotteryModel.dart';
import 'package:wealth/widgets/unsuccessfull_error.dart';
import 'package:wealth/admin/createLottery.dart';

class LotteryView extends StatefulWidget {
  @override
  _LotteryViewState createState() => _LotteryViewState();
}

class _LotteryViewState extends State<LotteryView> {
  Future<QuerySnapshot> queryLottery;
  AdminHelper helper = new AdminHelper();

  Widget singleItem(DocumentSnapshot doc) {
    LotteryModel model = LotteryModel.fromJson(doc.data);

    //Date Parsing and Formatting
    Timestamp dateRetrieved = model.end;
    var formatter = new DateFormat('EEE d MMM y HH:MM');
    String date = formatter.format(dateRetrieved.toDate());

    return ListTile(
      leading: Icon(
        Icons.label_important,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(model.name),
      isThreeLine: true,
      subtitle: Text('Ends on ' + date),
    );
  }

  @override
  void initState() {
    super.initState();
    queryLottery = helper.getAdminLotteries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<QuerySnapshot>(
          future: queryLottery,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.none:
                return UnsuccessfullError(
                  message: 'There are no lotteries',
                );
              case ConnectionState.done:
                return ListView(
                  children: snapshot.data.documents
                      .map((lotItem) => singleItem(lotItem))
                      .toList(),
                );
              default:
                return SpinKitDoubleBounce(
                  color: Theme.of(context).primaryColor,
                  size: 200,
                );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CreateLottery(),
        )),
        child: Icon(Icons.create),
        tooltip: 'New Lottery',
      ),
    );
  }
}
