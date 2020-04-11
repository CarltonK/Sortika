import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class BudgetItem {
  String title;
  int amount;
  double interest;
  IconData icon;

  BudgetItem({this.title, this.amount, this.icon, this.interest});
}

/*
Food and Dining
Transport
Health and Personal Care
Home and Living
Government
Bills
Cash transfers
Leisure
Family
Shopping

*/

BudgetItem _dining = new BudgetItem(
    icon: Icons.restaurant, amount: 0, title: 'Food', interest: 15);

BudgetItem _transport = new BudgetItem(
    icon: Icons.directions_bus, amount: 0, title: 'Transport', interest: 10);

BudgetItem _health = new BudgetItem(
    icon: Icons.healing, amount: 0, title: 'Wellness', interest: 6);

BudgetItem _home = new BudgetItem(
    icon: Icons.home, amount: 0, title: 'Housing', interest: 22.5);

BudgetItem _bills = new BudgetItem(
    icon: Icons.account_balance, amount: 0, title: 'Bills', interest: 5);

BudgetItem _charity = new BudgetItem(
    icon: Icons.people, amount: 0, title: 'Charity', interest: 12);

BudgetItem _savings = new BudgetItem(
    icon: FontAwesome5.money_bill_alt,
    amount: 0,
    title: 'Savings',
    interest: 17);

BudgetItem _leisure = new BudgetItem(
    icon: Icons.sentiment_very_satisfied,
    amount: 0,
    title: 'Leisure',
    interest: 12.5);

List<BudgetItem> budgetItems = [
  _home,
  _dining,
  _savings,
  _charity,
  _transport,
  _bills,
  _leisure,
  _health,
];
