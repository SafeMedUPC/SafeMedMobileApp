import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:medsystem_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:medsystem_app/features/appointments/presentation/pages/appointment_page.dart';
import 'package:medsystem_app/features/auth/presentation/pages/profile_page.dart';
import 'package:medsystem_app/features/heartRate/domain/heart_rate.dart';
import 'package:medsystem_app/features/heartRate/presentation/screens/hear_rate_screen.dart';
import 'package:medsystem_app/features/treatments/presentation/pages/treatments_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AppointmentPage(),
    const Placeholder(),
    const UserProfilePage(),
    const HeartRateScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 1
          ? Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage("assets/images/fondo.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(255, 25, 38, 56),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_hospital,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Mira tus tratamientos",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Consulta tus tratamientos en curso y el historial médico en un solo lugar.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TreatmentsScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            backgroundColor: const Color(0xFFFF5722),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Ver tratamientos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 25, 38, 56),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GNav(
              selectedIndex: _selectedIndex,
              color: const Color.fromARGB(255, 255, 255, 255),
              activeColor: const Color.fromARGB(255, 255, 255, 255),
              tabBackgroundColor: const Color.fromARGB(104, 51, 77, 104),
              gap: 8,
              padding: const EdgeInsets.all(16),
              duration: const Duration(milliseconds: 900),
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              tabs: const [
                GButton(icon: Icons.alarm, text: 'Appointments'),
                GButton(icon: Icons.align_vertical_bottom, text: 'Treatments'),
                GButton(icon: Icons.person, text: 'Profile'),
                GButton(icon: Icons.monitor_heart, text: 'Heart Rate'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
