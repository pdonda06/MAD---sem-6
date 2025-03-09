import 'package:flutter/material.dart';
import 'package:crypto_tracker/models/crypto_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CryptoListItem extends StatelessWidget {
  final Crypto crypto;
  final VoidCallback onTap;

  const CryptoListItem({
    super.key,
    required this.crypto,
    required this.onTap,
  });

  String _formatPrice(double price) {
    if (price >= 1.0) {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(price);
    } else if (price >= 0.01) {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 4).format(price);
    } else {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 8).format(price);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);
    final isPositive = crypto.priceChangePercentage24h >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Crypto Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  crypto.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Crypto Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crypto.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      crypto.symbol,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              // Mini Chart
              if (crypto.sparklineData.isNotEmpty)
                SizedBox(
                  width: 60,
                  height: 30,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: crypto.sparklineData.length.toDouble() - 1,
                      minY: crypto.sparklineData.reduce((a, b) => a < b ? a : b),
                      maxY: crypto.sparklineData.reduce((a, b) => a > b ? a : b),
                      lineBarsData: [
                        LineChartBarData(
                          spots: crypto.sparklineData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          color: isPositive ? Colors.green : Colors.red,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              // Price Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(crypto.currentPrice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      percentFormat.format(crypto.priceChangePercentage24h / 100),
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }
} 