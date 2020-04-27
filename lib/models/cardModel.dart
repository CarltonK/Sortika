import 'package:flutter/material.dart';

enum CardType { MasterCard, Visa, Invalid }

class PaymentCard {
  CardType type;
  String number;
  String name;
  int month;
  int year;
  int cvv;
  String address;

  PaymentCard(
      {this.type,
      this.number,
      this.name,
      this.month,
      this.year,
      this.cvv,
      this.address});

  Map<String, dynamic> toJson() => {
        "cardNumber": number,
        "cardName": name,
        "cardMonth": month,
        "cardYear": year,
        "cardCvv": cvv,
        "cardAddress": address
      };
}

class CardUtils {
  static String validateCVV(String value) {
    if (value.isEmpty) {
      return 'Required';
    }

    if (value.length < 3 || value.length > 4) {
      return "Invalid";
    }
    return null;
  }

  static String validateDate(String value) {
    if (value.isEmpty) {
      return 'Required';
    }

    int year;
    int month;
    // The value contains a forward slash if the month and year has been
    // entered.
    if (value.contains(new RegExp(r'(\/)'))) {
      var split = value.split(new RegExp(r'(\/)'));
      // The value before the slash is the month while the value to right of
      // it is the year.
      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {
      // Only the month was entered
      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }

    if ((month < 1) || (month > 12)) {
      // A valid month is between 1 (January) and 12 (December)
      return 'Invalid Month';
    }

    var fourDigitsYear = convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      // We are assuming a valid should be between 1 and 2099.
      // Note that, it's valid doesn't mean that it has not expired.
      return 'Invalid';
    }

    if (!hasDateExpired(month, year)) {
      return "Expired";
    }
    return null;
  }

  /// Convert the two-digit year to four-digit year if necessary
  static int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  static bool hasDateExpired(int month, int year) {
    return !(month == null || year == null) && isNotExpired(year, month);
  }

  static bool isNotExpired(int year, int month) {
    // It has not expired if both the year and date has not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  static List<int> getExpiryDate(String value) {
    var split = value.split(new RegExp(r'(\/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    // The month has passed if:
    // 1. The year is in the past. In that case, we just assume that the month
    // has passed
    // 2. Card's month (plus another month) is more than current month.
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  static bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    // The year has passed if the year we are currently is more than card's
    // year
    return fourDigitsYear < now.year;
  }

  static String getCleanedNumber(String text) {
    RegExp regExp = new RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  static Widget getCardIcon(CardType cardType) {
    String img = "";
    Icon icon;
    switch (cardType) {
      case CardType.MasterCard:
        img = 'mastercard.jpg';
        break;
      case CardType.Visa:
        img = 'visa.png';
        break;
      case CardType.Invalid:
        // TODO: Handle this case.
        break;
    }

    Widget widget;
    if (img.isNotEmpty) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 8),
        child: new Image.asset('assets/logos/$img', width: 40.0),
      );
    } else {
      widget = icon;
    }
    return widget;
  }

  /// With the card number with Luhn Algorithm
  /// https://en.wikipedia.org/wiki/Luhn_algorithm
  static String validateCardNum(String input) {
    if (input.isEmpty) {
      return 'Required';
    }

    input = getCleanedNumber(input);

    if (input.length < 8) {
      return 'Invalid';
    }

    int sum = 0;
    int length = input.length;
    for (var i = 0; i < length; i++) {
      // get digits in reverse order
      int digit = int.parse(input[length - i - 1]);

      // every 2nd number multiply with 2
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }

    if (sum % 10 == 0) {
      return null;
    }

    return 'Invalid';
  }

  static CardType getCardTypeFrmNumber(String input) {
    CardType cardType;
    if (input.startsWith(new RegExp(
        r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
      cardType = CardType.MasterCard;
    } else if (input.startsWith(new RegExp(r'[4]'))) {
      cardType = CardType.Visa;
    } else {
      cardType = CardType.Invalid;
    }
    return cardType;
  }
}
