import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_network/image_network.dart';
import 'package:muet_past_papers/models/department.dart';
import 'package:muet_past_papers/utils.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen(
      {Key? key, required this.department, required this.semester})
      : super(key: key);

  final Department department;
  final int semester;

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  String? subjectUid;
  bool isDownloading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            title: Text(
              subjectUid != null ? '$subjectUid' : 'Select Subject',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Color(0xFF23262F),
            centerTitle: true,
          ),
          backgroundColor: Color(0xFFE0E5F7),
          body: subjectUid == null
              ? FutureBuilder<List<String>>(
                  future: FirebaseRepo.getSubjects(
                      widget.department.uid, widget.semester),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF23262F),
                        ),
                      );
                    }
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('No Past Papers Added Yet...'),
                      );
                    }
                    return ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       'Select Semester',
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 24,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        ...List.generate(
                          snapshot.data!.length,
                          (index) {
                            var onPressed = () {
                              setState(() {
                                subjectUid = snapshot.data![index];
                              });
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
                                                  : Color(0xFF23262F)
                                                      .withOpacity(0.4),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              snapshot.data![index],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
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
                    );
                  })
              : Stack(
                  children: [
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: FirebaseRepo.getPapers(
                        widget.department.uid,
                        widget.semester,
                        subjectUid!,
                      ),
                      builder: (c, s) {
                        if (!s.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF23262F),
                            ),
                          );
                        }
                        return ListView(
                          padding: EdgeInsets.all(16),
                          children: [
                            ...List.generate(
                              s.data!.length,
                              (index) {
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: isDownloading
                                          ? null
                                          : () async {
                                              setState(() {
                                                isDownloading = true;
                                              });
                                              var image_id =
                                                  await ImageDownloader
                                                      .downloadImage(
                                                s.data![index]['paperUrl'],
                                              );
                                              if (image_id == null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Could not download image, an unknown error occured!',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Successfully downloaded image: $image_id',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                              setState(() {
                                                isDownloading = false;
                                              });
                                            },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color.fromARGB(255, 47, 50, 61),
                                              Color(0xFF23262F),
                                              Color(0xFF23262F),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(6, 6),
                                              color: Color(0xFF23262F)
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: SizedBox(
                                                height: 400,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.85,
                                                child: kIsWeb
                                                    ? ImageNetwork(
                                                        image: s.data![index]
                                                            ["paperUrl"],
                                                        height: 400,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.85,
                                                        fitWeb: BoxFitWeb.cover,
                                                      )
                                                    : Image.network(
                                                        s.data![index]
                                                            ["paperUrl"],
                                                        height: 400,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.85,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                s.data![index]["subject"],
                                                style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  // fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(
                              height: 60,
                            ),
                          ],
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
                                  primary: Color(0xFF23262F),
                                ),
                                onPressed: () {
                                  setState(() {
                                    subjectUid = null;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'CHANGE SUBJECT',
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
                    ),
                  ],
                ),
        ),
        if (isDownloading) ...[
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF23262F),
              ),
            ),
          ),
        ]
      ],
    );
  }
}
