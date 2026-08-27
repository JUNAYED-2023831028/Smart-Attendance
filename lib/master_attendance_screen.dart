import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_service.dart';

class MasterAttendanceScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final String batch;

  const MasterAttendanceScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.batch,
  }) : super(key: key);

  @override
  _MasterAttendanceScreenState createState() => _MasterAttendanceScreenState();
}

class _MasterAttendanceScreenState extends State<MasterAttendanceScreen> {
  final DbService _dbService = DbService();

  static const Color woodDark = Color(0xFF4E342E);
  static const Color woodMid = Color(0xFF8D6E45);
  static const Color woodLight = Color(0xFFB08D57);
  static const Color cardBlue = Color(0xFFE8F1FB);

  static const double rowHeight = 42;
  static const double headerHeight = 46;
  static const double frozenColWidth = 118;
  static const double dateColWidth = 78;
  static const double summaryColWidth = 62;

  final ScrollController _leftVController = ScrollController();
  final ScrollController _rightVController = ScrollController();
  bool _isSyncingScroll = false;

  AttendanceMatrixResult? _matrixData;
  String _dept = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _leftVController.addListener(_onLeftScroll);
    _rightVController.addListener(_onRightScroll);
    _loadData();
  }

  void _onLeftScroll() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    if (_rightVController.hasClients) {
      _rightVController.jumpTo(_leftVController.offset);
    }
    _isSyncingScroll = false;
  }

  void _onRightScroll() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    if (_leftVController.hasClients) {
      _leftVController.jumpTo(_rightVController.offset);
    }
    _isSyncingScroll = false;
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _dbService.buildAttendanceMatrix(
          subjectId: widget.subjectId,
          batch: widget.batch,
        ),
        _dbService.fetchDepartmentForSubject(widget.subjectId),
      ]);
      if (!mounted) return;
      setState(() {
        _matrixData = results[0] as AttendanceMatrixResult;
        _dept = results[1] as String;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _leftVController.dispose();
    _rightVController.dispose();
    super.dispose();
  }

  String _formatDateShort(String dateKey) {
    try {
      final d = DateTime.parse(dateKey);
      return DateFormat('MMM dd').format(d);
    } catch (_) {
      return dateKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Attendance Report'),
        backgroundColor: woodDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [woodDark, woodMid, woodLight],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Error loading report: $_errorMessage',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildHeaderCard(),
                    Expanded(child: _buildMatrixTable()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _headerStat('Department', _dept.isEmpty ? 'N/A' : _dept),
          ),
          Container(width: 1, height: 34, color: Colors.black12),
          Expanded(child: _headerStat('Batch', widget.batch)),
          Container(width: 1, height: 34, color: Colors.black12),
          Expanded(child: _headerStat('Subject', widget.subjectCode)),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.55)),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMatrixTable() {
    final data = _matrixData!;

    if (data.students.isEmpty) {
      return Center(
        child: Text(
          'No students found for Batch ${widget.batch}.',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    if (data.dateKeys.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No attendance sessions recorded yet for this subject/batch.',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    double scrollableWidth =
        (data.dateKeys.length * dateColWidth) + (summaryColWidth * 2);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: frozenColWidth,
            child: Column(
              children: [
                Container(
                  height: headerHeight,
                  alignment: Alignment.center,
                  color: woodDark,
                  child: const Text(
                    'Student ID',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _leftVController,
                    physics: const ClampingScrollPhysics(),
                    itemCount: data.students.length,
                    itemBuilder: (context, index) {
                      var s = data.students[index];
                      return Container(
                        height: rowHeight,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? Colors.white
                              : const Color(0xFFF7F4EF),
                          border: const Border(
                            right: BorderSide(
                              color: Color(0xFFDDDDDD),
                              width: 1.2,
                            ),
                            bottom: BorderSide(
                              color: Color(0xFFEEEEEE),
                              width: 0.6,
                            ),
                          ),
                        ),
                        child: Text(
                          s['studentId'] ?? '',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: scrollableWidth,
                child: Column(
                  children: [
                    Container(
                      height: headerHeight,
                      color: woodMid,
                      child: Row(
                        children: [
                          ...data.dateKeys.map(
                            (d) => Container(
                              width: dateColWidth,
                              alignment: Alignment.center,
                              child: Text(
                                _formatDateShort(d),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: summaryColWidth,
                            alignment: Alignment.center,
                            color: Colors.green.shade700,
                            child: const Text(
                              'Present',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: summaryColWidth,
                            alignment: Alignment.center,
                            color: Colors.red.shade700,
                            child: const Text(
                              'Absent',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _rightVController,
                        physics: const ClampingScrollPhysics(),
                        itemCount: data.students.length,
                        itemBuilder: (context, index) {
                          var s = data.students[index];
                          Set<String> presentDates =
                              data.presentMap[s['uid']] ?? <String>{};
                          int presentCount = data.dateKeys
                              .where((d) => presentDates.contains(d))
                              .length;
                          int absentCount = data.dateKeys.length - presentCount;

                          return Container(
                            height: rowHeight,
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFFF7F4EF),
                            child: Row(
                              children: [
                                ...data.dateKeys.map((d) {
                                  bool isPresent = presentDates.contains(d);
                                  return Container(
                                    width: dateColWidth,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Color(0xFFEEEEEE),
                                          width: 0.6,
                                        ),
                                        bottom: BorderSide(
                                          color: Color(0xFFEEEEEE),
                                          width: 0.6,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      isPresent ? '✅' : '❌',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }),
                                Container(
                                  width: summaryColWidth,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEAF7EC),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFEEEEEE),
                                        width: 0.6,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '$presentCount',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: summaryColWidth,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFCEBEA),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFEEEEEE),
                                        width: 0.6,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '$absentCount',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
