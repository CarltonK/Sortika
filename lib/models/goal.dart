class Goal {
  String title;
  String subtitle;

  Goal({this.title, this.subtitle});
}

Goal _savings = new Goal(title: 'Savings', subtitle: 'Define your life goals');
Goal _investment =
    new Goal(title: 'Investment', subtitle: 'Invest to grow your wealth');
Goal _group =
    new Goal(title: 'Group Savings', subtitle: 'Together we are stronger');

List<Goal> goals = [_savings, _investment, _group];
