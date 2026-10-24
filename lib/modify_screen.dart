import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mortgage_data.dart';

class ModifyScreen extends StatefulWidget {
  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  late TextEditingController _amountController;

  late int _years;
  late double _rate;
  late String _interestType;
  late bool _includeTax;

  @override
  void initState() {
    super.initState();

    final data = context.read<MortgageData>();

    _amountController =
        TextEditingController(text: data.amount);

    _years = int.tryParse(data.years) ?? 30;
    if (![10, 15, 30].contains(_years)) {
      _years = 30;
    }

    _rate = double.tryParse(data.rate) ?? 3.50;
    _interestType = data.rateType;
    _includeTax = data.includeTax;
  }

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Years',
                style: TextStyle(fontSize: 16),
              ),

              Row(
                children: [
                  Radio<int>(
                    value: 10,
                    groupValue: _years,
                    onChanged: (value) {
                      setState(() => _years = value!);
                    },
                  ),
                  const Text('10'),

                  Radio<int>(
                    value: 15,
                    groupValue: _years,
                    onChanged: (value) {
                      setState(() => _years = value!);
                    },
                  ),
                  const Text('15'),

                  Radio<int>(
                    value: 30,
                    groupValue: _years,
                    onChanged: (value) {
                      setState(() => _years = value!);
                    },
                  ),
                  const Text('30'),
                ],
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _amountController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Rate Type',
                style: TextStyle(fontSize: 16),
              ),

              RadioListTile<String>(
                title: const Text('Fixed'),
                value: 'Fixed',
                groupValue: _interestType,
                onChanged: (value) {
                  setState(() => _interestType = value!);
                },
              ),

              RadioListTile<String>(
                title: const Text('Variable'),
                value: 'Variable',
                groupValue: _interestType,
                onChanged: (value) {
                  setState(() => _interestType = value!);
                },
              ),

              CheckboxListTile(
                title: const Text('Include Tax (+\$150/mo)'),
                value: _includeTax,
                controlAffinity:
                ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() => _includeTax = value!);
                },
              ),

              const SizedBox(height: 15),

              Text(
                'Interest Rate: ${(_rate / 100).toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 10),

              Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: ListView.builder(
                  itemCount: 53,
                  itemBuilder: (context, index) {
                    double option = 2.0 + index * 0.25;

                    return ListTile(
                      title: Text(
                        '${option.toStringAsFixed(2)}%',
                      ),
                      selected: _rate == option,
                      selectedTileColor: Colors.purple.shade50,
                      onTap: () {
                        setState(() => _rate = option);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: MaterialButton(
                  color: Colors.grey.shade300,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black),
                  ),
                  onPressed: () {
                    double amount = double.tryParse(
                      _amountController.text,
                    ) ??
                        0;

                    if (amount <= 0 || !amount.isFinite) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid amount'),
                        ),
                      );
                      return;
                    }

                    context.read<MortgageData>().updateMortgage(
                      amount: _amountController.text,
                      years: _years.toString(),
                      rate: _rate.toStringAsFixed(2),
                      rateType: _interestType,
                      includeTax: _includeTax,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('DONE'),
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
    _amountController.dispose();
    super.dispose();
  }
}
