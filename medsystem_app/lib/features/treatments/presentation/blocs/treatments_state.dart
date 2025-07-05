import 'package:medsystem_app/features/treatments/domain/treatment.dart';

abstract class TreatmentsState {}

class TreatmentsInitialState extends TreatmentsState {}

class TreatmentsLoadingState extends TreatmentsState {}

class TreatmentsLoadedState extends TreatmentsState {
  List<Treatment> treatments;
  TreatmentsLoadedState({required this.treatments});
}

class TreatmentsErrorState extends TreatmentsState {
  String message;
  TreatmentsErrorState({required this.message});
}
