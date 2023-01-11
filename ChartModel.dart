
import 'package:charts_flutter_new/flutter.dart' as charts;

class ChartModel {
  final String month;
  final String totalGiven;
  final String totalPaid;
  final charts.Color barColor;

  ChartModel({
    required this.month,
    required this.totalGiven,
    required this.totalPaid,
    required this.barColor,
  });

  Map<String, dynamic> toMap() {
    return {
      "month": month,
      "totalGiven": totalGiven,
      "totalPaid": totalPaid,
      "barColor": barColor,
    };
  }

  @override
  String toString() {
    return "ChartModel(month: $month, totalGiven: $totalGiven, totalPaid: $totalPaid)";
  }
}
