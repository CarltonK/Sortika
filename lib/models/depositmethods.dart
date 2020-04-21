class Deposit {
  String title;
  String subtitle;

  Deposit({this.title, this.subtitle});
}

final Deposit depoMpesaAuto =
    new Deposit(title: 'M-PESA', subtitle: 'Automatic request');
final Deposit depoMpesaManual =
    new Deposit(title: 'M-PESA', subtitle: 'Manual method');
final Deposit depoPesaLink = new Deposit(title: 'Pesalink', subtitle: '');
final Deposit depoCard = new Deposit(title: 'Card', subtitle: '');

List<Deposit> methods = [
  depoMpesaAuto,
  depoMpesaManual,
  depoPesaLink,
  depoCard
];
