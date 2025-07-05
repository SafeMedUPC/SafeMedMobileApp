

import '../domain/heart_rate.dart';
import '../repositories/heart_rate_repository.dart';

class GetHeartRateStream {
  final HeartRateRepository repository;

  GetHeartRateStream(this.repository);

  Stream<HeartRate> call() {
    return repository.getHeartRateStream();
  }
}
