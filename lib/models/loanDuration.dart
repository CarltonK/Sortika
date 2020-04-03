class LoanDuration {
  bool isSelected = false;

  String duration;

  LoanDuration(this.duration);
}

LoanDuration one = LoanDuration('1W');
LoanDuration two = LoanDuration('2W');
LoanDuration three = LoanDuration('1M');
LoanDuration four = LoanDuration('2M');
LoanDuration five = LoanDuration('3M');
LoanDuration six = LoanDuration('6M');
LoanDuration seven = LoanDuration('1Y');

List<LoanDuration> durationList = [one, two, three, four, five, six, seven];

LoanDuration one1 = LoanDuration('1M');
LoanDuration two2 = LoanDuration('3M');
LoanDuration three3 = LoanDuration('6M');
LoanDuration four4 = LoanDuration('1Y');
LoanDuration five5 = LoanDuration('2Y');
LoanDuration six6 = LoanDuration('3Y');
LoanDuration seven7 = LoanDuration('5Y');

List<LoanDuration> durationGoalList = [one1, two2, three3, four4, five5, six6, seven7];
