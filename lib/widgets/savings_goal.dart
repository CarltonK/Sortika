import 'package:flutter/material.dart';

class SavingsGoal extends StatefulWidget {
  @override
  _SavingsGoalState createState() => _SavingsGoalState();
}

class _SavingsGoalState extends State<SavingsGoal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[],
      ),
    );
  }
}
