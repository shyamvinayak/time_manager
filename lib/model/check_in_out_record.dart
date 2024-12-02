
class CheckInOutRecord {
  final int? id;
  final DateTime chooseDate;
  final DateTime checkInTime;
  final DateTime checkOutTime;

  CheckInOutRecord({
    this.id,
    required this.chooseDate,
    required this.checkInTime,
    required this.checkOutTime,
  });
}