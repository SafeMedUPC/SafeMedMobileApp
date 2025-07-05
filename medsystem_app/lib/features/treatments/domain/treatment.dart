class Treatment {
  int id;
  String treatmentName;
  String description;
  String period;
  int patientId;

  Treatment(
      {required this.id,
      required this.treatmentName,
      required this.description,
      required this.period,
      required this.patientId});
  Treatment.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? -1,
        treatmentName = json['treatmentName'] ?? '',
        description = json['description'] ?? '',
        period = json['period'] ?? '',
        patientId = json['patientId'] ?? -1;
}
