import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefs {
  LocalPrefs() {
    print('Initiating local preferences');
  }

  Future saveDepositDestination(String destination, String goalName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('destination', destination);
    prefs.setString('goal', goalName);
  }

  Future retrieveDestination() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String destination = prefs.getString('destination');
    String goal = prefs.getString('goal');
    Map<String, dynamic> depositKeys = {
      'destination': destination,
      'goal': goal
    };
    return depositKeys;
  }

  Future deleteDestination() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('destination');
  }
}
