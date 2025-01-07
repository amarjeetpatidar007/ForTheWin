// lib/models/social_data.dart


// lib/services/api_service.dart
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';




class SocialDataGraph extends StatefulWidget {
  const SocialDataGraph({super.key});

  @override
  _SocialDataGraphState createState() => _SocialDataGraphState();
}

class _SocialDataGraphState extends State<SocialDataGraph> {
  bool isLoading = true;
  Map<String, Map<String, int>> aggregatedData = {};
  final String token = dotenv.env['token'] ?? "Key";
  final String endpoint = dotenv.env['endpoint'] ?? "Key";



  @override
  void initState() {
    super.initState();
    fetchSocialData();
  }
  final List<Color> barColors = [
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.red.shade400,
    Colors.orange.shade400,
  ];


  Future<void> fetchSocialData() async {

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Token': token,
          'Content-Type': 'application/json',
          'x-embedding-api-key': '',
        },
        body: jsonEncode({
          'find': {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']['documents'] as List;

        // Aggregating Data
        Map<String, Map<String, int>> tempData = {};
        for (var doc in data) {
          String postType = doc['post_type'];
          tempData.putIfAbsent(postType, () => {
            'likes': 0,
            'comments': 0,
            'shares': 0,
            'views': 0,
            'total': 0,
          });

          tempData[postType]!['likes'] = tempData[postType]!['likes']! + int.parse(doc['likes']);
          tempData[postType]!['comments'] = tempData[postType]!['comments']! + int.parse(doc['comments']);
          tempData[postType]!['shares'] = tempData[postType]!['shares']! + int.parse(doc['shares']);
          tempData[postType]!['views'] = tempData[postType]!['views']! + int.parse(doc['views']);
          tempData[postType]!['total'] = tempData[postType]!['total']! + 1;

        setState(() {
          aggregatedData = tempData;
          isLoading = false;
        });
      }} else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  String formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  height: constraints.maxHeight * 0.9,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Engagement Metrics by Post Type',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceEvenly,
                                maxY: aggregatedData.values
                                    .expand((element) => element.values)
                                    .reduce((max, value) =>
                                max > value ? max : value)
                                    .toDouble() *
                                    1.1,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    // tooltipBgColor: Colors.blueGrey.shade800,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      String metricName = ['Likes', 'Comments', 'Shares', 'Views'][rodIndex];
                                      return BarTooltipItem(
                                        '${metricName}\n${formatNumber(rod.toY)}',
                                        const TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        String postType = aggregatedData.keys
                                            .elementAt(value.toInt());
                                        return Text(
                                          postType,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          formatNumber(value),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: null,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade200,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                barGroups: List.generate(
                                  aggregatedData.length,
                                      (index) {
                                    final entry = aggregatedData.entries
                                        .elementAt(index);
                                    final metrics = entry.value;
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: metrics['likes']!.toDouble(),
                                          color: barColors[0],
                                          width: constraints.maxWidth * 0.03,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                        BarChartRodData(
                                          toY: metrics['comments']!.toDouble(),
                                          color: barColors[1],
                                          width: constraints.maxWidth * 0.03,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                        BarChartRodData(
                                          toY: metrics['shares']!.toDouble(),
                                          color: barColors[2],
                                          width: constraints.maxWidth * 0.03,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                        BarChartRodData(
                                          toY: metrics['views']!.toDouble(),
                                          color: barColors[3],
                                          width: constraints.maxWidth * 0.03,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),

                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _buildLegendItem('Likes', barColors[0]),
                              _buildLegendItem('Comments', barColors[1]),
                              _buildLegendItem('Shares', barColors[2]),
                              _buildLegendItem('Views', barColors[3]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}