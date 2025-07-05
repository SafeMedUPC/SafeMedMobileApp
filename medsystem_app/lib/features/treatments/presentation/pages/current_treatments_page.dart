import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medsystem_app/features/treatments/presentation/blocs/treatments_bloc.dart';
import 'package:medsystem_app/features/treatments/presentation/blocs/treatments_event.dart';
import 'package:medsystem_app/features/treatments/presentation/blocs/treatments_state.dart';

class CurrentTreatmentsScreen extends StatefulWidget {
  const CurrentTreatmentsScreen({super.key});

  @override
  State<CurrentTreatmentsScreen> createState() =>
      _CurrentTreatmentsScreenState();
}

class _CurrentTreatmentsScreenState extends State<CurrentTreatmentsScreen> {
  @override
  void initState() {
    context.read<TreatmentsBloc>().add(GetTreatments());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/fondo.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), // Cambia la opacidad aquí
                  BlendMode.darken,
                ),
              ),
            ),
          ),
           Padding(
            padding: const EdgeInsets.only(top: 80.0),
                child: BlocBuilder<TreatmentsBloc, TreatmentsState>(
                  builder: (context, state) {
                    if (state is TreatmentsLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    } else if (state is TreatmentsLoadedState) {
                      return ListView.builder(
                        itemCount: state.treatments.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemBuilder: (context, index) {
                          final treatment = state.treatments[index];
                          return Card(
                            color: Colors.white.withOpacity(0.9),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      treatment.treatmentName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color.fromRGBO(46, 63, 110, 1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    label: 'Patient:',
                                    value: treatment.patientId.toString(),
                                  ),
                                  _buildDetailRow(
                                    label: 'Description:',
                                    value: treatment.description,
                                  ),
                                  _buildDetailRow(
                                    label: 'Period:',
                                    value: treatment.period,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is TreatmentsErrorState) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return const Center(
                      child: Text(
                        'No treatments found',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  },
                ),
           ),      
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(46, 63, 110, 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
