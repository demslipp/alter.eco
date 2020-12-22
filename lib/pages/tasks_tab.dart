import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/models/user.dart';
import 'package:greenapp/pages/task_creation.dart';
import 'package:greenapp/pages/task_list.dart';
import 'package:greenapp/services/base_auth.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:greenapp/widgets/placeholder_content.dart';
import 'package:http/http.dart' as http;

final int INITIAL_ID_FOR_TASKS = 0;

class TasksTab extends StatefulWidget {
  TasksTab({this.baseTaskProvider, this.baseAuth});

  @required
  final BaseTaskProvider baseTaskProvider;
  @required
  final BaseAuth baseAuth;

  @override
  _TasksTabState createState() {
    return _TasksTabState();
  }
}

class _TasksTabState extends State<TasksTab> {
  int theriGroupVakue = 0;
  TaskStatus segmentValue = TaskStatus.CREATED;

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text("Available"),
    1: Text("Assigned"),
  };

  final buttonWidget = <Widget>[
    CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        debugPrint("Check TODO clicked");
      },
      child: const Icon(
        CupertinoIcons.check_mark_circled,
        semanticLabel: 'VoteToDo',
      ),
    ),
    CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        debugPrint("Check resolve clicked");
      },
      child: const Icon(
        CupertinoIcons.check_mark_circled,
        semanticLabel: 'VoteResolve',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return new NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('Tasks'),
              leading: GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Add",
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => TaskCreationPage(
                                baseTaskProvider: widget.baseTaskProvider,
                              )));
                },
              ),
              trailing: buttonWidget[theriGroupVakue],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(Container(
                  height: 50,
                  color: CupertinoColors.systemBackground,
                  child: Center(
                      child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 15.0,
                      ),
                      Expanded(
                        child: CupertinoSegmentedControl(
                          groupValue: theriGroupVakue,
                          onValueChanged: (int changeFromGroupValue) {
                            setState(() {
                              theriGroupVakue = changeFromGroupValue;
                              switch (changeFromGroupValue) {
                                case 0:
                                  segmentValue = TaskStatus.CREATED;
                                  break;
                                case 1:
                                  segmentValue = TaskStatus.IN_PROGRESS;
                                  break;
                                default:
                                  segmentValue = TaskStatus.CREATED;
                                  break;
                              }
                            });
                          },
                          children: logoWidgets,
                        ),
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                    ],
                  )))),
              pinned: true,
            ),
          ];
        },
        body: FutureBuilder(
            future: (segmentValue == TaskStatus.CREATED)
                ? widget.baseTaskProvider.getTasks(INITIAL_ID_FOR_TASKS)
                : widget.baseTaskProvider
                    .getTasksForUser(INITIAL_ID_FOR_TASKS, UserType.LOCAL),
            builder: (context, projectSnapshot) {
              debugPrint(EnumToString.parse(projectSnapshot.connectionState));
              if (projectSnapshot.hasError)
                return PlaceHolderContent(
                  title: "Problem Occurred",
                  message: "Internet not connect try again",
                  tryAgainButton: _tryAgainButtonClick,
                );
              switch (projectSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return _showCircularProgress();
                case ConnectionState.done:
                  {
                    return projectSnapshot.data.length == 0
                        ? _noItemOnServer()
                        : TaskList(
                            baseTaskProvider: widget.baseTaskProvider,
                            taskList: projectSnapshot.data,
                            taskStatus: segmentValue,
                          );
                  }
                default:
                  return _showCircularProgress();
              }
            }));
  }

  void update() {}

  _tryAgainButtonClick(bool _) => setState(() {
        _showCircularProgress();
      });

  Widget _showCircularProgress() {
    return Center(child: CupertinoActivityIndicator());
  }

  Widget _noItemOnServer() {
    debugPrint("No items displayed");
    return Center(
      child: Text(
        'Where is not any items on server',
        style: Styles.body15Regular(),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<List<Task>> getTasksList() async {
    debugPrint("getTasksList");
    http.Response response = await http.post(
      "https://greenapp-gateway.herokuapp.com/task-provider/tasks",
      headers: <String, String>{
        'Authorization':
            "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJzemIwOTkyM0BjdW9seS5jb20iLCJleHAiOjE1OTI3NjQ0MjIsImlhdCI6MTU5Mjc0NjQyMn0.ouTIaGc6hLPE4aKa-TCj_LW2ovkHQ-kCfWhgdiaz9Q9ED14m5uwPH0vczZ82HO9fMcEieZ1va4ZWrs8wJdFhMw",
        'Content-type': 'application/json',
      },
      body: json.encode({
        'status': EnumToString.parse(TaskStatus.CREATED),
        "limit": 10,
        "offset": 0
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      List<Task> taskList = [];
      for (Map i in t) {
        taskList.add(Task.fromJson(i));
      }
      return taskList;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      throw Exception('Failed to parse tasks');
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Container _tabBar;

  @override
  double get minExtent => _tabBar.constraints.constrainHeight();
  @override
  double get maxExtent => _tabBar.constraints.constrainHeight();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
