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
  bool hasShownHighAlert = false;
  bool hasShownModerateAlert = false;

  @override
  Widget build(BuildContext context) {
    // Corrige el tipo: es AsyncValue<List<HeartRate>>
    ref.listen<AsyncValue<List<HeartRate>>>(heartRateControllerProvider,
        (previous, next) {
      final heartRates = next.asData?.value;

      if (heartRates == null || heartRates.isEmpty) return;

      final lastHeartRate = heartRates.last;
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Ritmo Cardíaco',
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () {
              // Lógica de configuración
            },
          ),
        ],
      ),
      body: Stack(
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
          asyncData.when(
            data: (data) {
              final lastHeartRate = data.isNotEmpty ? data.last : null;
              return _buildHeartRateContent(context, data, lastHeartRate);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateContent(
      BuildContext context, List<HeartRate> data, HeartRate? lastHeartRate) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
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
            SizedBox(
              height: 200,
              child: _buildChart(data),
            ),
            const Spacer(),
            _buildEmergencyContactCard(),
            const SizedBox(height: 20),
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
                .map((hr) => FlSpot(
                    hr.timestamp.millisecondsSinceEpoch.toDouble(),
                    hr.bpm.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.redAccent,
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
        color: const Color.fromARGB(255, 25, 38, 56),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
                'https://st.depositphotos.com/46542440/55684/i/450/depositphotos_556849068-stock-illustration-square-face-character-stiff-art.jpg'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Juan Pérez',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
            onPressed: () {
              // Lógica de llamada
            },
            icon: const Icon(Icons.phone, color: Colors.white, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmergencyCallButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Lógica de llamada a emergencias
      },
      icon: const Icon(Icons.call, color: Colors.white),
      label: const Text('LLAMAR A EMERGENCIAS'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.red.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Precaución"),
        content: const Text(
            "Tu ritmo cardíaco está un poco elevado. ¿Deseas contactar a tu médico?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          TextButton(onPressed: () {}, child: const Text("Sí, contactar")),
        ],
      ),
    );
  }
}
