import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muet_past_papers/models/department.dart';

class FirebaseRepo {
  static var instance = FirebaseFirestore.instance;
  static var departmentCollection = instance.collection('departments');
  static var pastPapersCollection = instance.collection('pastPapers');

  static Stream<QuerySnapshot<Map<String, dynamic>>> getDepartments() {
    return departmentCollection.snapshots();

    // return depts;
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
