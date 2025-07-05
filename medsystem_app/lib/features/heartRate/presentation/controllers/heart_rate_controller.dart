import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/heart_rate.dart';
import '../../repositories/heart_rate_repository.dart';
import '../../repositories/heart_rate_repository_impl.dart';
import '../../usescases/get_hear_rate_stream.dart';

// Proveedor del repositorio de ritmo cardíaco
final heartRateRepositoryProvider = Provider<HeartRateRepository>((ref) {
  return HeartRateRepositoryImpl();
});

final heartRateControllerProvider =
    StreamProvider.autoDispose<List<HeartRate>>((ref) {
  final useCase = GetHeartRateStream(ref.watch(heartRateRepositoryProvider));
  return useCase(); // ✅ directamente retorna Stream<List<HeartRate>>
});
