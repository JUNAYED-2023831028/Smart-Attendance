import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_generator_screen.dart';
import 'master_attendance_screen.dart';

class TeacherClassesScreen extends StatelessWidget {
  final String teacherUid;
  const TeacherClassesScreen({super.key, required this.teacherUid});

  void showOptions(BuildContext context, String id, String name, String code) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Start QR (Batch 2023)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (c) => QrGeneratorScreen(
                  subjectId: id, subjectName: name, subjectCode: code, teacherUid: teacherUid, batch: '2023',
                )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('View Report (Batch 2023)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (c) => MasterAttendanceScreen(
                  subjectId: id, subjectName: name, subjectCode: code, batch: '2023',
                )));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses'), backgroundColor: Colors.brown),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.
        collection('subjects').
        where('assignedTeacherId', isEqualTo: teacherUid).
        snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var sub = docs[index];
              return ListTile(
                leading: const Icon(Icons.book),
                title: Text(sub['name']),
                subtitle: Text(sub['code']),
                onTap: () => showOptions(context, sub.id, sub['name'], sub['code']),
              );
            },
          );
        },
      ),
    );
  }
}