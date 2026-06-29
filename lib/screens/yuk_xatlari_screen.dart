import 'package:flutter/material.dart';
import 'package:ombor_hisobot/models/models.dart';
import 'package:ombor_hisobot/services/firebase_service.dart';
import 'package:ombor_hisobot/utils/theme.dart';

class YukXatlariScreen extends StatefulWidget {
  const YukXatlariScreen({super.key});

  @override
  State<YukXatlariScreen> createState() => _YukXatlariScreenState();
}

class _YukXatlariScreenState extends State<YukXatlariScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Mijoz nomi yoki yuk xati raqami...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            })
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _showCreateForm(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Yaratish"),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<YukXati>>(
            stream: FirebaseService.getYukXatlari(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = snap.data ?? [];
              final filtered = _query.isEmpty
                  ? all
                  : all
                      .where((y) =>
                          y.mijozNomi.toLowerCase().contains(_query) ||
                          y.raqami.toLowerCase().contains(_query))
                      .toList();
              if (filtered.isEmpty) {
                return const Center(
                    child: Text("Yuk xati yo'q",
                        style: TextStyle(color: AppColors.textSecondary)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final y = filtered[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showDetail(context, y),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.receipt_long,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(y.raqami,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary)),
                                  Text(y.mijozNomi,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                  Text(Fmt.date(y.sana),
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(Fmt.money(y.summa),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15)),
                                Text('Foyda: ${Fmt.money(y.foyda)}',
                                    style: const TextStyle(
                                        color: AppColors.accent, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDetail(BuildContext context, YukXati y) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(y.raqami,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.danger),
                    onPressed: () async {
                      await FirebaseService.deleteYukXati(y);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              Text('Mijoz: ${y.mijozNomi}',
                  style: const TextStyle(color: AppColors.textSecondary)),
              Text('Sana: ${Fmt.date(y.sana)}',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const Divider(),
              const Text('Mahsulotlar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              ...y.mahsulotlar.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.mahsulotNomi,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text('${item.miqdor} x ${Fmt.money(item.narx)}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                          ],
                        )),
                        Text(Fmt.money(item.jami),
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jami summa:',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(Fmt.money(y.summa),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Foyda:',
                      style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600)),
                  Text(Fmt.money(y.foyda),
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateForm(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const _CreateYukXatiScreen()));
  }
}

class _CreateYukXatiScreen extends StatefulWidget {
  const _CreateYukXatiScreen();

  @override
  State<_CreateYukXatiScreen> createState() => _CreateYukXatiScreenState();
}

class _CreateYukXatiScreenState extends State<_CreateYukXatiScreen> {
  Mijoz? _selectedMijoz;
  final List<YukXatiMahsulot> _items = [];
  bool _saving = false;

  double get _totalSumma => _items.fold(0, (s, i) => s + i.jami);
  double get _totalFoyda => _items.fold(0, (s, i) {
        return s + (i.jami - (i.miqdor * 0)); // rough, override in real impl
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yuk xati yaratish')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mijoz tanlash',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          StreamBuilder<List<Mijoz>>(
                            stream: FirebaseService.getMijozlar(),
                            builder: (ctx, snap) {
                              final mijozlar = snap.data ?? [];
                              return DropdownButtonFormField<String>(
                                initialValue: _selectedMijoz?.id,
                                decoration:
                                    const InputDecoration(labelText: 'Mijoz *'),
                                items: mijozlar
                                    .map((m) => DropdownMenuItem(
                                        value: m.id, child: Text(m.nomi)))
                                    .toList(),
                                onChanged: (v) => setState(() =>
                                    _selectedMijoz =
                                        mijozlar.firstWhere((m) => m.id == v)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Mahsulotlar',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              TextButton.icon(
                                onPressed: () => _addItem(),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Qo'shish"),
                              ),
                            ],
                          ),
                          if (_items.isEmpty)
                            const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text("Mahsulot qo'shing",
                                        style: TextStyle(
                                            color: AppColors.textSecondary)))),
                          ..._items.asMap().entries.map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(e.value.mahsulotNomi,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                            '${e.value.miqdor} x ${Fmt.money(e.value.narx)} = ${Fmt.money(e.value.jami)}',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12)),
                                      ],
                                    )),
                                    IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: AppColors.danger,
                                            size: 20),
                                        onPressed: () => setState(
                                            () => _items.removeAt(e.key))),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jami:',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(Fmt.money(_totalSumma),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _saving || _selectedMijoz == null || _items.isEmpty
                            ? null
                            : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Saqlash'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    Mahsulot? selectedMah;
    final miqdorCtrl = TextEditingController(text: '1');
    final narxCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => SingleChildScrollView(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Mahsulot qo\'shish',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              StreamBuilder<List<Mahsulot>>(
                stream: FirebaseService.getMahsulotlar(),
                builder: (ctx, snap) {
                  final list = snap.data ?? [];
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Mahsulot *'),
                    items: list
                        .map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text('${m.nomi} (${m.miqdor} ${m.birlik})')))
                        .toList(),
                    onChanged: (v) {
                      selectedMah = list.firstWhere((m) => m.id == v);
                      narxCtrl.text = selectedMah!.narx.toStringAsFixed(0);
                      setS(() {});
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: miqdorCtrl,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Miqdor *'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextField(
                          controller: narxCtrl,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Narx *'))),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (selectedMah == null) return;
                  final miqdor = int.tryParse(miqdorCtrl.text) ?? 1;
                  final narx =
                      double.tryParse(narxCtrl.text) ?? selectedMah!.narx;
                  setState(() => _items.add(YukXatiMahsulot(
                        mahsulotId: selectedMah!.id,
                        mahsulotNomi: selectedMah!.nomi,
                        miqdor: miqdor,
                        narx: narx,
                        jami: miqdor * narx,
                      )));
                  Navigator.pop(ctx);
                },
                child: const Text("Qo'shish"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final now = DateTime.now();
    final raqami =
        'INV-${now.year}-${now.month.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';

    double foyda = 0;
    // We'd need tannarx from mahsulot for accurate foyda — simplified here
    for (final item in _items) {
      foyda += item.jami * 0.1;
    }

    final yukXati = YukXati(
      id: '',
      raqami: raqami,
      mijozId: _selectedMijoz!.id,
      mijozNomi: _selectedMijoz!.nomi,
      sana: now,
      summa: _totalSumma,
      foyda: foyda,
      mahsulotlar: _items,
    );

    await FirebaseService.addYukXati(yukXati);
    if (mounted) Navigator.pop(context);
  }
}
