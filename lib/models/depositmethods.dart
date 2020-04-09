class Deposit {
  String title;
  String subtitle;

  Deposit({this.title, this.subtitle});
}

Deposit depoMpesaAuto =
    new Deposit(title: 'M-PESA', subtitle: 'Automatic request');
Deposit depoMpesaManual =
    new Deposit(title: 'M-PESA', subtitle: 'Manual method');
Deposit depoPesaLink = new Deposit(title: 'Pesalink', subtitle: '');
Deposit depoCard = new Deposit(title: 'Card', subtitle: '');

List<Deposit> methods = [
  depoMpesaAuto,
  depoMpesaManual,
  depoPesaLink,
  depoCard
];
