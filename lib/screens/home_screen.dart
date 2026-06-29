import 'package:flutter/material.dart';
import 'package:ombor_hisobot/widgets/app_drawer.dart';
import 'package:ombor_hisobot/screens/dashboard_screen.dart';
import 'package:ombor_hisobot/screens/mijozlar_screen.dart';
import 'package:ombor_hisobot/screens/kategoriyalar_screen.dart';
import 'package:ombor_hisobot/screens/mahsulotlar_screen.dart';
import 'package:ombor_hisobot/screens/yuk_xatlari_screen.dart';
import 'package:ombor_hisobot/screens/hisobotlar_screen.dart';
import 'package:ombor_hisobot/screens/foydalanuvchilar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Dashboard',
    'Mijozlar',
    'Mahsulot kategoriyalari',
    'Mahsulotlar',
    'Yuk xatlari',
    'Foyda hisobotlari',
    'Foydalanuvchilar',
  ];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          onMijozQosh: () => setState(() => _selectedIndex = 1),
          onMahsulotQosh: () => setState(() => _selectedIndex = 3),
          onYukXatiYarat: () => setState(() => _selectedIndex = 4),
        );
      case 1:
        return const MijozlarScreen();
      case 2:
        return const KategoriyalarScreen();
      case 3:
        return const MahsulotlarScreen();
      case 4:
        return const YukXatlariScreen();
      case 5:
        return const HisobotlarScreen();
      case 6:
        return const FoydalanuvchilarScreen();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onSelect: (i) => setState(() => _selectedIndex = i),
      ),
      body: _buildBody(),
    );
  }
}
