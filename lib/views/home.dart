import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/controllers/fbm.dart';
import 'package:cs530_mobile/controllers/localdb.dart';
import 'package:cs530_mobile/models/Category.dart';
import 'package:cs530_mobile/anims/animation_homepage.dart';
import 'package:cs530_mobile/views/calendar.dart';
import 'package:cs530_mobile/widgets/home_card.dart';
import 'package:cs530_mobile/widgets/home_top_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Animation<double> ba;

  late AnimationController _bc;

  @override
  initState() {
    super.initState();
    _getSavedCategories();
    _getCategories();

    _bc = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat();
    ba = CurvedAnimation(parent: _bc, curve: Curves.easeIn);
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            snap: false,
            floating: false,
            elevation: 0,
            expandedHeight: 190.0,
            flexibleSpace: FlexibleSpaceBar(
              title: FittedBox(
                fit:  BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.only( right: 60.0),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      WavyAnimatedText(                    
                        'VOLUNTARY SPAM APP',
                        textAlign: TextAlign.justify,
                        textStyle: GoogleFonts.robotoCondensed(                      
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w400),
                        speed: const Duration(milliseconds: 200),
                      ),
                    ],
                    totalRepeatCount: 1,
                    pause: const Duration(milliseconds: 1000),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                ),
              ),
              background: const HomeTopViewWidget(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: _getBottomAppBar(),
          ),
        ],
      ),
    );
  }

  Widget _getBottomAppBar() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: aT.evaluate(ba),
            end: aB.evaluate(ba),
            colors: [
              darkBackground.evaluate(ba)!,
              normalBackground.evaluate(ba)!,
              lightBackground.evaluate(ba)!,
            ],
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          child: Column(            
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        assetName: 'upcoming',
                        name: 'UPCOMING\nEVENTS',),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CalendarPage()));
                    },
                    child: const HomeCardWidget(
                        assetName: 'marking_calendar', name: 'ALL\nEVENTS'),
                  ),
                  GestureDetector(                
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
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
                          });
                    },
                    child: const HomeCardWidget(
                        assetName: 'hist', name: 'NOTIFICATION\nHISTORY'),
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
