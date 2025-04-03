import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AttendanceCalculatorApp());
}

class AttendanceCalculatorApp extends StatelessWidget {
  const AttendanceCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          primary: const Color(0xFF6750A4),
          primaryContainer: const Color(0xFFEADDFF),
          onPrimary: Colors.white,
          secondary: const Color(0xFF625B71),
          secondaryContainer: const Color(0xFFE8DEF8),
          surface: const Color(0xFFFFFBFE),
          background: const Color(0xFFF5F5F7),
        ),
        useMaterial3: true,
      ),
      home: const AttendanceCalculatorScreen(),
    );
  }
}

class AttendanceCalculatorScreen extends StatefulWidget {
  const AttendanceCalculatorScreen({super.key});

  @override
  State<AttendanceCalculatorScreen> createState() => _AttendanceCalculatorScreenState();
}

class _AttendanceCalculatorScreenState extends State<AttendanceCalculatorScreen> {
  final TextEditingController _attendedController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  String? _errorMessage;
  CalculationResult? _result;
  bool _isCalculating = false;
  bool _hasCalculated = false;
  final List<AttendanceData> _tableData = [];

  @override
  void dispose() {
    _attendedController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _calculateAttendance() {
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isCalculating = true;
      _errorMessage = null;
      _result = null;
      _tableData.clear();
      _hasCalculated = false;
    });

    final attended = int.tryParse(_attendedController.text) ?? 0;
    final total = int.tryParse(_totalController.text) ?? 0;

    if (attended < 0 || total <= 0 || attended > total) {
      setState(() {
        _errorMessage = "Please enter valid numbers (Attended ≤ Total)";
        _isCalculating = false;
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _performCalculation(attended, total);
      setState(() {
        _hasCalculated = true;
      });
    });
  }

  void _performCalculation(int attended, int total) {
    final percentage = (attended / total) * 100;
    _tableData.add(AttendanceData(attended, total, percentage));

    if (percentage < 75) {
      var needed = 0;
      while ((attended + needed) / (total + needed) * 100 < 75) {
        needed++;
        final newAttended = attended + needed;
        final newTotal = total + needed;
        final newPercentage = (newAttended / newTotal) * 100;
        _tableData.add(AttendanceData(newAttended, newTotal, newPercentage));
      }

      setState(() {
        _result = CalculationResult(
          isAboveThreshold: false,
          value: needed,
          currentPercentage: percentage,
        );
        _isCalculating = false;
      });
    } else {
      var bunks = 0;
      while (attended / (total + bunks) * 100 > 75) {
        bunks++;
        final newTotal = total + bunks;
        final newPercentage = (attended / newTotal) * 100;
        _tableData.add(AttendanceData(attended, newTotal, newPercentage));
      }

      final safeBunks = bunks - 1;
      setState(() {
        _result = CalculationResult(
          isAboveThreshold: true,
          value: safeBunks,
          currentPercentage: percentage,
        );
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.cast_for_education, color: Colors.white, size: 30),
        title: const Text('ATTENDANCE CALCULATOR', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15
        ,color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 131, 89, 230),
                const Color.fromARGB(255, 78, 32, 156),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: _hasCalculated 
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildAnalysisCard(),
                    if (_result != null) ...[
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _buildProResultCard(context, _result!),
                      ),
                      const SizedBox(height: 24),
                      _buildProjectionCard(),
                    ],
                  ],
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildAnalysisCard(),
                ),
              ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 16),
              // const Text(
              //   // 'ATTENDANCE ANALYSIS',
              //   // style: TextStyle(
              //   //   fontSize: 18,
              //   //   fontWeight: FontWeight.bold,
              //   //   letterSpacing: 1.1,
              //   //   color: Colors.deepPurple,
              //   // ),
              // ),
              const SizedBox(height: 24),
              
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              
              TextField(
                controller: _attendedController,
                decoration: InputDecoration(
                  labelText: 'Classes Attended',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  prefixIcon: const Icon(Icons.check_circle_outline, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _totalController,
                decoration: InputDecoration(
                  labelText: 'Total Classes',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  prefixIcon: const Icon(Icons.event_note, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCalculating ? null : _calculateAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: Colors.deepPurple.withOpacity(0.3),
                  ),
                  child: _isCalculating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
  Icon(Icons.insights, color: Colors.white),
  SizedBox(width: 12),
  Text(
    'ANALYZE',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),
],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ATTENDANCE PROJECTION',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tableData.length,
                  itemBuilder: (context, index) {
                    final data = _tableData[index];
                    return Container(
                      width: 120,
                      margin: EdgeInsets.only(
                        right: index == _tableData.length - 1 ? 0 : 12,
                      ),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Scenario ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${data.attended}/${data.total}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 2.0, 
                                      child: CircularProgressIndicator(
                                        value: data.percentage / 100,
                                        backgroundColor: Colors.grey[200],
                                        color: data.percentage >= 75
                                            ? Colors.green
                                            : Colors.orange,
                                        strokeWidth: 5,
                                      ),
                                    ),
                                    // CircularProgressIndicator(
                                    //   value: data.percentage / 100,
                                    //   backgroundColor: Colors.grey[200],
                                    //   color: data.percentage >= 75
                                    //       ? Colors.green
                                    //       : Colors.orange,
                                    //   strokeWidth: 5,
                                    // ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${data.percentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: data.percentage >= 75
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                        Text(
                                          data.percentage >= 75 ? '✓' : '!',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: data.percentage >= 75
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProResultCard(BuildContext context, CalculationResult result) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: result.isAboveThreshold
                ? [
                    Colors.green.shade50,
                    Colors.green.shade100,
                  ]
                : [
                    Colors.orange.shade50,
                    Colors.orange.shade100,
                  ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: result.currentPercentage / 100,
                    backgroundColor: Colors.grey[200],
                    color: result.isAboveThreshold ? Colors.green : Colors.orange,
                    strokeWidth: 5,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${result.currentPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: result.isAboveThreshold ? Colors.green : Colors.orange,
                      ),
                    ),
                    const Text(
                      'Current',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              result.isAboveThreshold 
                  ? 'SAFE TO SKIP'
                  : 'REQUIRED ATTENDANCE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.value.toString(),
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: result.isAboveThreshold ? Colors.green : Colors.orange,
                height: 1,
              ),
            ),
            Text(
              result.isAboveThreshold ? 'CLASSES' : 'MORE CLASSES',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Target',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '75%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Difference',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${(result.currentPercentage - 75).abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.help_outline, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text(
                'How to Use',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter your attended classes and total classes to get:\n\n'
                '- How many more classes you need to reach 75% attendance\n'
                '- Or how many classes you can skip while maintaining 75%\n\n'
                'The visualization shows all possible scenarios with their percentages.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'GOT IT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceData {
  final int attended;
  final int total;
  final double percentage;

  AttendanceData(this.attended, this.total, this.percentage);
}

class CalculationResult {
  final bool isAboveThreshold;
  final int value;
  final double currentPercentage;

  CalculationResult({
    required this.isAboveThreshold,
    required this.value,
    required this.currentPercentage,
  });
}