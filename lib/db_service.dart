import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  final db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> teacherSubjects(String tid) {
    return db.collection('subjects').where('assignedTeacherId', isEqualTo: tid).snapshots();
  }

  Future<String> createSession(String subId, String tid, String qr) async {
    var doc = await db.collection('sessions').add({
      'subId': subId,
      'tid': tid,
      'batch': '2023',
      'qr': qr,
      'status': 'active',
      'date': DateTime.now().toString().substring(0, 10),
    });
    return doc.id;
  }

  Future<void> closeSession(String sid) async {
    await db.collection('sessions').doc(sid).update({'status': 'closed'});
  }

  Future<void> markAttendance(String sid, String uid) async {
    var sDoc = await db.collection('students').doc(uid).get();
    var sesDoc = await db.collection('sessions').doc(sid).get();
    var sData = sDoc.data()!;
    var sesData = sesDoc.data()!;

    await db.collection('records').add({
      'sid': sid,
      'uid': uid,
      'name': sData['name'],
      'studentId': sData['studentId'],
      'subId': sesData['subId'],
      'batch': '2023',
      'date': sesData['date'],
      'status': 'Present',
    });
  }

  Future<Map<String, dynamic>> buildAttendanceMatrix({required String subjectId, required String batch}) async {
    var sRes = await db.collection('students').where('batch', isEqualTo: '2023').get();
    var rRes = await db.collection('records').where('subId', isEqualTo: subjectId).get();

    List students = sRes.docs.map((d) => {'uid': d.id, 'studentId': d.data()['studentId']}).toList();
    Set<String> dates = {};
    Map<String, Set<String>> presentMap = {};

    for (var d in rRes.docs) {
      var data = d.data();
      String date = data['date'] ?? 'N/A';
      dates.add(date);
      if (presentMap[data['uid']] == null) {
        presentMap[data['uid']] = {};
      }
      presentMap[data['uid']]!.add(date);
    }

    return {'students': students, 'dateKeys': dates.toList(), 'presentMap': presentMap};
  }

  Future<String> fetchDepartmentForSubject(String subId) async {
    return "CSE"; 
  }

  Stream<QuerySnapshot> studentAttendance(String uid) {
    return db.collection('records').where('uid', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot> subjects() {
    return db.collection('subjects').snapshots();
  }

  Future<List<Map<String, dynamic>>> students() async {
    var res = await db.collection('students').where('batch', isEqualTo: '2023').get();
    return res.docs.map((d) => {
      'uid': d.id,
      'name': d.data()['name'],
      'studentId': d.data()['studentId'],
    }).toList();
  }
}