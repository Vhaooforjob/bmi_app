import 'package:flutter/material.dart';
import 'bmi_result_page.dart';

class BmiHomePage extends StatefulWidget {
  const BmiHomePage({super.key});

  @override
  State<BmiHomePage> createState() => _BmiHomePageState();
}

class _BmiHomePageState extends State<BmiHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _calc() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final h = double.parse(_heightCtrl.text) / 100;
    final w = double.parse(_weightCtrl.text);
    final bmi = w / (h * h);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => BmiResultPage(bmi: bmi)));
  }

  String? _v(String? v) {
    if (v == null || v.trim().isEmpty) return 'Không để trống';
    final x = double.tryParse(v);
    if (x == null || x <= 0) return 'Không hợp lệ';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tính BMI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _heightCtrl,
                decoration: const InputDecoration(labelText: 'Chiều cao (cm)'),
                validator: _v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightCtrl,
                decoration: const InputDecoration(labelText: 'Cân nặng (kg)'),
                validator: _v,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calc,
                  child: const Text('Tính'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
