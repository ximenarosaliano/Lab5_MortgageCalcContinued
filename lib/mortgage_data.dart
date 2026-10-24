import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MortgageData extends ChangeNotifier {
  String _amount = '100000.00';
  String _years = '30';
  String _rate = '3.50';
  String _rateType = 'Fixed';
  bool _includeTax = false;
  bool _agreedToTerms = false;

  String get amount => _amount;
  String get years => _years;
  String get rate => _rate;
  String get rateType => _rateType;
  bool get includeTax => _includeTax;
  bool get agreedToTerms => _agreedToTerms;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _amount = prefs.getString('amount') ?? '100000.00';
    _years = prefs.getString('years') ?? '30';
    _rate = prefs.getString('rate') ?? '3.50';
    _rateType = prefs.getString('rateType') ?? 'Fixed';
    _includeTax = prefs.getBool('includeTax') ?? false;
    _agreedToTerms = prefs.getBool('agreedToTerms') ?? false;

    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('amount', _amount);
    await prefs.setString('years', _years);
    await prefs.setString('rate', _rate);
    await prefs.setString('rateType', _rateType);
    await prefs.setBool('includeTax', _includeTax);
    await prefs.setBool('agreedToTerms', _agreedToTerms);
  }

  void updateAmount(String value) {
    _amount = value;
    notifyListeners();
    saveData();
  }

  void updateYears(String value) {
    _years = value;
    notifyListeners();
    saveData();
  }

  void updateRate(String value) {
    _rate = value;
    notifyListeners();
    saveData();
  }

  void updateRateType(String value) {
    _rateType = value;
    notifyListeners();
    saveData();
  }

  void updateTax(bool value) {
    _includeTax = value;
    notifyListeners();
    saveData();
  }
  void updateTerms(bool value){
    _agreedToTerms = value;
    notifyListeners();
    saveData();
  }

  void updateMortgage({
    required String amount,
    required String years,
    required String rate,
    required String rateType,
    required bool includeTax,
  }) {
    _amount = amount;
    _years = years;
    _rate = rate;
    _rateType = rateType;
    _includeTax = includeTax;

    notifyListeners();
    saveData();
  }
}
