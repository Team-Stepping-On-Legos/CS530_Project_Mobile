import 'dart:convert';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/controllers/fbm.dart';
import 'package:cs530_mobile/controllers/localdb.dart';
import 'package:cs530_mobile/models/category_data.dart';
import 'package:cs530_mobile/views/calendar.dart';
import 'package:cs530_mobile/views/notification_history.dart';
import 'package:cs530_mobile/views/upcoming_events.dart';
import 'package:cs530_mobile/widgets/home_card.dart';
import 'package:cs530_mobile/widgets/home_top_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool downloadCategoriesCheck = true;

  @override
  initState() {
    super.initState();

    _getSavedCategories();

    _getCategories().then((_) => setState(() {
          downloadCategoriesCheck = false;
        }));
  }

  @override
  dispose() {
    super.dispose();
  }

  List<Category> categoryList = [];
  List<dynamic> readCategoryList = [];

  Future<void> _getCategories() async {
    return API.getCategories().then((response) {
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
      body: ModalProgressHUD(
        inAsyncCall: downloadCategoriesCheck,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              snap: false,
              floating: false,
              elevation: 0,
              expandedHeight: 190.0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.symmetric(horizontal: 20),
                title: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText(
                          'VOLUNTARY SPAM',
                          textStyle: GoogleFonts.robotoCondensed(
                              color: Colors.white70,
                              fontSize: 18,
                              letterSpacing: 1.5,
                              wordSpacing: 2.0,
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
      ),
    );
  }

  Widget _getBottomAppBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        stops: const [
          0.1,
          0.4,
          0.6,
          0.9,
        ],
        colors: [
          Colors.white.withOpacity(.5),
          Colors.indigo.shade300.withOpacity(.5),
          Colors.deepPurple.shade300.withOpacity(.5),
          Colors.indigo.withOpacity(.5),
        ],
      )),
      child: BottomAppBar(
        color: Colors.transparent,
        child: _getGridView(),
      ),
    );
  }

  GridView _getGridView() {
    return GridView.count(
      childAspectRatio: 2 / 2,
      primary: false,
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      crossAxisCount: 2,
      children: <Widget>[
        // GET NOTIFIED
        GestureDetector(
          onTap: () {
            _showDialogCategories();
          },
          child: const HomeCardWidget(
              assetName: 'get_notified', name: 'GET\nNOTIFIED'),
        ),
        // UPCOMING EVENTS
        GestureDetector(
          onTap: () {
            //   showDialog(
            //       context: context,
            //       builder: (BuildContext context) {
            //         //Here we will build the content of the dialog
            //         return AlertDialog(
            //           title: const Text("UPCOMING EVENTS"),
            //           content: Lottie.asset(
            //             'assets/404.json',
            //             repeat: true,
            //             reverse: true,
            //             animate: true,
            //             height: 120,
            //             width: 120,
            //           ),
            //           actions: <Widget>[
            //             TextButton(
            //               child: const Text("OK"),
            //               onPressed: () async {
            //                 Navigator.of(context).pop();
            //               },
            //             )
            //           ],
            //         );
            //       });
            // }
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UpcomingViewCalendar(
                    subscribedCategories: _getSavedCategoriesAsString())));
          },
          child: const HomeCardWidget(
            assetName: 'marking_calendar',
            name: 'EVENTS\nCALENDAR',
          ),
        ),
        // ALL EVENTS
        // GestureDetector(
        //   onTap: () {
        //     Navigator.of(context).push(MaterialPageRoute(
        //         builder: (context) => CalendarPage(
        //               subscribedCategories: _getSavedCategoriesAsString(),
        //             )));
        //   },
        //   child: const HomeCardWidget(
        //       assetName: 'upcoming', name: 'ALL\nEVENTS'),
        // ),
        // NOTIFICATION HISTORY
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            //Here we will build the content of the dialog
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NotificationHistory(
                      subscribedCategories: _getSavedCategoriesAsString(),
                    )));
          },
          child: const HomeCardWidget(
            assetName: 'upcoming',
            name: 'NOTIFICATION\nHISTORY',
          ),
        ),
      ],
    );
  }

  String _getSavedCategoriesAsString() {
    return (readCategoryList.join(',') == null)
        ? "Uncat"
        : readCategoryList.join(',').toString() + ",Uncat";
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
