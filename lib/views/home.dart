import 'dart:convert';
import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/controllers/fbm.dart';
import 'package:cs530_mobile/controllers/localdb.dart';
import 'package:cs530_mobile/models/Category.dart';
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
    readContent().then((String value) {
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
                  await writeContent(selectedCategoryList);
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.deepPurple,
            decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/bg.jpg"), fit: BoxFit.fill)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    height: 60,
                  ),
                  Lottie.asset('assets/subscriber.json',
                      repeat: true,
                      reverse: true,
                      animate: true,
                      height: 150,
                      width: 150),
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'VOLUNTARY SPAM\nAPP',
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            height: 310,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _showDialogCategories();
                },
                child: Card(
                  color: Colors.white,
                  elevation: 40,
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/get_notified.json',
                        repeat: true,
                        reverse: true,
                        animate: true,
                        height: 150,
                        width: 150,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'GET\nNOTIFIED',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("EVENTS"),
                          content: Lottie.asset(
                            'assets/404.json',
                            repeat: true,
                            reverse: true,
                            animate: true,
                            height: 150,
                            width: 150,
                          ),
                          actions: [
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      });
                },
                child: Card(
                  color: Colors.white,
                  elevation: 40,
                  child: Column(
                    children: [
                      Lottie.asset('assets/marking_calendar.json',
                          repeat: true,
                          reverse: true,
                          animate: true,
                          height: 150,
                          width: 150),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'UPCOMING\nEVENTS',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
