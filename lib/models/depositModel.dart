class DepositModel {
  String destination;
  String goalName;
  String method;
  //Common for all methods
  double amount;
  //Somewhat common for all methods
  String phone;

  DepositModel(
      {this.destination, this.goalName, this.method, this.amount, this.phone});

  factory DepositModel.fromJson(Map<String, dynamic> json) => DepositModel(
      amount: json['amount'],
      destination: json['destination'],
      goalName: json['goalName'],
      method: json['method'],
      phone: json['phone']);

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'destination': destination,
        'goalName': goalName,
        'method': method,
        'phone': phone
      };
}
