class Department {
  final String name, imageUrl, uid;
  final int noOfSemesters;

  Department(this.name, this.imageUrl, this.uid, this.noOfSemesters);

  static Department fromJson(String uid, Map<String, dynamic> data) {
    return Department(
      data['name'],
      data['imageUrl'],
      uid,
      data.containsKey('noOfSemesters') ? data['noOfSemesters'] : 8,
    );
  }
}
