import 'package:flutter/material.dart';
import 'db_service.dart';

class MasterAttendanceScreen extends StatefulWidget {
  final String subjectId;
  final String subjectCode;

  const MasterAttendanceScreen({
    super.key, 
    required this.subjectId, 
    required this.subjectCode,
    required String subjectName,
    required String batch,
  });

  @override
  State<MasterAttendanceScreen> createState() => _MasterAttendanceScreenState();
}

class _MasterAttendanceScreenState extends State<MasterAttendanceScreen> {
  final DbService _dbService = DbService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectCode} - 2023 Batch'),
        backgroundColor: Colors.brown,
      ),
      body: FutureBuilder(
        future: _dbService.buildAttendanceMatrix(subjectId: widget.subjectId, batch: '2023'),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!;
          List students = data['students'];
          List dateKeys = data['dateKeys'];
          Map presentMap = data['presentMap'];

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('Student ID')),
                  for (var date in dateKeys) DataColumn(label: Text(date.toString().substring(5, 10))),
                  const DataColumn(label: Text('Total')),
                ],
                rows: [
                  for (var s in students)
                    DataRow(cells: [
                      DataCell(Text(s['studentId'] ?? '')),
                      for (var d in dateKeys)
                        DataCell(Text(presentMap[s['uid']]?.contains(d) == true ? '✅' : '❌')),
                      DataCell(Text(presentMap[s['uid']]?.length.toString() ?? '0')),
                    ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}