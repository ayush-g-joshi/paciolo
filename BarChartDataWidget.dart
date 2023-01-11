
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:paciolo/model/ChartModel.dart';
import 'package:paciolo/util/styles.dart';

import 'Constants.dart';
import 'LegendWidget.dart';
import 'Translation.dart';
import 'dimensions.dart';

class BarChartDataWidget extends StatelessWidget {

  String TAG = "BarChartDataWidget";
  List<BarChartGroupData> barChartGroupList;
  double maxAmount;

  BarChartDataWidget({Key? key, required this.barChartGroupList, required this.maxAmount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("$TAG Bar Chart Group List =========>  ${barChartGroupList.length}");

    return Card(
      margin: const EdgeInsets.only(top: Dimensions.PADDING_M, left: Dimensions.PADDING_M, right: Dimensions.PADDING_M,),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.PADDING_L),
      ),
      elevation: Dimensions.PADDING_XS,
      borderOnForeground: true,
      semanticContainer: true,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: Dimensions.PADDING_S, left: Dimensions.PADDING_S, right: Dimensions.PADDING_S,),
            child: Text(
              Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_GRAPH_TITLE : IT.CUSTOMER_PROFILE_GRAPH_TITLE,
              style: gothamRegular.copyWith(
                fontSize: Dimensions.FONT_L,
                color: const Color(AllColors.colorText),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          LegendsListWidget(
            legends: [
              Legend(
                Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_GRAPH_POSITIVE : IT.CUSTOMER_PROFILE_GRAPH_POSITIVE,
                const Color(0xff1e8ab7),
              ),
              Legend(
                Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_GRAPH_NEGATIVE : IT.CUSTOMER_PROFILE_GRAPH_NEGATIVE,
                const Color(0xffe77e23),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 3,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(),
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 22,
                      ),
                      axisNameSize: 12
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipMargin: 8,
                    tooltipBgColor: const Color(0xff4000000),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: barChartGroupList,
                maxY: maxAmount,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    var style = gothamRegular.copyWith(
      color: const Color(AllColors.colorText),
      fontSize: 10,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Gen';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'Mag';
        break;
      case 5:
        text = 'Giu';
        break;
      case 6:
        text = 'Lug';
        break;
      case 7:
        text = 'Ago';
        break;
      case 8:
        text = 'Set';
        break;
      case 9:
        text = 'Ott';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dic';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }
}