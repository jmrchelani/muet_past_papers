import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:muet_past_papers/models/department.dart';
import 'package:muet_past_papers/screens/subject_screen.dart';

class DepartmentScreen extends StatelessWidget {
  const DepartmentScreen({Key? key, required this.department})
      : super(key: key);

  final Department department;

  @override
  Widget build(BuildContext context) {
    print(department.uid);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        toolbarHeight: 200,
        flexibleSpace: SizedBox(
          height: 230,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: kIsWeb
                    ? ImageNetwork(
                        image: department.imageUrl,
                        height: 230,
                        width: MediaQuery.of(context).size.width,
                        fitWeb: BoxFitWeb.cover,
                      )
                    : Image.network(
                        department.imageUrl,
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        // colorBlendMode: BlendMode.saturation,
                        // color: Colors.grey,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    iconSize: 25,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.chevron_left_rounded,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // title: Text(
        //   'MUET Past Papers',
        //   style: TextStyle(
        //     color: Colors.white,
        //   ),
        // ),
        // backgroundColor: Color(0xFF23262F),
        // centerTitle: true,
      ),
      backgroundColor: Color(0xFFE0E5F7),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Semester',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          ...List.generate(
            department.noOfSemesters,
            (index) {
              var onPressed = () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SubjectScreen(
                      department: department,
                      semester: index + 1,
                    ),
                  ),
                );
              };
              return Column(
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: (onPressed == null)
                            ? [Colors.grey, Colors.grey.shade400]
                            : [
                                Color.fromARGB(255, 47, 50, 61),
                                Color(0xFF23262F),
                                Color(0xFF23262F),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: onPressed == null
                          ? null
                          : [
                              BoxShadow(
                                offset: Offset(6, 6),
                                color: (onPressed == null)
                                    ? Colors.grey
                                    : Color(0xFF23262F).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                    ),
                    child: MaterialButton(
                      splashColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: onPressed,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(index + 1 == 1 ? "1st" : (index + 1 == 2 ? "2nd" : (index + 1 == 3 ? "3rd" : "${index + 1}th")))} Semester',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
