import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth/analytics/analytics_funnels.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/autoCreateModel.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/models/notificationModel.dart';
import 'package:wealth/models/usermodel.dart';

class AuthService {
  //Identify current user
  FirebaseUser currentUser;
  //create instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //create instance of Firestore
  final Firestore _firestore = Firestore.instance;
  //Analytics
  final AnalyticsFunnel funnel = AnalyticsFunnel();
  //Google Sign In
  final GoogleSignIn googleSignIn = GoogleSignIn();
  //Messaging
  final FirebaseMessaging fcm = FirebaseMessaging();

  static DateTime now = DateTime.now();
  DateTime monthsAgo = now.subtract(Duration(days: 180));
  DateTime oneYearFromNow = now.add(Duration(days: 365));

  //Initialize class
  AuthService() {
    print("An instance of AuthService has started");
  }

  //Return a user
  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  //Logout call
  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
    var result = await _auth.signOut();
    //notifyListeners();
    return result;
  }

  /*
  USER REGISTRATION
  */
  //Create User
  Future createUserEmailPass(User user) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: user.email, password: user.password);

      //The User has registered successfully
      currentUser = result.user;

      //Get the uid
      String uid = currentUser.uid;

      //Log an Analytics Event signalling SIGN UP
      await funnel.logSignUp(uid);

      //Initiate email verification
      currentUser.sendEmailVerification();

      //print('Positive Registration Response: ${currentUser.uid}');
      //Try adding the user to the Firestore
      await saveUser(user, uid);
      //notifyListeners();
      return Future.value(currentUser);
    } catch (e) {
      var response;
      if (e.toString().contains("ERROR_WEAK_PASSWORD")) {
        response = 'Your password is weak. Please choose another';
        //print('Negative Response: $response');
      }
      if (e.toString().contains("ERROR_INVALID_EMAIL")) {
        response = 'The email format entered is invalid';
        //print('Negative Response: $response');
      }
      if (e.toString().contains("ERROR_EMAIL_ALREADY_IN_USE")) {
        response = 'An account with the same email exists';
        //print('Negative Response: $response');
      }
      return response;
    }
  }

  //Save the User as a document in the "users" collection
  Future saveUser(User user, String uid) async {
    //Remove password from user class and replace with 'XXXXX'
    user.password = null;
    //Set uid to user model
    user.uid = uid;
    try {
      await _firestore.collection("users").document(uid).setData(user.toJson());
    } catch (e) {
      print("The user was not successfully saved");
      print("This is the error ${e.toString()}");
    }
  }

  /*
  USER LOGIN
  */
  //Sign In
  Future signInEmailPass(User user) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: user.email, password: user.password);
      currentUser = result.user;
      // result.user.getIdToken();

      //Check if email is verified before proceeding
      bool emailVerificationStatus = currentUser.isEmailVerified;

      if (emailVerificationStatus) {
        //notifyListeners();
        return Future.value(currentUser);
      } else {
        return 'Please verify your email before signing in. We sent you an email earlier';
      }
    } catch (e) {
      var response;
      if (e.toString().contains("ERROR_WRONG_PASSWORD")) {
        response = 'Invalid credentials. Please try again';
      }
      if (e.toString().contains("ERROR_INVALID_EMAIL")) {
        response = 'The email format entered is invalid';
      }
      if (e.toString().contains("ERROR_USER_NOT_FOUND")) {
        response = 'Please register first';
      }
      if (e.toString().contains("ERROR_USER_DISABLED")) {
        response = 'Your account has been disabled';
      }
      if (e.toString().contains("ERROR_TOO_MANY_REQUESTS")) {
        response = 'Too many requests. Please try again in 2 minutes';
      }
      return response;
    }
  }

  /*
  USER PASSWORD RESET
  */
  Future resetPass(User user) async {
    var response;
    try {
      await _auth.sendPasswordResetEmail(email: user.email);
      await funnel.logEvent('Password Reset', user.email);
      response = true;
      return response;
    } catch (e) {
      if (e.toString().contains("ERROR_INVALID_EMAIL")) {
        response = 'Invalid Email. Please enter the correct email';
        //print('Negative Response: $response');
      }
      if (e.toString().contains("ERROR_USER_NOT_FOUND")) {
        response = 'Please register first';
        //print('Negative Response: $response');
      }
      return response;
    }
  }

  /*
  GOOGLE SIGN IN
  */
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      await _firestore
          .collection('users')
          .document(user.uid)
          .get()
          .then((value) async {
        if (value.exists) {
          print('A user already exists -> ${user.email}');
        } else {
          print('Let\'s create a new user');
          String token = await fcm.getToken();
          User model = new User(
            fullName: user.displayName,
            phone: user.phoneNumber,
            phoneVerified: false,
            designation: null,
            registerDate: Timestamp.fromDate(DateTime.now()),
            loanLimitRatio: 75,
            token: token,
            lastLogin: Timestamp.fromDate(monthsAgo),
            points: 100,
            passiveSavingsRate: 5,
            platform: Platform.operatingSystem,
            dailySavingsTarget: 0,
            dailyTarget: 0,
            weeklyTarget: 0,
            monthlyTarget: 0,
            photoURL: user.photoUrl,
            email: user.email,
          );
          await saveUser(model, user.uid);
        }
      });
      return user;
    } catch (e) {
      print('signInWithGoogle ERROR -> ${e.toString()}');
      return null;
    }
  }

  /*
  USER ACTIVITY
  */
  Future postActivity(String uid, ActivityModel activity) async {
    //Activities will be posted in user subcollection
    final String collectionUpper = "users";
    final String collectionLower = "activity";
    await _firestore
        .collection(collectionUpper)
        .document(uid)
        .collection(collectionLower)
        .document()
        .setData(activity.toJson());
  }

  Future postNotification(String uid, NotificationModel activity) async {
    //Activities will be posted in user subcollection
    final String collectionUpper = "users";
    final String collectionLower = "notifications";
    await _firestore
        .collection(collectionUpper)
        .document(uid)
        .collection(collectionLower)
        .document()
        .setData(activity.toJson());
  }

  Future<void> createAutoGoal(AutoCreateModel model) async {
    //Analytics Event - LOG EVENT
    await funnel.logEvent('Autocreate Goals', model.uid);
    await _firestore
        .collection("autocreates")
        .document()
        .setData(model.toJson());
  }
}
