import 'package:equatable/equatable.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class GetAppointments extends AppointmentsEvent {
  final String uid;

  const GetAppointments({required this.uid});

  @override
  List<Object?> get props => [uid];
}
