import 'package:flutter/material.dart';

class BudgetItem {
  String title;
  int amount;
  IconData icon;
  bool isActive = false;

  BudgetItem({this.title, this.amount, this.icon});
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
Loans

*/

BudgetItem _dining =
    new BudgetItem(icon: Icons.restaurant, amount: 0, title: 'Food');
BudgetItem _transport =
    new BudgetItem(icon: Icons.directions_bus, amount: 0, title: 'Transport');
BudgetItem _health =
    new BudgetItem(icon: Icons.healing, amount: 0, title: 'Health');
BudgetItem _home = new BudgetItem(icon: Icons.home, amount: 0, title: 'Home');
BudgetItem _government =
    new BudgetItem(icon: Icons.business_center, amount: 0, title: 'Government');
BudgetItem _bills =
    new BudgetItem(icon: Icons.account_balance, amount: 0, title: 'Bills');
BudgetItem _transfers =
    new BudgetItem(icon: Icons.devices_other, amount: 0, title: 'Transfers');
BudgetItem _leisure = new BudgetItem(
    icon: Icons.sentiment_very_satisfied, amount: 0, title: 'Leisure');
BudgetItem _family =
    new BudgetItem(icon: Icons.people, amount: 0, title: 'Family');
BudgetItem _shopping =
    new BudgetItem(icon: Icons.shopping_cart, amount: 0, title: 'Shopping');
BudgetItem _loans =
    new BudgetItem(icon: Icons.receipt, amount: 0, title: 'Loans');

List<BudgetItem> budgetItems = [
  _dining,
  _transport,
  _health,
  _home,
  _government,
  _bills,
  _transfers,
  _leisure,
  _family,
  _shopping,
  _loans
];
