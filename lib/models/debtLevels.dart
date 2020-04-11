class Debt {
  String duration;
  double rate;

  Debt({this.duration, this.rate});
}

Debt _month = Debt(duration: 'Monthly', rate: (15.92 / 100));
Debt _semiAnnually = Debt(duration: 'Half Year', rate: (15.92 / 100) * 6);
Debt _annually = Debt(duration: 'Yearly', rate: (15.92 / 100) * 12);
Debt _triAnnually = Debt(duration: '3 Years', rate: (15.92 / 100) * 36);
Debt _pentaAnnually = Debt(duration: '5 Years', rate: (15.92 / 100) * 60);

List<Debt> debtItems = [
  _month,
  _semiAnnually,
  _annually,
  _triAnnually,
  _pentaAnnually
];
