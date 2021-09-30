import 'dart:convert';
import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/controllers/fbm.dart';
import 'package:cs530_mobile/controllers/localdb.dart';
import 'package:cs530_mobile/models/Category.dart';
import 'package:cs530_mobile/views/calendar.dart';
import 'package:cs530_mobile/views/get_started.dart';
import 'package:cs530_mobile/widgets/home_card.dart';
import 'package:cs530_mobile/widgets/home_top_view.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  initState() {
    super.initState();
    _getSavedCategories();
    _getCategories();
  }

  @override
  dispose() {
    super.dispose();
  }

  List<Category> categoryList = [];
  List<dynamic> readCategoryList = [];

  _getCategories() {
    API.getCategories().then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        categoryList = list.map((model) => Category.fromJson(model)).toList();
      });
    });
  }

  _getSavedCategories() {
    readContent("categories").then((String value) {
      setState(() {
        readCategoryList = jsonDecode(value);
      });
    });
  }

  _showDialogCategories() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          List<String> selectedCategoryList = [];
          //Here we will build the content of the dialog
          return AlertDialog(
            title: const Text("CATEGORIES"),
            content: categoryList.isNotEmpty
                ? MultiSelectChip(
                    categoryList,
                    readCategoryList,
                    onSelectionChanged: (selectedList) {
                      setState(() {
                        selectedCategoryList = selectedList;
                      });
                    },
                  )
                : Lottie.asset(
                    'assets/404.json',
                    repeat: true,
                    reverse: true,
                    animate: true,
                    height: 150,
                    width: 150,
                  ),
            actions: <Widget>[
              TextButton(
                child: const Text("SUBSCRIBE"),
                onPressed: () async {
                  FBM fbm = FBM();
                  for (var item in categoryList) {
                    fbm.unSubscribeTopic(item.name);
                  }
                  fbm.subscribeTopics(selectedCategoryList);
                  await writeContent("categories", selectedCategoryList);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent[50],
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeTopViewWidget(),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showDialogCategories();
                    },
                    child: const HomeCardWidget(
                        assetName: 'get_notified', name: 'GET\nNOTIFIED'),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            List<String> selectedCategoryList = [];
                            //Here we will build the content of the dialog
                            return AlertDialog(
                              title: const Text("UPCOMING EVENTS"),
                              content: Lottie.asset(
                                'assets/404.json',
                                repeat: true,
                                reverse: true,
                                animate: true,
                                height: 150,
                                width: 150,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    },
                    child: const HomeCardWidget(
                        assetName: 'marking_calendar',
                        name: 'UPCOMING\nEVENTS'),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const CalendarPage()));
                  },
                  child: const HomeCardWidget(
                      assetName: 'basic_calendar', name: 'ALL\nEVENTS'),
                ),
                GestureDetector(
                  onTap: () { showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            List<String> selectedCategoryList = [];
                            //Here we will build the content of the dialog
                            return AlertDialog(
                              title: const Text("NOTIFICATION HISTORY"),
                              content: Lottie.asset(
                                'assets/404.json',
                                repeat: true,
                                reverse: true,
                                animate: true,
                                height: 150,
                                width: 150,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });},
                  child: const HomeCardWidget(
                      assetName: 'kanban', name: 'NOTIFICATION\nHISTORY'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<Category> categoryList;
  final List<dynamic> readCategoryList;
  final Function(List<String>) onSelectionChanged;
  const MultiSelectChip(this.categoryList, this.readCategoryList,
      {required this.onSelectionChanged});
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = [];
  _buildChoiceList() {
    List<Widget> choices = [];
    for (var item in widget.categoryList) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item.name),
          selected: selectedChoices.contains(item.name),
          onSelected: (selected) {
            setState(() {
              if (selectedChoices.contains(item.name)) {
                selectedChoices.remove(item.name);
                widget.readCategoryList.remove(item.name);
              } else {
                selectedChoices.add(item.name);
                widget.readCategoryList.add(item.name);
              }
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    }
    return choices;
  }

  @override
  void initState() {
    super.initState();
    if (widget.readCategoryList.isNotEmpty) {
      for (var item in widget.readCategoryList) {
        selectedChoices.add(item.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
