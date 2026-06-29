import 'package:flutter/material.dart';
import 'package:ombor_hisobot/services/firebase_service.dart';
import 'package:ombor_hisobot/models/models.dart';
import 'package:ombor_hisobot/utils/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onMijozQosh,
    required this.onMahsulotQosh,
    required this.onYukXatiYarat,
  });
  final VoidCallback onMijozQosh;
  final VoidCallback onMahsulotQosh;
  final VoidCallback onYukXatiYarat;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = FirebaseService.getDashboardStats();
  }

  void _refresh() => setState(() {
        _statsFuture = FirebaseService.getDashboardStats();
      });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.danger, size: 40),
                        const SizedBox(height: 8),
                        Text('Xatolik: ${snap.error}',
                            style: const TextStyle(color: AppColors.danger)),
                        TextButton(
                          onPressed: _refresh,
                          child: const Text('Qayta urinish'),
                        ),
                      ],
                    ),
                  );
                }
                final stats = snap.data!;
                final totalSavdo =
                    (stats['totalSavdo'] as num? ?? 0).toDouble();
                final buOySavdo = (stats['buOySavdo'] as num? ?? 0).toDouble();
                final totalFoyda =
                    (stats['totalFoyda'] as num? ?? 0).toDouble();
                final buOyFoyda = (stats['buOyFoyda'] as num? ?? 0).toDouble();
                final totalMijoz = (stats['totalMijoz'] as num? ?? 0).toInt();
                final faolMijoz = (stats['faolMijoz'] as num? ?? 0).toInt();
                final ombordagi = (stats['ombordagi'] as num? ?? 0).toInt();
                final kamQolgan = (stats['kamQolgan'] as num? ?? 0).toInt();

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                      title: 'Jami savdo',
                      value: Fmt.money(totalSavdo),
                      sub: "Bu oy: ${Fmt.money(buOySavdo)}",
                      icon: Icons.attach_money,
                      iconColor: const Color(0xFF4CAF50),
                      iconBg: const Color(0xFFE8F5E9),
                    ),
                    _StatCard(
                      title: 'Jami foyda',
                      value: Fmt.money(totalFoyda),
                      sub: "Bu oy: ${Fmt.money(buOyFoyda)}",
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFF9C27B0),
                      iconBg: const Color(0xFFF3E5F5),
                    ),
                    _StatCard(
                      title: 'Jami mijozlar',
                      value: '$totalMijoz',
                      sub: "Faol: $faolMijoz",
                      icon: Icons.people,
                      iconColor: const Color(0xFF2196F3),
                      iconBg: const Color(0xFFE3F2FD),
                    ),
                    _StatCard(
                      title: 'Omborda',
                      value: '$ombordagi',
                      sub: "Kam qolgan: $kamQolgan",
                      icon: Icons.inventory_2,
                      iconColor: const Color(0xFFFF9800),
                      iconBg: const Color(0xFFFFF3E0),
                      subColor: kamQolgan > 0 ? AppColors.danger : null,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // So'nggi yuk xatlari
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "So'nggi yuk xatlari",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<YukXati>>(
                      stream: FirebaseService.getYukXatlari(),
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }
                        if (snap.hasError) {
                          return Text('Xatolik: ${snap.error}',
                              style: const TextStyle(color: AppColors.danger));
                        }
                        final items = (snap.data ?? []).take(3).toList();
                        if (items.isEmpty) {
                          return const Text(
                            "Ma'lumot yo'q",
                            style: TextStyle(color: AppColors.textSecondary),
                          );
                        }
                        return Column(
                          children: items
                              .map((y) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                y.raqami,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              Text(
                                                y.mijozNomi,
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          Fmt.money(y.summa),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Kam qolgan mahsulotlar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kam qolgan mahsulotlar",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Mahsulot>>(
                      stream: FirebaseService.getMahsulotlar(),
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }
                        if (snap.hasError) {
                          return Text('Xatolik: ${snap.error}',
                              style: const TextStyle(color: AppColors.danger));
                        }
                        final items = (snap.data ?? [])
                            .where((m) => m.miqdor <= 5)
                            .take(5)
                            .toList();
                        if (items.isEmpty) {
                          return const Text(
                            "Barcha mahsulotlar yetarli",
                            style: TextStyle(color: AppColors.accent),
                          );
                        }
                        return Column(
                          children: items
                              .map((m) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF5F5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.danger
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                m.nomi,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(
                                                m.kategoriya,
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${m.miqdor} qoldi',
                                          style: TextStyle(
                                            color: m.miqdor <= 0
                                                ? AppColors.danger
                                                : AppColors.warning,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tezkor amallar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tezkor amallar",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.person_add_outlined,
                            label: "Mijoz qo'shish",
                            onTap: widget.onMijozQosh,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.add_box_outlined,
                            label: "Mahsulot qo'shish",
                            onTap: widget.onMahsulotQosh,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.receipt_long_outlined,
                            label: "Yuk xati yaratish",
                            onTap: widget.onYukXatiYarat,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.subColor,
  });
  final String title, value, sub;
  final IconData icon;
  final Color iconColor, iconBg;
  final Color? subColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration:
                      BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                  color: subColor ?? AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
