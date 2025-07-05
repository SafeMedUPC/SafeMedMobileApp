// 1. AÑADE LA IMPORTACIÓN DE RIVERPOD
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medsystem_app/features/appointments/presentation/blocs/appointments_bloc.dart';
import 'package:medsystem_app/features/auth/data/remote/auth_gate.dart';
import 'package:medsystem_app/features/auth/data/remote/firebase_options.dart';
import 'package:medsystem_app/features/treatments/presentation/blocs/treatments_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(

    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tu MultiBlocProvider se mantiene exactamente igual
    return MultiBlocProvider(
      providers: [
        BlocProvider<TreatmentsBloc>(
          create: (context) => TreatmentsBloc(),
        ),
        BlocProvider<AppointmentsBloc>(
          create: (context) => AppointmentsBloc(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}