import '../domain/heart_rate.dart';

abstract class HeartRateRepository {
  Stream<List<HeartRate>> getHeartRateStream(); // antes era Stream<HeartRate>
}
