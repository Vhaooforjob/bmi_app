import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../application/bmi_controller.dart';
import '../../../core/auth/token_storage.dart';

class BmiHomePage extends StatefulWidget {
  const BmiHomePage({super.key});

  @override
  State<BmiHomePage> createState() => _BmiHomePageState();
}

class _BmiHomePageState extends State<BmiHomePage> {
  final heightCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String sex = 'average';
  String activity = 'sedentary';
  final mealSplits = [
    {'id': 'breakfast', 'name': 'Bữa sáng', 'percent': 30},
    {'id': 'lunch', 'name': 'Bữa trưa', 'percent': 40},
    {'id': 'dinner', 'name': 'Bữa tối', 'percent': 30},
  ];

  bool showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    heightCtrl.dispose();
    weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final userId = await TokenStorage().getUserId();
    if (userId != null && mounted) {
      await context.read<BmiController>().fetchHistory(userId);
      final current = context.read<BmiController>().current;
      if (current != null) {
        heightCtrl.text = current.heightCm.toString();
        weightCtrl.text = current.weightKg.toString();
      }
    }
  }

  int _mealTotal() =>
      mealSplits.fold<int>(0, (sum, m) => sum + (m['percent'] as int));

  Color _bmiColor(double bmi, String bmiClass) {
    if (bmiClass.toLowerCase() == 'normal') {
      return Colors.blue;
    }
    if (bmi >= 18.5 && bmi < 23) {
      return Colors.green;
    }
    return const Color.fromARGB(255, 206, 156, 5);
  }

  Future<void> _onCalculate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId = await TokenStorage().getUserId();
    if (userId == null) return;

    final h = int.parse(heightCtrl.text);
    final w = int.parse(weightCtrl.text);

    final ctrl = context.read<BmiController>();

    if (showAdvanced) {
      final sum = _mealTotal();
      if (sum != 100 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tổng % bữa ăn đang là $sum%, nên bằng 100%')),
        );
      }
      await ctrl.calculateAdvanced(
        userId: userId,
        height: h,
        weight: w,
        sex: sex,
        activity: activity,
        mealSplit: mealSplits,
      );
    } else {
      await ctrl.calculate(userId, h, w);
    }
  }

  InputDecoration _dec(BuildContext ctx, String label, IconData icon) {
    final cs = Theme.of(ctx).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: cs.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BmiController>();
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final current = ctrl.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI & Calories'),
        actions: [
          IconButton(
            tooltip: showAdvanced ? 'Ẩn nâng cao' : 'Hiện nâng cao',
            icon: AnimatedRotation(
              turns: showAdvanced ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.tune, color: cs.primary),
            ),
            onPressed: () => setState(() => showAdvanced = !showAdvanced),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (current != null)
              Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: _bmiColor(
                          current.bmi,
                          current.bmiClass,
                        ),
                        child: Text(
                          current.bmi.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          runSpacing: 6,
                          spacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Chip(
                              label: Text(current.bmiClass),
                              backgroundColor: _bmiColor(
                                current.bmi,
                                current.bmiClass,
                              ).withOpacity(0.12),
                              side: BorderSide(
                                color: _bmiColor(current.bmi, current.bmiClass),
                              ),
                              labelStyle: TextStyle(
                                color: _bmiColor(current.bmi, current.bmiClass),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text('BMR: ${current.bmrKcal} kcal'),
                            Text('TDEE: ${current.tdeeKcal} kcal'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (current != null) const SizedBox(height: 16),

            Card(
              elevation: 0,
              color: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: heightCtrl,
                              decoration: _dec(
                                context,
                                'Chiều cao (cm)',
                                Icons.height,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n <= 0)
                                  return 'Nhập chiều cao hợp lệ';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: weightCtrl,
                              decoration: _dec(
                                context,
                                'Cân nặng (kg)',
                                Icons.monitor_weight,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n <= 0)
                                  return 'Nhập cân nặng hợp lệ';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      AnimatedCrossFade(
                        crossFadeState:
                            showAdvanced
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 220),
                        firstChild: Column(
                          children: [
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: sex,
                              items: const [
                                DropdownMenuItem(
                                  value: 'male',
                                  child: Text('Nam'),
                                ),
                                DropdownMenuItem(
                                  value: 'female',
                                  child: Text('Nữ'),
                                ),
                                DropdownMenuItem(
                                  value: 'average',
                                  child: Text('Khác'),
                                ),
                              ],
                              onChanged: (v) => setState(() => sex = v!),
                              decoration: _dec(
                                context,
                                'Giới tính',
                                Icons.wc_outlined,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: activity,
                              items: const [
                                DropdownMenuItem(
                                  value: 'sedentary',
                                  child: Text('Ít vận động'),
                                ),
                                DropdownMenuItem(
                                  value: 'light',
                                  child: Text('Vận động nhẹ'),
                                ),
                                DropdownMenuItem(
                                  value: 'moderate',
                                  child: Text('Vận động vừa'),
                                ),
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Năng động'),
                                ),
                                DropdownMenuItem(
                                  value: 'very_active',
                                  child: Text('Rất năng động'),
                                ),
                              ],
                              onChanged: (v) => setState(() => activity = v!),
                              decoration: _dec(
                                context,
                                'Mức hoạt động',
                                Icons.directions_run,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Chia bữa ăn (%)',
                                style: t.titleSmall,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...mealSplits.map((m) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(m['name'] as String)),
                                    SizedBox(
                                      width: 72,
                                      child: TextFormField(
                                        initialValue: m['percent'].toString(),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          suffixText: '%',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          m['percent'] = int.tryParse(val) ?? 0;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Tổng: ${_mealTotal()}%',
                                style: t.bodySmall?.copyWith(
                                  color:
                                      _mealTotal() == 100
                                          ? cs.onSurfaceVariant
                                          : cs.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        secondChild: const SizedBox(height: 8),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: ctrl.loading ? null : _onCalculate,
                          child:
                              ctrl.loading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Tính BMI'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (current != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Gợi ý calo theo bữa', style: t.titleMedium),
              ),
              const SizedBox(height: 8),
              ...current.meals.map(
                (m) => Card(
                  elevation: 0,
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.primary.withOpacity(0.12),
                      child: Icon(Icons.local_dining, color: cs.primary),
                    ),
                    title: Text(m.name),
                    subtitle: Text('${m.percent}% · ${m.kcal} kcal'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
