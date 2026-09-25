import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'helpers.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});
  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final nameController = TextEditingController();
  final regController = TextEditingController();
  final deptController = TextEditingController();
  final sessionController = TextEditingController();
  final passController = TextEditingController();

  void addStudent() async {
    try {
      String email = regController.text.trim() + '@student.qrattendance.app';

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: passController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'student',
        'name': nameController.text.trim(),
        'idNumber': regController.text.trim(),
        'batch': '2023',
        'dept': deptController.text.trim(),
        'session': sessionController.text.trim(),
      });

      await FirebaseFirestore.instance.collection('students').doc(uid).set({
        'uid': uid,
        'name': nameController.text.trim(),
        'studentId': regController.text.trim(),
        'batch': '2023',
        'dept': deptController.text.trim(),
        'session': sessionController.text.trim(),
      });

      Navigator.pop(context);
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error: $e');
    }
  }

  void showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: regController, decoration: InputDecoration(labelText: 'Reg No')),
              TextField(controller: deptController, decoration: InputDecoration(labelText: 'Dept')),
              TextField(controller: sessionController, decoration: InputDecoration(labelText: 'Session')),
              TextField(controller: passController, decoration: InputDecoration(labelText: 'Password')),
              SizedBox(height: 20),
              ElevatedButton(onPressed: addStudent, child: Text('Save Student')),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Students (2023)'), backgroundColor: Colors.brown),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').where('batch', isEqualTo: '2023').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var student = docs[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(student['name']),
                subtitle: Text('ID: ${student['studentId']} | Dept: ${student['dept']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddSheet,
        child: Icon(Icons.add),
      ),
    );
  }
}