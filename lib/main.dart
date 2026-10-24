//Ximena Rosaliano
//LAB 5 - Mortgage Calc with Statement Management
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'mortgage_data.dart';
import 'modify_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final mortgageData = MortgageData();
  await mortgageData.loadData();

  runApp(
    ChangeNotifierProvider(
      create: (context) => mortgageData,
      child: MortgageApp(),
    ),
  );
}

class MortgageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mortgage Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: false,
      ),
      home: MortgageCalculator(),
    );
  }
}

class MortgageCalculator extends StatefulWidget {
  @override
  _MortgageCalculatorState createState() =>
      _MortgageCalculatorState();
}

class _MortgageCalculatorState extends State<MortgageCalculator> {
  late TextEditingController _priceController;
  late TextEditingController _yearsController;
  late TextEditingController _rateController;

  String _result = '0.00';
  String _totalResult = '0.00';

  @override
  void initState() {
    super.initState();

    final data = context.read<MortgageData>();

    _priceController =
        TextEditingController(text: data.amount);
    _yearsController =
        TextEditingController(text: data.years);
    _rateController =
        TextEditingController(text: data.rate);

    _priceController.addListener(_updateAmount);
    _yearsController.addListener(_updateYears);
    _rateController.addListener(_updateRate);

    WidgetsBinding.instance.addPostFrameCallback((_){
      if (mounted) {
        _calculateMortgage();
      }
    });
  }

  void _updateAmount() {
    context.read<MortgageData>()
        .updateAmount(_priceController.text);
  }

  void _updateYears() {
    context.read<MortgageData>()
        .updateYears(_yearsController.text);
  }

  void _updateRate() {
    context.read<MortgageData>()
        .updateRate(_rateController.text);
  }

  void _calculateMortgage() {
    final data = context.read<MortgageData>();

    if (!data.agreedToTerms) {
      setState(() {
        _result = '0.00';
        _totalResult = '0.00';
      });
      return;
    }

    double amount = double.tryParse(data.amount) ?? 0;
    int years = int.tryParse(data.years) ?? 0;
    double rate = double.tryParse(data.rate) ?? -1;

    if (amount <= 0 || years <= 0 || rate < 0 || !amount.isFinite || !rate.isFinite) {
      setState(() {
        _result = '0.00';
        _totalResult = '0.00';
      });
      return;
    }

    int months = years * 12;
    double monthlyRate = rate / 100 / 12;
    double payment;

    if (monthlyRate == 0) {
      payment = amount / months;
    } else {
      payment = amount * monthlyRate /
          (1 - pow(1 + monthlyRate, -months));
    }

    if (data.includeTax) {
      payment += 150;
    }

    double total = payment * months;

    setState(() {
      _result = payment.toStringAsFixed(2);
      _totalResult = total.toStringAsFixed(2);
    });
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: const Text(
            'Select Agree, to calculate Mortgage Monthly '
                'Payment and Total Payment.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<MortgageData>().updateTerms(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<MortgageData>().updateTerms(true);
                _calculateMortgage();
              },
              child: const Text('Agree'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(
        decimal: label != 'Years',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MortgageData>();

    if (_priceController.text != data.amount) {
      _priceController.value = TextEditingValue(
        text: data.amount,
        selection: TextSelection.collapsed(
          offset: data.amount.length,
        ),
      );
    }

    if (_yearsController.text != data.years) {
      _yearsController.value = TextEditingValue(
        text: data.years,
        selection: TextSelection.collapsed(
          offset: data.years.length,
        ),
      );
    }

    if (_rateController.text != data.rate) {
      _rateController.value = TextEditingValue(
        text: data.rate,
        selection: TextSelection.collapsed(
          offset: data.rate.length,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortgage Calculator'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_priceController, 'Amount'),
              const SizedBox(height: 15),

              _buildTextField(_yearsController, 'Years'),
              const SizedBox(height: 15),

              _buildTextField(
                  _rateController, 'Interest Rate %'),
              const SizedBox(height: 20),

              Text(
                'Rate Type: ${data.rateType}',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 10),
              const Divider(
                color: Colors.purple,
                thickness: 3,
              ),
              const SizedBox(height: 15),

              Text(
                'Monthly Payment: \$$_result',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),

              Text(
                'Total Payment: \$$_totalResult',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 15),

              CheckboxListTile(
                title: const Text('Terms and Conditions'),
                value: data.agreedToTerms,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  if (value == true) {
                    _showTermsDialog();
                  } else {
                    setState(() {
                      context.read<MortgageData>().updateTerms(false);
                      _calculateMortgage();
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              Center(
                child: MaterialButton(
                  color: Colors.grey.shade300,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModifyScreen(),
                      ),
                    );

                    if (!mounted) return;

                    // Provider already has the modified data
                    _calculateMortgage();
                  },
                  child: const Text('MODIFY DATA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _priceController.removeListener(_updateAmount);
    _yearsController.removeListener(_updateYears);
    _rateController.removeListener(_updateRate);

    _priceController.dispose();
    _yearsController.dispose();
    _rateController.dispose();
    super.dispose();
  }
}
