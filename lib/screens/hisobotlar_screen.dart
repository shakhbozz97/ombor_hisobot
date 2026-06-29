import 'package:flutter/material.dart';
import 'package:ombor_hisobot/models/models.dart';
import 'package:ombor_hisobot/services/firebase_service.dart';
import 'package:ombor_hisobot/utils/theme.dart';

class HisobotlarScreen extends StatefulWidget {
  const HisobotlarScreen({super.key});

  @override
  State<HisobotlarScreen> createState() => _HisobotlarScreenState();
}

class _HisobotlarScreenState extends State<HisobotlarScreen> {
  DateTime _from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _to = DateTime.now();
  String? _selectedMijozId;
  List<YukXati> _results = [];
  bool _loading = false;
  double _totalSavdo = 0;
  double _totalFoyda = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                  child: _SummaryCard(
                      title: 'Jami savdo',
                      value: Fmt.money(_totalSavdo),
                      color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _SummaryCard(
                      title: 'Jami foyda',
                      value: Fmt.money(_totalFoyda),
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 16),
          // Filter card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Sana bo'yicha filter",
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _DateButton(
                              label: 'Dan: ${Fmt.date(_from)}',
                              onTap: () async {
                                final d = await showDatePicker(
                                    context: context,
                                    initialDate: _from,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now());
                                if (d != null) setState(() => _from = d);
                              })),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _DateButton(
                              label: 'Gacha: ${Fmt.date(_to)}',
                              onTap: () async {
                                final d = await showDatePicker(
                                    context: context,
                                    initialDate: _to,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now());
                                if (d != null) setState(() => _to = d);
                              })),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<Mijoz>>(
                    stream: FirebaseService.getMijozlar(),
                    builder: (ctx, snap) {
                      final mijozlar = snap.data ?? [];
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedMijozId,
                        decoration:
                            const InputDecoration(labelText: 'Barcha mijozlar'),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Barcha mijozlar')),
                          ...mijozlar.map((m) => DropdownMenuItem(
                              value: m.id, child: Text(m.nomi))),
                        ],
                        onChanged: (v) => setState(() => _selectedMijozId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _search,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text("Ko'rsatish"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_results.isNotEmpty) ...[
            const Text('Natijalar',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ..._results.map((y) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(y.mijozNomi,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text(y.raqami,
                                style: const TextStyle(
                                    color: AppColors.primary, fontSize: 13)),
                            Text(Fmt.date(y.sana),
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(Fmt.money(y.summa),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            Text('Foyda: ${Fmt.money(y.foyda)}',
                                style: const TextStyle(
                                    color: AppColors.accent, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ] else if (!_loading)
            const Card(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: Text("Bu davr uchun ma'lumot topilmadi",
                          style: TextStyle(color: AppColors.textSecondary)))),
            ),
        ],
      ),
    );
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    final stream = FirebaseService.getYukXatlari();
    final all = await stream.first;
    final filtered = all.where((y) {
      final inRange = y.sana.isAfter(_from.subtract(const Duration(days: 1))) &&
          y.sana.isBefore(_to.add(const Duration(days: 1)));
      final inMijoz = _selectedMijozId == null || y.mijozId == _selectedMijozId;
      return inRange && inMijoz;
    }).toList();
    setState(() {
      _results = filtered;
      _totalSavdo = filtered.fold(0, (s, y) => s + y.summa);
      _totalFoyda = filtered.fold(0, (s, y) => s + y.foyda);
      _loading = false;
    });
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.title, required this.value, required this.color});
  final String title, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w800, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
    );
  }
}
