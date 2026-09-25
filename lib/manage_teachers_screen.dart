import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'helpers.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});
  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final idController = TextEditingController();
  final deptController = TextEditingController();
  final desController = TextEditingController();

  void addTeacher() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'teacher',
        'name': nameController.text.trim(),
        'idNumber': idController.text.trim(),
        'dept': deptController.text.trim(),
        'designation': desController.text.trim(),
      });

      await FirebaseFirestore.instance.collection('teachers').doc(uid).set({
        'uid': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'teacherId': idController.text.trim(),
        'dept': deptController.text.trim(),
        'designation': desController.text.trim(),
        'role': 'teacher',
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
                TextField(controller: desController, decoration: InputDecoration(labelText: 'Designation')),
                TextField(controller: idController, decoration: InputDecoration(labelText: 'Teacher ID')),
                TextField(controller: deptController, decoration: InputDecoration(labelText: 'Department')),
                TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
                TextField(controller: passController, decoration: InputDecoration(labelText: 'Password')),
                SizedBox(height: 20),
                ElevatedButton(onPressed: addTeacher, child: Text('Save Teacher')),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Teachers'), backgroundColor: Colors.brown),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var teacher = docs[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(teacher['name']),
                subtitle: Text('${teacher['designation']} | Dept: ${teacher['dept']}'),
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