import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/loanDuration.dart';
import 'package:wealth/utilities/styles.dart';

class GroupSavings extends StatefulWidget {
  @override
  _GroupSavingsState createState() => _GroupSavingsState();
}

class _GroupSavingsState extends State<GroupSavings> {
  //FocusNodes
  final focusObjective = FocusNode();

  //Identifiers
  String _name, _objective;
  String _amount, _amountpp;

  //Members
  double members = 1;

  //Group Registration status
  bool _isRegistered = false;
  bool _canSeeSavings = false;

  //Handle Name Input
  void _handleSubmittedName(String value) {
    _name = value;
    print('Group Name: ' + _name);
  }

  //Handle Objective Input
  void _handleSubmittedObjective(String value) {
    _objective = value;
    print('Group Objective: ' + _objective);
  }

  //Handle Amount Input
  void _handleSubmittedAmount(String value) {
    _amount = value;
    print('Amount: ' + _amount);
  }

  //Handle Amount Per person Input
  void _handleSubmittedAmountpp(String value) {
    _amountpp = value;
    print('Amount pp: ' + _amountpp);
  }

  //Group Name
  Widget _groupName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Group Name',
          style: labelStyle,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: boxDecorationStyle,
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.text,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(focusObjective);
              },
              textInputAction: TextInputAction.next,
              onSaved: _handleSubmittedName,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(
                    Icons.group_add,
                    color: Colors.white54,
                  ),
                  hintText: 'Give your group a name',
                  hintStyle: hintStyle)),
        )
      ],
    );
  }

  //Group Name
  Widget _groupObjective() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Group Objective',
          style: labelStyle,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: boxDecorationStyle,
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.text,
              maxLines: 2,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
              onSaved: _handleSubmittedObjective,
              focusNode: focusObjective,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(
                    Icons.group_add,
                    color: Colors.white54,
                  ),
                  hintText: 'What is main objective',
                  hintStyle: hintStyle)),
        )
      ],
    );
  }

  //Target Amount
  //Group Name
  Widget _groupTargetAmount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Target Amount',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.centerLeft,
            decoration: boxDecorationStyle,
            height: 60,
            child: TextFormField(
                keyboardType: TextInputType.number,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.white,
                )),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                onSaved: _handleSubmittedAmount,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14),
                    prefixIcon: Icon(
                      Icons.monetization_on,
                      color: Colors.white54,
                    ),
                    hintText: 'Enter amount',
                    hintStyle: hintStyle)),
          )
        ],
      ),
    );
  }

  //Target Amount
  //Group Name
  Widget _groupTargetAmountpp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Minimum amount per person',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.centerLeft,
            decoration: boxDecorationStyle,
            height: 60,
            child: TextFormField(
                keyboardType: TextInputType.number,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.white,
                )),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                onSaved: _handleSubmittedAmountpp,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14),
                    prefixIcon: Icon(
                      Icons.monetization_on,
                      color: Colors.white54,
                    ),
                    hintText: 'Enter amount',
                    hintStyle: hintStyle)),
          )
        ],
      ),
    );
  }

  //Group target membership
  Widget _groupMemberTarget() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Slider.adaptive(
              value: members,
              inactiveColor: Colors.white,
              divisions: 10,
              min: 1,
              max: 10,
              label: members.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  members = value;
                });
              }),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Row(
                children: <Widget>[
                  Text(
                    '${members.toInt().toString()}',
                    style: labelStyle,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    members.toInt() == 1 ? Icons.person : Icons.people,
                    color: Colors.white,
                  )
                ],
              ),
            ))
      ],
    );
  }

  //Widget Savings Period
  Widget _savingsPeriod() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Period',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.purple, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 70,
            child: ListView.builder(
              itemCount: durationList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    if (durationList.any((item) => item.isSelected)) {
                      setState(() {
                        durationList[index].isSelected =
                            !durationList[index].isSelected;
                      });
                    } else {
                      setState(() {
                        durationList[index].isSelected = true;
                      });
                    }
                    print(durationList[index].duration);
                  },
                  child: Card(
                    color: durationList[index].isSelected
                        ? Colors.white70
                        : Colors.white12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      width: 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.calendar_today,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '${durationList[index].duration}',
                            style: GoogleFonts.muli(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    letterSpacing: 2)),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  //Group Registration Status
  Widget _groupRegistrationStatus() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Text(
            'Is this group registered?',
            style: labelStyle,
          ),
        ),
        Expanded(
            child: Container(
          child: Row(
            children: <Widget>[
              Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.white),
                  child: Checkbox(
                      value: _isRegistered,
                      checkColor: Colors.greenAccent[700],
                      activeColor: Colors.white,
                      onChanged: (bool value) {
                        setState(() {
                          _isRegistered = value;
                        });
                      })),
            ],
          ),
        ))
      ],
    );
  }

  //Widget Group Permissions. Should members see savings total
  Widget _shouldMembersSeeTotal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Text(
              'Should members see total savings?',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.purple, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
              child: Container(
            child: Row(
              children: <Widget>[
                Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.purple),
                    child: Checkbox(
                        value: _canSeeSavings,
                        checkColor: Colors.white,
                        activeColor: Colors.purple,
                        onChanged: (bool value) {
                          setState(() {
                            _canSeeSavings = value;
                          });
                        })),
              ],
            ),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _groupName(),
              SizedBox(
                height: 30,
              ),
              _groupObjective(),
              SizedBox(
                height: 20,
              ),
              Text(
                'How many members are you targeting?',
                style: labelStyle,
              ),
              SizedBox(
                height: 8,
              ),
              _groupMemberTarget(),
              _groupRegistrationStatus(),
              Card(
                child: ExpansionTile(
                  leading: Icon(
                    Icons.settings,
                    color: Colors.purple,
                  ),
                  title: Text(
                    'Group Settings',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.purple,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  children: <Widget>[
                    _groupTargetAmount(),
                    SizedBox(
                      height: 10,
                    ),
                    _savingsPeriod(),
                    SizedBox(
                      height: 10,
                    ),
                    _groupTargetAmountpp(),
                    _shouldMembersSeeTotal()
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () {},
                color: Color(0xFF6CA8F1),
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Send invitations',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
