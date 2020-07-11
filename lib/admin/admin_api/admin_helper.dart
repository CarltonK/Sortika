import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wealth/models/bookingModel.dart';
import 'package:wealth/models/lotteryModel.dart';

class AdminHelper {
  final Firestore _firestore = Firestore.instance;

  AdminHelper() {
    print("An instance of Admin Database Helper has started");
  }

  Future<void> createLottery(LotteryModel lotteryModel) async {
    try {
      await _firestore
          .collection('lottery')
          .document()
          .setData(lotteryModel.toJson());
    } catch (e) {
      print('createLottery ERROR -> ${e.toString()}');
      return null;
    }
  }

  Future<QuerySnapshot> getAdminLotteries() async {
    try {
      QuerySnapshot queryLotteries =
          await _firestore.collection('lottery').getDocuments();
      print(queryLotteries);
      return queryLotteries;
    } catch (e) {
      print('getAdminLotteries ERROR -> ${e.toString()}');
      return null;
    }
  }

  Future<void> bookInvestment(BookingModel model) async {
    try {
      await _firestore
          .collection('bookings')
          .document()
          .setData(model.toJSON());
    } catch (e) {
      print('bookInvestment ERROR -> ${e.toString()}');
      return null;
    }
  }
}
