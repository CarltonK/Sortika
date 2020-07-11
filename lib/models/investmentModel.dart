class InvestmentModel {
  String title;
  String subtitle;
  List<dynamic> types;

  InvestmentModel({this.types, this.title, this.subtitle});

  factory InvestmentModel.fromJson(Map<String, dynamic> json) =>
      InvestmentModel(
          title: json["title"],
          types: json["types"],
          subtitle: json["subtitle"]);
}
