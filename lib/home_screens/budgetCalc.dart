import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/budgetItem.dart';
import 'package:wealth/models/debtLevels.dart';
import 'package:wealth/utilities/styles.dart';

class BudgetCalc extends StatefulWidget {
  @override
  _BudgetCalcState createState() => _BudgetCalcState();
}

class _BudgetCalcState extends State<BudgetCalc> {
  PageController _controllerBudget, _controllerDebt;

  final _formKey = GlobalKey<FormState>();
  int _budget = 0;
  bool _isStarted = false;
  Color _startedColor = Color(0xFF73AEF5);

  String _budgetCategory;

  //Animation Duration
  final Duration duration = const Duration(milliseconds: 200);

  void _handleSubmittedBudget(String value) {
    _budget = int.parse(value);
    print('Budget: $_budget');
  }

  //Confirm Password Widget
  Widget _customGoalName() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Set up a monthly budget',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              fontSize: 18,
            )),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  decoration: boxDecorationStyle,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 60,
                  child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                        color: Colors.white,
                      )),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'You have not entered an amount';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == '0' || value == null) {
                          print('Invalid value');
                          setState(() {
                            _isStarted = false;
                          });
                        } else {
                          setState(() {
                            _isStarted = true;
                            _budget = int.parse(value);
                          });
                        }
                      },
                      onSaved: _handleSubmittedBudget,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixText: 'KES',
                          suffixStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          contentPadding: EdgeInsets.only(top: 14),
                          prefixIcon: Icon(FontAwesome5.money_bill_alt,
                              color: Colors.white),
                          hintText: 'Enter your budget',
                          hintStyle: hintStyle)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  //Budget Item
  Widget _budgetItem(IconData icon, String title, int amount) {
    return AnimatedContainer(
      duration: duration,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isStarted ? Colors.blue : _startedColor),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              child: Icon(
                icon,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.greenAccent[700])),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$title',
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '${amount.toString()} KES',
                style: labelStyle,
              ),
            ],
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }

  Widget _debtItem(String title, double amount) {
    return AnimatedContainer(
      duration: duration,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isStarted ? Colors.blue : _startedColor),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              child: Icon(
                Icons.label,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.greenAccent[700])),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$title',
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '${amount.toStringAsFixed(2)} KES',
                style: labelStyle,
              ),
            ],
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }

  int _returnFinalAmount(int budget, double rate) {
    double amt = budget * (rate / 100);
    int finalAmt = amt.toInt();
    return finalAmt;
  }

  Widget _budgetScroll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Based on your budget of ${_budget.toString()} KES, this is what we recommend',
          textAlign: TextAlign.left,
          style: GoogleFonts.muli(
              textStyle: TextStyle(
            fontSize: 18,
          )),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 80,
          child: PageView(
            scrollDirection: Axis.horizontal,
            controller: _controllerBudget,
            onPageChanged: (value) {},
            children: budgetItems
                .map((map) => _budgetItem(map.icon, map.title,
                    _returnFinalAmount(_budget, map.interest)))
                .toList(),
          ),
        ),
      ],
    );
  }

  double _returnDebtLevel(int budget, double rate) {
    return budget * rate;
  }

  Widget _debtScroll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Are you thinking of taking a loan?',
          textAlign: TextAlign.left,
          style: GoogleFonts.muli(
              textStyle: TextStyle(
            fontSize: 18,
          )),
        ),
        Text(
          'Based on your budget of ${_budget.toString()} KES, these are the debt levels we recommend',
          textAlign: TextAlign.left,
          style: GoogleFonts.muli(
              textStyle: TextStyle(
            fontSize: 18,
          )),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 80,
          child: PageView(
            scrollDirection: Axis.horizontal,
            controller: _controllerDebt,
            onPageChanged: (value) {},
            children: debtItems
                .map((map) => _debtItem(
                    map.duration, _returnDebtLevel(_budget, map.rate)))
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _controllerBudget = PageController(viewportFraction: 0.7);
    _controllerDebt = PageController(viewportFraction: 0.7);
  }

  @override
  void dispose() {
    super.dispose();
    _controllerBudget.dispose();
    _controllerDebt.dispose();
  }

  List<DropdownMenuItem> itemsCategories = [
    DropdownMenuItem(
      value: '',
      child: Text(
        'School Fees',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  Widget _budgetCategoryWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: itemsCategories,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: _budgetCategory,
        hint: Text(
          'Category',
          style: GoogleFonts.muli(textStyle: TextStyle()),
        ),
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _budgetCategory = value;
          });
          //print(goal);
        },
      ),
    );
  }

  Future _addCustomGoal() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Add a custom goal',
            textAlign: TextAlign.left,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              fontSize: 18,
            )),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _budgetCategoryWidget(),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
              ),
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () {},
                child: Text(
                  'Add',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                    fontSize: 18,
                  )),
                ))
          ],
        );
      },
    );
  }

  Widget _introBudget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Budget Calculator',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        // IconButton(
        //   icon: Icon(
        //     Icons.edit,
        //     color: Colors.greenAccent[700],
        //   ),
        //   onPressed: () => _addCustomGoal(),
        // )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _introBudget(),
              SizedBox(
                height: 30,
              ),
              _customGoalName(),
              SizedBox(
                height: 30,
              ),
              _budgetScroll(),
              SizedBox(
                height: 30,
              ),
              _debtScroll()
            ],
          ),
        ),
      ),
    );
  }
}
