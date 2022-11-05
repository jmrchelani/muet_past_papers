import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseRepo {
  static var instance = FirebaseFirestore.instance;
  static var departmentCollection = instance.collection('departments');
  static var pastPapersCollection = instance.collection('pastPapers');

  static var storage = FirebaseStorage.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getDepartments() {
    return departmentCollection.snapshots();

    // return depts;
  }

  static Future<String?> uploadImage(String imagePath) async {
    var ref = storage
        .ref()
        .child('pastPapers/${DateTime.now().millisecondsSinceEpoch}.jpg');
    var uploadTask = ref.putFile(File(imagePath));
    var url = await (await uploadTask).ref.getDownloadURL();
    return url;
  }

  static Future<void> addPastPaper(
    String departmentUid,
    String subject,
    int semester,
    String filePath,
  ) async {
    var url = await uploadImage(filePath);
    if (url != null) {
      await instance.collection('uploadedPastPapers').add({
        'deptId': departmentUid,
        'subject': subject,
        'paperUrl': url,
        'semester': semester,
      });
    }
  }

  static Future<List<String>> getSubjects(String deptId, int semester) async {
    var data = await pastPapersCollection
        .where('deptId', isEqualTo: deptId)
        .where('semester', isEqualTo: semester)
        .get();
    return data.docs
        .map((e) {
          var returnedData = e.data() as Map<String, dynamic>;
          return returnedData["subject"] as String;
        })
        .toSet()
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getPapers(
    String deptId,
    int semester,
    String subject,
  ) async {
    var data = await pastPapersCollection
        .where('deptId', isEqualTo: deptId)
        .where('semester', isEqualTo: semester)
        .where('subject', isEqualTo: subject)
        .get();
    return data.docs
        .map((e) {
          var returnedData = e.data() as Map<String, dynamic>;
          return {
            'deptId': deptId,
            'semester': semester,
            'subject': returnedData["subject"],
            'paperUrl': returnedData["paperUrl"],
          };
        })
        .toSet()
        .toList();
  }

  static Future<int> getTotalPastPapers(
    String deptId,
  ) async {
    var data =
        await pastPapersCollection.where('deptId', isEqualTo: deptId).get();
    return data.docs.length;
  }
}
