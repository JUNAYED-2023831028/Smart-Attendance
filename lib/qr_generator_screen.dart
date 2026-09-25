import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'db_service.dart';

class QrGeneratorScreen extends StatefulWidget {
  final String subjectId;
  final String teacherUid;
  final String subjectCode;

  const QrGeneratorScreen({
    super.key,
    required this.subjectId,
    required this.teacherUid,
    required this.subjectCode,
    required String subjectName,
    required String batch,
  });

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final DbService _dbService = DbService();
  String? sessionId;
  bool active = false;

  void startSession() async {
    String sid = await _dbService.createSession(widget.subjectId, widget.teacherUid, widget.subjectId);
    setState(() {
      sessionId = sid;
      active = true;
    });
  }

  void stopSession() async {
    await _dbService.closeSession(sessionId!);
    setState(() {
      active = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR - ${widget.subjectCode}'), backgroundColor: Colors.brown),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (active == false)
              ElevatedButton(onPressed: startSession, child: const Text('Start Attendance Session'))
            else
              Column(
                children: [
                  QrImageView(data: sessionId!, size: 250),
                  const Text('Students Scanning Now...', style: TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton(onPressed: stopSession, child: const Text('Stop Session')),
                  const Divider(),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('records').where('sid', isEqualTo: sessionId).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) return const CircularProgressIndicator();
                      var docs = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.check, color: Colors.green),
                            title: Text(docs[index]['name']),
                            subtitle: Text(docs[index]['studentId']),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}