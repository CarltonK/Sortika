import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wealth/models/usermodel.dart';

class AuthService with ChangeNotifier {
  //Identify current user
  FirebaseUser currentUser;

  //create instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //create instance of Firestore
  final Firestore _firestore = Firestore.instance;

  //Initialize class
  AuthService() {
    print("An instance of AuthService has started");
  }

  //Return a user
  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  //Logout call
  Future logout() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('uid');
    this.currentUser = null;
    _auth.signOut();
    notifyListeners();
    return Future.value(currentUser);
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

      //Initiate email verification
      currentUser.sendEmailVerification();

      //print('Positive Registration Response: ${currentUser.uid}');
      //Try adding the user to the Firestore
      await saveUser(user, uid);
      notifyListeners();
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
    int passLength = user.password.length;
    user.password = 'X' * passLength;

    //Set uid to user model
    user.uid = uid;
    try {
      await _firestore.collection("users").document(uid).setData(user.toJson());
      print("The user was successfully saved");
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

      //Check if email is verified before proceeding
      bool emailVerificationStatus = currentUser.isEmailVerified;

      if (emailVerificationStatus) {
        notifyListeners();
        return Future.value(currentUser);
      } else {
        return 'Please verify your email before signing in. We sent you an email earlier';
      }
    } catch (e) {
      var response;
      if (e.toString().contains("ERROR_WRONG_PASSWORD")) {
        response = 'Invalid credentials. Please try again';
        //print('Negative Response: $response');
      }
      if (e.toString().contains("ERROR_INVALID_EMAIL")) {
        response = 'The email format entered is invalid';
        //print('Negative Response: $response');
      }
      if (e.toString().contains("ERROR_USER_NOT_FOUND")) {
        response = 'Please register first';
        //print('Negative Response: $response');
      }
      if (e.toString().contains("ERROR_USER_DISABLED")) {
        response = 'Your account has been disabled';
        //print('Negative Response: $response');
      }
      if (e.toString().contains("ERROR_TOO_MANY_REQUESTS")) {
        response = 'Too many requests. Please try again in 2 minutes';
        //print('Negative Response: $response');
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
}
