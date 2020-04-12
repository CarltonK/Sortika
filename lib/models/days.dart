class Days {
  String day;
  bool selected = false;

  Days({this.day, this.selected});
}

Days mon = Days(day: 'Monday', selected: false);
Days tue = Days(day: 'Tuesday', selected: false);
Days wed = Days(day: 'Wednesday', selected: false);
Days thu = Days(day: 'Thuesday', selected: false);
Days fri = Days(day: 'Friday', selected: false);
Days sat = Days(day: 'Saturday', selected: false);
Days sun = Days(day: 'Sunday', selected: false);

List<Days> allDays = [mon, tue, wed, thu, fri, sat, sun];
