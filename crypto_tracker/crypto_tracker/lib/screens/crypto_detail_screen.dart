import 'package:flutter/material.dart';
import 'package:crypto_tracker/models/crypto_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_tracker/providers/crypto_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class CryptoDetailScreen extends StatefulWidget {
  final Crypto crypto;

  const CryptoDetailScreen({
    super.key,
    required this.crypto,
  });

  @override
  State<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen> {
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  String _error = '';
  int _selectedChartIndex = 2; // 0: 24h, 1: 7d, 2: 30d
  final List<String> _timeFrames = ['1D', '7D', '1M', '6M', '1Y'];
  String _selectedTimeFrame = '7D';
  double? _touchedValue;
  DateTime? _touchedDate;
  final Color _chartBgColor = const Color(0xFF1C1F2D);
  List<double> _currentChartData = [];
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _updateChartData();
  }

  Future<void> _loadDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final details = await context.read<CryptoProvider>().getCryptoDetails(widget.crypto.id);
      
      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to load data. Please check your internet connection and try again.';
          _isLoading = false;
        });
      }
    }
  }

  // Add a retry mechanism
  Future<void> _retryLoadDetails() async {
    setState(() {
      _error = '';
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(seconds: 1)); // Add a small delay before retrying
    _loadDetails();
  }

  void _updateChartData() {
    final sparklineData = widget.crypto.sparklineData;
    if (sparklineData.isEmpty) {
      _currentChartData = [];
      return;
    }

    final now = DateTime.now();
    int dataPoints;
    
    switch (_selectedTimeFrame) {
      case '1D':
        _startDate = now.subtract(const Duration(days: 1));
        dataPoints = 24; // 1 point per hour
        break;
      case '7D':
        _startDate = now.subtract(const Duration(days: 7));
        dataPoints = 24 * 7; // 1 point per hour for 7 days
        break;
      case '1M':
        _startDate = now.subtract(const Duration(days: 30));
        dataPoints = 30; // 1 point per day
        break;
      case '6M':
        _startDate = now.subtract(const Duration(days: 180));
        dataPoints = 180; // 1 point per day
        break;
      case '1Y':
        _startDate = now.subtract(const Duration(days: 365));
        dataPoints = 365; // 1 point per day (to ensure smooth month transitions)
        break;
      default:
        _startDate = now.subtract(const Duration(days: 7));
        dataPoints = 24 * 7;
    }

    // Calculate how many original data points to take for each new point
    final totalPoints = sparklineData.length;
    final pointsPerInterval = totalPoints / dataPoints;
    
    // Create new data points by averaging the original data
    _currentChartData = List.generate(dataPoints, (index) {
      final startIdx = (index * pointsPerInterval).floor();
      final endIdx = ((index + 1) * pointsPerInterval).floor();
      
      if (startIdx >= totalPoints) return sparklineData.last;
      
      double sum = 0;
      int count = 0;
      for (var i = startIdx; i < endIdx && i < totalPoints; i++) {
        sum += sparklineData[i];
        count++;
      }
      return count > 0 ? sum / count : sparklineData[startIdx];
    });
  }

  DateTime _getDateForIndex(int index) {
    switch (_selectedTimeFrame) {
      case '1D':
        return _startDate.add(Duration(hours: index));
      case '7D':
        return _startDate.add(Duration(hours: index));
      case '1M':
        return _startDate.add(Duration(days: index));
      case '6M':
        return _startDate.add(Duration(days: index));
      case '1Y':
        return _startDate.add(Duration(days: index));
      default:
        return _startDate.add(Duration(hours: index));
    }
  }

  String _getFormattedDate(DateTime date, String timeFrame) {
    switch (timeFrame) {
      case '1D':
        return DateFormat('HH:mm').format(date);
      case '7D':
        return DateFormat('MMM d').format(date);
      case '1M':
        return DateFormat('MMM d').format(date);
      case '6M':
        return DateFormat('MMM d').format(date);
      case '1Y':
        return DateFormat('MMM').format(date);
      default:
        return DateFormat('MMM d').format(date);
    }
  }

  int _getIntervalCount(String timeFrame) {
    switch (timeFrame) {
      case '1D':
        return 7; // Show 6 intervals plus end
      case '7D':
        return 8; // Show 7 intervals plus end
      case '1M':
        return 7; // Show 6 intervals plus end
      case '6M':
        return 7; // Show 6 intervals plus end
      case '1Y':
        return 13; // Show all 12 months plus end
      default:
        return 8;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);
    final isPositive = widget.crypto.priceChangePercentage24h >= 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              title: Row(
                children: [
                  Hero(
                    tag: 'crypto-icon-${widget.crypto.id}',
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.crypto.image),
                      radius: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.crypto.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _error,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _retryLoadDetails,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price Card
                          Card(
                            margin: const EdgeInsets.all(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currencyFormat.format(widget.crypto.currentPrice),
                                            style: const TextStyle(
                                              fontSize: 28,
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
                                              '${isPositive ? '+' : ''}${percentFormat.format(widget.crypto.priceChangePercentage24h / 100)}',
                                              style: TextStyle(
                                                color: isPositive ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        widget.crypto.symbol.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[400],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn().slideY(),
                          
                          // Time Frame Selector
                          _buildTimeFrameSelector(),

                          // Price Chart
                          if (widget.crypto.sparklineData.isNotEmpty)
                            Card(
                              margin: const EdgeInsets.all(16),
                              color: const Color(0xFF171B26),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                height: 400,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                                                    .format(_touchedValue ?? widget.crypto.currentPrice),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    DateFormat('MMM dd, yyyy')
                                                        .format(_touchedDate ?? DateTime.now()),
                                                    style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    DateFormat('HH:mm')
                                                        .format(_touchedDate ?? DateTime.now()),
                                                    style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                                        child: LineChart(
                                          LineChartData(
                                            backgroundColor: const Color(0xFF171B26),
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: true,
                                              horizontalInterval: _calculateYAxisInterval(widget.crypto.sparklineData),
                                              verticalInterval: widget.crypto.sparklineData.length / 6,
                                              getDrawingHorizontalLine: (value) => FlLine(
                                                color: Colors.grey.withOpacity(0.1),
                                                strokeWidth: 1,
                                                dashArray: [5, 5],
                                              ),
                                              getDrawingVerticalLine: (value) => FlLine(
                                                color: Colors.grey.withOpacity(0.1),
                                                strokeWidth: 1,
                                                dashArray: [5, 5],
                                              ),
                                            ),
                                            titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 35,
                                                  interval: _selectedTimeFrame == '1Y' 
                                                    ? (_currentChartData.length / 12).floorToDouble()
                                                    : _currentChartData.length / (_getIntervalCount(_selectedTimeFrame) - 1),
                                                  getTitlesWidget: (value, meta) {
                                                    final index = value.toInt();
                                                    
                                                    // For 1Y, show all months
                                                    if (_selectedTimeFrame == '1Y') {
                                                      final monthInterval = (_currentChartData.length / 12).floor();
                                                      // Show label if it's a month boundary
                                                      if (index % monthInterval == 0 || index == _currentChartData.length - 1) {
                                                        final date = _getDateForIndex(index);
                                                        return Padding(
                                                          padding: const EdgeInsets.only(top: 8),
                                                          child: RotatedBox(
                                                            quarterTurns: 1,
                                                            child: Text(
                                                              DateFormat('MMM').format(date),
                                                              style: TextStyle(
                                                                color: Colors.grey[500],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      return const SizedBox.shrink();
                                                    }

                                                    // For 7D and 1D, show more frequent intervals
                                                    if (_selectedTimeFrame == '7D' || _selectedTimeFrame == '1D') {
                                                      final intervals = _getIntervalCount(_selectedTimeFrame) - 1;
                                                      if (index == 0 || index == _currentChartData.length - 1 || 
                                                          index % (_currentChartData.length ~/ intervals) == 0) {
                                                        final date = _getDateForIndex(index);
                                                        return Padding(
                                                          padding: const EdgeInsets.only(top: 8),
                                                          child: Text(
                                                            _getFormattedDate(date, _selectedTimeFrame),
                                                            style: TextStyle(
                                                              color: Colors.grey[500],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }

                                                    // For other time frames
                                                    if (index == 0 || index == _currentChartData.length - 1 || 
                                                        index % (_currentChartData.length ~/ (_getIntervalCount(_selectedTimeFrame) - 1)) == 0) {
                                                      final date = _getDateForIndex(index);
                                                      return Padding(
                                                        padding: const EdgeInsets.only(top: 8),
                                                        child: Text(
                                                          _getFormattedDate(date, _selectedTimeFrame),
                                                          style: TextStyle(
                                                            color: Colors.grey[500],
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return const Text('');
                                                  },
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 85,
                                                  interval: _calculateYAxisInterval(_currentChartData),
                                                  getTitlesWidget: (value, meta) {
                                                    // Get the magnitude of the price to determine decimal places
                                                    double magnitude = _currentChartData.reduce((a, b) => a > b ? a : b).abs();
                                                    
                                                    // Determine decimal places based on price magnitude
                                                    int decimalPlaces;
                                                    if (magnitude >= 1000) {
                                                      decimalPlaces = 0;
                                                    } else if (magnitude >= 1) {
                                                      decimalPlaces = 2;
                                                    } else if (magnitude >= 0.01) {
                                                      decimalPlaces = 4;
                                                    } else {
                                                      decimalPlaces = 6;
                                                    }

                                                    return SideTitleWidget(
                                                      axisSide: meta.axisSide,
                                                      child: Text(
                                                        NumberFormat.currency(
                                                          symbol: '\$',
                                                          decimalDigits: decimalPlaces,
                                                        ).format(value),
                                                        style: TextStyle(
                                                          color: Colors.grey[500],
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(show: false),
                                            minX: 0,
                                            maxX: _currentChartData.length.toDouble() - 1,
                                            minY: _currentChartData.reduce((a, b) => a < b ? a : b) * 0.99,
                                            maxY: _currentChartData.reduce((a, b) => a > b ? a : b) * 1.01,
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: _currentChartData.asMap().entries.map((entry) {
                                                  return FlSpot(entry.key.toDouble(), entry.value);
                                                }).toList(),
                                                isCurved: true,
                                                color: isPositive ? const Color(0xFF00A577) : const Color(0xFFFF4976),
                                                barWidth: 2,
                                                isStrokeCapRound: true,
                                                dotData: const FlDotData(show: false),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      isPositive ? const Color(0xFF00A577).withOpacity(0.2) : const Color(0xFFFF4976).withOpacity(0.2),
                                                      isPositive ? const Color(0xFF00A577).withOpacity(0.0) : const Color(0xFFFF4976).withOpacity(0.0),
                                                    ],
                                                    stops: const [0.0, 0.7],
                                                  ),
                                                ),
                                              ),
                                            ],
                                            lineTouchData: LineTouchData(
                                              enabled: true,
                                              touchTooltipData: LineTouchTooltipData(
                                                tooltipBgColor: Colors.transparent,
                                                tooltipPadding: EdgeInsets.zero,
                                                tooltipMargin: 0,
                                                getTooltipItems: (touchedSpots) => [],
                                              ),
                                              getTouchedSpotIndicator: (barData, spotIndexes) {
                                                return spotIndexes.map((index) {
                                                  return TouchedSpotIndicatorData(
                                                    FlLine(
                                                      color: Colors.white.withOpacity(0.3),
                                                      strokeWidth: 1,
                                                    ),
                                                    FlDotData(
                                                      show: true,
                                                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                                        radius: 4,
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                        strokeColor: isPositive ? const Color(0xFF00A577) : const Color(0xFFFF4976),
                                                      ),
                                                    ),
                                                  );
                                                }).toList();
                                              },
                                              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                                                if (event is FlPanEndEvent || event is FlTapUpEvent) {
                                                  setState(() {
                                                    _touchedValue = null;
                                                    _touchedDate = null;
                                                  });
                                                  return;
                                                }

                                                if (response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
                                                  final spot = response.lineBarSpots![0];
                                                  final pointIndex = spot.x.toInt();
                                                  
                                                  setState(() {
                                                    _touchedValue = spot.y;
                                                    _touchedDate = _getDateForIndex(pointIndex);
                                                  });
                                                }
                                              },
                                              mouseCursorResolver: (event, response) => SystemMouseCursors.click,
                                              handleBuiltInTouches: true,
                                              touchSpotThreshold: 50,
                                              longPressDuration: Duration.zero,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn().slideX(),

                          // Market Stats
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Market Stats',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        _buildStatRow(
                                          'Market Cap',
                                          currencyFormat.format(widget.crypto.marketCap),
                                          Icons.bar_chart,
                                        ),
                                        const Divider(),
                                        _buildStatRow(
                                          'Market Cap Rank',
                                          '#${widget.crypto.marketCapRank}',
                                          Icons.leaderboard,
                                        ),
                                        if (_details != null) ...[
                                          const Divider(),
                                          _buildStatRow(
                                            'Circulating Supply',
                                            '${NumberFormat.compact().format(_details!['market_data']['circulating_supply'] ?? 0)} ${widget.crypto.symbol.toUpperCase()}',
                                            Icons.cyclone,
                                          ),
                                          const Divider(),
                                          _buildStatRow(
                                            'Total Supply',
                                            '${NumberFormat.compact().format(_details!['market_data']['total_supply'] ?? 0)} ${widget.crypto.symbol.toUpperCase()}',
                                            Icons.all_inclusive,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn().slideX(),
                              ],
                            ),
                          ),

                          if (_details != null && _details!['description']['en'] != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'About',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        _details!['description']['en'],
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ).animate().fadeIn().slideX(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeFrames.length,
        itemBuilder: (context, index) {
          final timeFrame = _timeFrames[index];
          final isSelected = timeFrame == _selectedTimeFrame;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedTimeFrame = timeFrame;
                    _touchedValue = null;
                    _touchedDate = null;
                    _updateChartData();
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    timeFrame,
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceDisplay() {
    final price = _touchedValue ?? widget.crypto.currentPrice;
    final date = _touchedDate ?? DateTime.now();
    final isPositive = widget.crypto.priceChangePercentage24h >= 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(price),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy HH:mm').format(date),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${isPositive ? '+' : ''}${NumberFormat.decimalPercentPattern(decimalDigits: 2).format(widget.crypto.priceChangePercentage24h / 100)}',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateYAxisInterval(List<double> prices) {
    if (_currentChartData.isEmpty) return 1.0;
    
    double minPrice = _currentChartData.reduce((a, b) => a < b ? a : b);
    double maxPrice = _currentChartData.reduce((a, b) => a > b ? a : b);
    double priceRange = maxPrice - minPrice;
    
    // Get the order of magnitude of the price
    double magnitude = maxPrice.abs();
    
    // Calculate number of steps we want to show (5-8 steps looks good)
    const targetSteps = 6;
    
    if (magnitude >= 10000) {
      // For high value coins like BTC
      return (priceRange / targetSteps / 1000).round() * 1000;
    } else if (magnitude >= 1000) {
      // For coins like ETH
      return (priceRange / targetSteps / 100).round() * 100;
    } else if (magnitude >= 100) {
      // For coins like BNB, SOL
      return (priceRange / targetSteps / 10).round() * 10;
    } else if (magnitude >= 10) {
      // For coins like LINK, DOT
      return (priceRange / targetSteps).round().toDouble();
    } else if (magnitude >= 1) {
      // For coins around $1-10
      return (priceRange / targetSteps * 2).round() / 2;
    } else if (magnitude >= 0.1) {
      // For coins like DOGE
      return (priceRange / targetSteps * 10).round() / 10;
    } else if (magnitude >= 0.01) {
      // For very low value coins
      return (priceRange / targetSteps * 100).round() / 100;
    } else {
      // For micro-value coins
      return (priceRange / targetSteps * 1000).round() / 1000;
    }
  }

  List<FlSpot> _getReducedDataPoints(List<double> prices) {
    if (prices.isEmpty) return [];
    return prices.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
} 