class BankModel {
  String bankName;
  String bankBranch;
  String bankCode;
  String bankSwiftCode;
  String bankAccountName;
  String bankAccountNumber;

  BankModel(
      {this.bankName,
      this.bankBranch,
      this.bankCode,
      this.bankSwiftCode,
      this.bankAccountNumber,
      this.bankAccountName});

  Map<String, dynamic> toJson() => {
        "bankName": bankName,
        "bankBranch": bankBranch,
        "bankCode": bankCode,
        "bankSwiftCode": bankSwiftCode,
        "bankAccountName": bankAccountName,
        "bankAccountNumber": bankAccountNumber
      };
}
