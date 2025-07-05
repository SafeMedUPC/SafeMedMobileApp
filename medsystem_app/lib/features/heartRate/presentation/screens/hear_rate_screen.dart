import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/heart_rate.dart';
import '../controllers/heart_rate_controller.dart';


class HeartRateScreen extends ConsumerStatefulWidget {
  const HeartRateScreen({super.key});

  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends ConsumerState<HeartRateScreen> {
  // Banderas para asegurar que las alertas se muestren solo una vez por sesión de vista
  bool hasShownHighAlert = false;
  bool hasShownModerateAlert = false;

  @override
  Widget build(BuildContext context) {

    ref.listen<AsyncValue<List<HeartRate>>>(heartRateControllerProvider, (previous, next) {

      if (next is! AsyncData || next.value!.isEmpty) return;

      final lastHeartRate = next.value!.last;
      final isHigh = lastHeartRate.bpm > 120;
      final isModerate = lastHeartRate.bpm > 100 && lastHeartRate.bpm <= 120;

      if (isHigh && !hasShownHighAlert) {
        setState(() => hasShownHighAlert = true);
        _showAlertDialog(context, "¡Alerta!",
            "El ritmo cardíaco es muy elevado. Vamos a llamar a tu número de contacto preferido.");
      } else if (isModerate && !hasShownModerateAlert) {
        setState(() => hasShownModerateAlert = true);
        _showConfirmationDialog(context);
      }
    });

    final asyncData = ref.watch(heartRateControllerProvider);

    // 1. APLICANDO EL PATRÓN VISUAL
    return Scaffold(
      extendBodyBehindAppBar: true, // Clave para el AppBar transparente
      appBar: AppBar(
        title: const Text(
          'Ritmo Cardíaco',
          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0,
        leading: IconButton( // Botón para regresar si es necesario
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () {
              // Tu lógica de configuración
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo oscuro consistente con el resto de la app
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
          // Contenido de la página
          asyncData.when(
            data: (data) => _buildHeartRateContent(context, data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );
  }

  // 3. CÓDIGO MÁS LIMPIO: UI separada en métodos
  Widget _buildHeartRateContent(BuildContext context, List<HeartRate> data) {
    final lastHeartRate = data.isNotEmpty ? data.last : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Texto del ritmo cardíaco actual
            Center(
              child: Text(
                '${lastHeartRate?.bpm ?? "---"} bpm',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Ritmo Cardíaco Actual',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 30),
            // Gráfico del ritmo cardíaco
            SizedBox(
              height: 200,
              child: _buildChart(data),
            ),
            const Spacer(), // Ocupa el espacio disponible para empujar lo demás hacia abajo
            // Tarjeta de contacto de emergencia
            _buildEmergencyContactCard(),
            const SizedBox(height: 20),
            // Botón de "Llamar Emergencias"
            _buildEmergencyCallButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<HeartRate> data) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data
                .map((hr) => FlSpot(hr.timestamp.millisecondsSinceEpoch.toDouble(), hr.bpm.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.redAccent, // Color de línea más llamativo
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.redAccent.withOpacity(0.3),
                  Colors.redAccent.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 25, 38, 56), // Color del tema
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://st.depositphotos.com/46542440/55684/i/450/depositphotos_556849068-stock-illustration-square-face-character-stiff-art.jpg'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Juan Pérez',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Contacto de Emergencia',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () { /* Lógica para llamar al contacto */ },
            icon: const Icon(Icons.phone, color: Colors.white, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.green, // Mantenemos el verde para una acción clara
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmergencyCallButton() {
    return ElevatedButton.icon(
      onPressed: () { /* Lógica para llamar a emergencias */ },
      icon: const Icon(Icons.call, color: Colors.white),
      label: const Text('LLAMAR A EMERGENCIAS'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.red.withOpacity(0.8), // Color rojo para emergencias
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Métodos de diálogo (sin cambios)
  void _showAlertDialog(BuildContext context, String title, String message) { /* ... tu código ... */ }
  void _showConfirmationDialog(BuildContext context) { /* ... tu código ... */ }
}