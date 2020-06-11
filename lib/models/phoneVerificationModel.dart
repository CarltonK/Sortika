class PhoneVerificationModel {
  String uid;
  String phone;
  String genCode;

  PhoneVerificationModel({this.uid, this.phone, this.genCode});

  factory PhoneVerificationModel.fromJson(Map<String, dynamic> json) =>
      PhoneVerificationModel(
          uid: json['uid'], phone: json['phone'], genCode: json['gen_code']);

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'phone': phone,
        'gen_code': genCode,
      };
}
