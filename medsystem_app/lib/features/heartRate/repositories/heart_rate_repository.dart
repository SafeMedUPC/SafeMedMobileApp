
import '../domain/heart_rate.dart';abstract class HeartRateRepository {
  Stream<HeartRate> getHeartRateStream();
}
