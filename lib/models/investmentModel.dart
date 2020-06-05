class InvestmentModel {
  String title;
  List<dynamic> types;

  InvestmentModel({this.types, this.title});

  factory InvestmentModel.fromJson(Map<String, dynamic> json) =>
      InvestmentModel(title: json["title"], types: json["types"]);
}
