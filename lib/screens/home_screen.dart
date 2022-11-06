import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muet_past_papers/models/department.dart';
import 'package:muet_past_papers/screens/department_screen.dart';
import 'package:muet_past_papers/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var searchController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      searchController.addListener(() {
        if (searchController.text.isNotEmpty) setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        title: Text(
          'MUET Past Papers',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF23262F),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF23262F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8,
                // top: 8,
                bottom: 12,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEFF3FC),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Icon(
                        Icons.search,
                      ),
                    ),
                    hintText: 'Search',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Dialog box with text "A semester project of 19SW27 (Milton) and 19SW117 (Wajid) for MAD-19SW."

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('About'),
                    content: Text(
                      'A semester project of 19SW27 (Milton) and 19SW117 (Wajid) for MAD-19SW.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.info_outline_rounded,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      // backgroundColor: Color(0xFFE0E5F7),
      body: Stack(
        children: [
          // Container(
          //   decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.topCenter,
          //       end: Alignment.bottomCenter,
          //       colors: [
          //         Color(0xFFEAF4EC),
          //         Color(0xFFD2E9E7),
          //         Color(0xFFB3DBE0),
          //       ],
          //     ),
          //   ),
          //   // child: Spacer(),
          // ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseRepo.getDepartments(),
            builder: (c, s) {
              if (!s.hasData ||
                  s.connectionState == ConnectionState.waiting ||
                  s.data == null) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Color(0xFF23262F),
                ));
              }
              var depts = s.data!.docs
                  .map((e) => Department.fromJson(e.id, e.data()))
                  .toList();
              // only depts which contain the search query
              depts = depts
                  .where((element) => element.name.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ))
                  .toList();
              depts.sort((a, b) => a.name.compareTo(b.name));
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (c, i) => SizedBox(height: 16),
                itemBuilder: (c, i) => DepartmentTile(
                  department: depts[i],
                ),
                itemCount: depts.length,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Color(0xFF23262F),
                      ),
                      onPressed: () {
                        // Shows a modal bottom sheet with department, semester, and subject dropdown fields, allows file upload of 2 mb max.
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          isDismissible: false,
                          builder: (context) {
                            return UploadPaperBottomSheet();
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ADD PAST PAPER',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class UploadPaperBottomSheet extends StatefulWidget {
  const UploadPaperBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<UploadPaperBottomSheet> createState() => _UploadPaperBottomSheetState();
}

class _UploadPaperBottomSheetState extends State<UploadPaperBottomSheet> {
  List<int>? semesters;
  List<Department>? departments;
  List<String>? subjects;
  Department? selectedDepartment;
  int? selectedSemester;
  String? selectedSubject;
  XFile? selectedFile;

  bool isUploading = false;
  bool hasUploaded = false;

  Future<void> loadDepartments() async {
    var depts = await FirebaseRepo.instance.collection('departments').get();
    var _departments =
        depts.docs.map((e) => Department.fromJson(e.id, e.data())).toList();
    _departments.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      departments = _departments;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadDepartments();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasUploaded
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Paper uploaded successfully!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Color(0xFF23262F),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : departments == null || isUploading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF23262F),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            color: Color(0xFF23262F),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                      // SizedBox(
                      //   height: 8,
                      // ),
                      Text(
                        'Upload a Paper',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 32),
                      DropdownButtonFormField<Department>(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          labelText: 'Department',
                        ),
                        items: departments!
                            .map(
                              (e) => DropdownMenuItem<Department>(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedDepartment = v;
                            semesters = List.generate(
                                    v!.noOfSemesters, (index) => index + 1)
                                .toList();
                            selectedSemester = null;
                            selectedSubject = null;
                          });
                        },
                        value: selectedDepartment,
                      ),
                      SizedBox(height: 16),

                      if (departments != null &&
                          selectedDepartment != null &&
                          semesters != null) ...[
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            labelText: 'Semester',
                          ),
                          items: semesters!
                              .map(
                                (e) => DropdownMenuItem<int>(
                                  value: e,
                                  child: Text(e.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (v) async {
                            setState(() {
                              selectedSemester = v;
                              selectedSubject = null;
                              subjects = null;
                            });
                            var _subjects = await FirebaseRepo.getSubjects(
                                selectedDepartment!.uid, selectedSemester!);
                            setState(() {
                              subjects = _subjects;
                            });
                          },
                          value: selectedSemester,
                        ),
                        SizedBox(height: 16),
                      ],
                      if (departments != null &&
                          selectedDepartment != null &&
                          semesters != null &&
                          selectedSemester != null) ...[
                        TextField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            labelText: 'Subject',
                          ),
                          onChanged: (v) {
                            setState(() {
                              selectedSubject = v.isEmpty ? null : v;
                            });
                          },
                        ),
                        // ? DropdownButtonFormField<String>(
                        //     decoration: InputDecoration(
                        //       border: const OutlineInputBorder(),
                        //       labelText: 'Subject',
                        //     ),
                        //     items: subjects!
                        //         .map(
                        //           (e) => DropdownMenuItem<String>(
                        //             value: e,
                        //             child: Text(e),
                        //           ),
                        //         )
                        //         .toList(),
                        //     onChanged: (v) {},
                        //   )
                        SizedBox(height: 16),
                      ],
                      // Row containting a button "Select File" and a text label showing the name of the file
                      if (selectedDepartment != null &&
                          selectedSemester != null &&
                          selectedSubject != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Color(0xFF23262F),
                                ),
                                onPressed: () {
                                  // showDialog for file selection using camera and gallery
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Select File'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: StadiumBorder(),
                                              backgroundColor:
                                                  Color(0xFF23262F),
                                            ),
                                            onPressed: () async {
                                              var file = await ImagePicker()
                                                  .pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              if (file != null) {
                                                setState(() {
                                                  selectedFile = file;
                                                });
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'No file selected. Please try again.'),
                                                  ),
                                                );
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text('From Gallery'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // SizedBox(height: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: StadiumBorder(),
                                              backgroundColor:
                                                  Color(0xFF23262F),
                                            ),
                                            onPressed: () async {
                                              var file = await ImagePicker()
                                                  .pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              if (file != null) {
                                                setState(() {
                                                  selectedFile = file;
                                                });
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'No file captured. Please try again.'),
                                                  ),
                                                );
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text('From Camera'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Select File'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                selectedFile == null
                                    ? 'No file selected'
                                    : '${selectedFile!.name.substring(0, 15)}...',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Color(0xFF23262F),
                        ),
                        onPressed: selectedDepartment != null &&
                                selectedSemester != null &&
                                selectedSubject != null &&
                                selectedFile != null
                            ? () async {
                                setState(() {
                                  isUploading = true;
                                });
                                await FirebaseRepo.addPastPaper(
                                  selectedDepartment!.uid,
                                  selectedSubject!,
                                  selectedSemester!,
                                  selectedFile!.path,
                                );
                                setState(() {
                                  isUploading = false;
                                  hasUploaded = true;
                                  selectedDepartment = null;
                                  selectedSemester = null;
                                  selectedSubject = null;
                                  selectedFile = null;
                                });
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Upload',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Cancel button red color
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class DepartmentTile extends StatelessWidget {
  const DepartmentTile({
    Key? key,
    required this.department,
  }) : super(key: key);

  final Department department;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DepartmentScreen(
              department: department,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Color(0xFFEFF3FC),
                      // border: Border.all(
                      //   color: Color.fromARGB(255, 199, 199, 199)
                      //       .withOpacity(0.2),
                      //   width: 3,
                      // ),
                      // boxShadow: [
                      //   BoxShadow(
                      //     offset: Offset.zero,
                      //     color: Colors.grey,
                      //     blurRadius: 1,
                      //     spreadRadius: 1,
                      //   ),
                      // ],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    // child: Spacer(),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Opacity(
                  opacity: 1,
                  child: kIsWeb
                      ? ImageNetwork(
                          image: department.imageUrl,
                          height: 160,
                          width: 120,
                          fitWeb: BoxFitWeb.cover,
                        )
                      : Image.network(
                          department.imageUrl,
                          height: 160,
                          width: 120,
                          fit: BoxFit.cover,
                          // colorBlendMode: BlendMode.saturation,
                          // color: Colors.grey,
                        ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  height: 120,
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Department of',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            department.name,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<int>(
                          future:
                              FirebaseRepo.getTotalPastPapers(department.uid),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.hasData
                                  ? '${snapshot.data!} Past Papers'
                                  : '...',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
