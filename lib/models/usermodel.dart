import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  //Initial Registration
  String fullName;
  String phone;
  String email;
  String password;
  DateTime registerDate;
  //Firebase user metadata
  String uid;
  //Account Page
  String photoURL;
  String natId;
  DateTime dob;
  String gender;
  String natIDURL;
  String kraURL;
  String platform;
  String token;

  User(
      {this.fullName,
      this.phone,
      this.email,
      this.password,
      this.registerDate,
      this.uid,
      this.photoURL,
      this.natId,
      this.dob,
      this.gender,
      this.natIDURL,
      this.kraURL,
      this.platform,
      this.token});

  factory User.fromJson(Map<String, dynamic> json) => User(
      fullName: json["fullName"],
      phone: json["phone"],
      email: json["email"],
      password: json["password"],
      registerDate: json["registerDate"],
      uid: json["uid"],
      photoURL: json["photoURL"],
      natId: json["natId"],
      dob: json["dob"],
      gender: json["gender"],
      natIDURL: json["natIDURL"],
      kraURL: json["kraURL"],
      platform: json["platform"],
      token: json["token"]);

  //Convert Dart object to JSON
  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "phone": phone,
        "email": email,
        "password": password,
        "registerDate": registerDate,
        "uid": uid,
        "photoURL": photoURL,
        "natId": natId,
        "dob": dob,
        "gender": gender,
        "natIDURL": natIDURL,
        "kraURL": kraURL,
        "platform": platform,
        "token": token
      };
}
