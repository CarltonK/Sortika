class Goal {
  String title;
  String subtitle;

  Goal({this.title, this.subtitle});
}

Goal _savings = new Goal(title: 'Savings', subtitle: '');
Goal _investment = new Goal(title: 'Investment', subtitle: '');
Goal _loanFund = new Goal(title: 'Loan Fund', subtitle: '');
Goal _group = new Goal(title: 'Group Savings', subtitle: '');

List<Goal> goals = [_savings, _investment, _loanFund, _group];