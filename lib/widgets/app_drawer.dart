import 'package:flutter/material.dart';
import 'package:ombor_hisobot/utils/theme.dart';
import 'package:ombor_hisobot/services/firebase_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer(
      {super.key, required this.selectedIndex, required this.onSelect});
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ColoredBox(
        color: AppColors.primary,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.warehouse_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ombor Hisobot',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        Text('Xojiakbar',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Dashboard
              _DrawerItem(
                  label: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  index: 0,
                  selectedIndex: selectedIndex,
                  onTap: () => _nav(context, 0)),

              const _SectionHeader('MIJOZLAR'),
              _DrawerItem(
                  label: 'Mijozlar',
                  icon: Icons.people_outline,
                  index: 1,
                  selectedIndex: selectedIndex,
                  onTap: () => _nav(context, 1)),

              const _SectionHeader('OMBOR'),
              _DrawerItem(
                  label: 'Kategoriyalar',
                  icon: Icons.category_outlined,
                  index: 2,
                  selectedIndex: selectedIndex,
                  onTap: () => _nav(context, 2)),
              _DrawerItem(
                  label: 'Mahsulotlar',
                  icon: Icons.inventory_2_outlined,
                  index: 3,
                  selectedIndex: selectedIndex,
                  onTap: () => _nav(context, 3)),

              const _SectionHeader('YUK XATLARI'),
              _DrawerItem(
                  label: 'Yuk xatlari',
                  icon: Icons.receipt_long_outlined,
                  index: 4,
                  selectedIndex: selectedIndex,
                  onTap: () => _nav(context, 4)),
              _DrawerItem(
                  label: 'Hisobotlar',
                  icon: Icons.bar_chart_outlined,
                  index: 5,
                  selectedIndex: selectedIndex,
                  onTap: () => _nav(context, 5)),

              const _SectionHeader('FOYDALANUVCHILAR'),
              _DrawerItem(
                  label: 'Foydalanuvchilar',
                  icon: Icons.manage_accounts_outlined,
                  index: 6,
                  selectedIndex: selectedIndex,
                  onTap: () => _nav(context, 6)),

              const Spacer(),
              const Divider(color: Colors.white24, height: 1),
              _DrawerItem(
                label: 'Chiqish',
                icon: Icons.logout,
                index: -1,
                selectedIndex: selectedIndex,
                onTap: () async {
                  await FirebaseService.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _nav(BuildContext context, int index) {
    Navigator.pop(context);
    onSelect(index);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon,
                    color: isSelected ? Colors.white : Colors.white60,
                    size: 18),
                const SizedBox(width: 12),
                Text(label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    )),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2))),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
