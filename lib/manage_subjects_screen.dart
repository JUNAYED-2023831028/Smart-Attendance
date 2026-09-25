import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'helpers.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});
  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  String? selectedTeacherId;

  void addSubject() async {
    if (nameController.text.isEmpty || codeController.text.isEmpty || selectedTeacherId == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('subjects').add({
        'name': nameController.text.trim(),
        'code': codeController.text.trim().toUpperCase(),
        'assignedTeacherId': selectedTeacherId,
      });

      Navigator.pop(context);
      nameController.clear();
      codeController.clear();
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
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Subject Name')),
              TextField(controller: codeController, decoration: InputDecoration(labelText: 'Subject Code')),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) return Container();
                  var teachers = snapshot.data!.docs;
                  return DropdownButton<String>(
                    hint: Text('Select Teacher'),
                    value: selectedTeacherId,
                    isExpanded: true,
                    items: teachers.map((doc) {
                      return DropdownMenuItem(value: doc.id, child: Text(doc['name']));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedTeacherId = val;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: addSubject, child: Text('Create Subject')),
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
      appBar: AppBar(title: Text('Manage Subjects'), backgroundColor: Colors.brown),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) return Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var subject = docs[index];
              return ListTile(
                leading: Icon(Icons.book),
                title: Text(subject['name']),
                subtitle: Text('Code: ${subject['code']}'),
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