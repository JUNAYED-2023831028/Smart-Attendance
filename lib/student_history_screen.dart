import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentHistoryScreen extends StatelessWidget {
  final String studentUid;
  const StudentHistoryScreen({super.key, required this.studentUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Colors.brown,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('records')
            .where('uid', isEqualTo: studentUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No records found.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;

              String subject = data['subId'] ?? data['subjectId'] ?? 'Unknown Sub';
              
              String date = 'N/A';
              if (data['date'] != null) {
                date = data['date'];
              } else if (data['timestamp'] != null) {
                date = (data['timestamp'] as Timestamp).toDate().toString().substring(0, 10);
              }

              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text('Subject: $subject'),
                subtitle: Text('Date: $date'),
                trailing: const Text('PRESENT', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              );
            },
          );
        },
      ),
    );
  }
}