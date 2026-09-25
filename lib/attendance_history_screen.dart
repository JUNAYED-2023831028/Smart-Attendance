import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String subjectId;
  final String subjectCode;

  const AttendanceHistoryScreen({
    super.key, 
    required this.subjectId, 
    required this.subjectCode,
    required String subjectName,
    required String batch,
  });

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectCode} - History'),
        backgroundColor: Colors.brown,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('records')
            .where('subId', isEqualTo: widget.subjectId)
            .where('batch', isEqualTo: '2023')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No records found for 2023 batch.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['name'] ?? 'Unknown'),
                subtitle: Text('ID: ${data['studentId']} | Date: ${data['date']}'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              );
            },
          );
        },
      ),
    );
  }
}