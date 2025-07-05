import 'package:flutter/material.dart';
import 'package:medsystem_app/features/treatments/presentation/pages/add_treatments_page.dart';
import 'package:medsystem_app/features/treatments/presentation/pages/current_treatments_page.dart';
import 'package:medsystem_app/features/treatments/presentation/pages/history_treatments_page.dart';
import 'package:medsystem_app/features/treatments/presentation/pages/remove_treatments_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class TreatmentsScreen extends StatefulWidget {
  const TreatmentsScreen({super.key});

  @override
  State<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends State<TreatmentsScreen> {
  int _selectedIndex = -1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = const [
    HistoryTreatmentsPage(),
    AddTreatmentsScreen(),
    RemoveTreatmentsPage()
  ];

  String _getAppBarTitle() {
    if (_selectedIndex == 0) return 'History Treatments';
    if (_selectedIndex == 1) return 'Add Treatments';
    if (_selectedIndex == 2) return 'Remove Treatments';
    return 'Current Treatments';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Contenido principal
          _selectedIndex == -1
              ? const CurrentTreatmentsScreen()
              : _pages[_selectedIndex],
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ], // Sombra opcional para realzar el diseño
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GNav(
                color: Colors.black,
                activeColor: Colors.white,
                tabBackgroundColor: const Color.fromARGB(255, 96, 196, 209),
                gap: 8,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 300),
                tabs: const [
                  GButton(icon: Icons.history, text: 'History'),
                  GButton(icon: Icons.add, text: 'Add'),
                  GButton(icon: Icons.delete, text: 'Delete'),
                ],
                selectedIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
                onTabChange: _onItemTapped,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
