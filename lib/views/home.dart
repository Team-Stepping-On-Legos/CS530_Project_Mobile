import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/controllers/custom_page_route.dart';
import 'package:cs530_mobile/controllers/fbm.dart';
import 'package:cs530_mobile/controllers/utils.dart';
import 'package:cs530_mobile/models/category_data.dart';
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
  // Online Connectivity Initialization
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Initialize a variable with [none] status to avoid nulls at startup
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  // Future for connectivity
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectivityResult = result;
      if (!(_connectivityResult == ConnectivityResult.mobile ||
          _connectivityResult == ConnectivityResult.wifi)) {
        showConnectivityDialog();
      }
      if (_connectivityResult == ConnectivityResult.mobile ||
          _connectivityResult == ConnectivityResult.wifi) {
        if (_isOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          _getSavedCategories();

          _getCategories().then((_) => setState(() {
                downloadCategoriesCheck = false;
              }));
        }
      }
    });
  }

  bool _isOpen = false;
  bool isDoneFindingConnection = true;

  bool downloadCategoriesCheck = true;
  late AnimationController _animationController;

  Future<void> isConnected() async {
    // Online Connectivity Initialization
    _connectivityResult = await (Connectivity().checkConnectivity());
    if (!(_connectivityResult == ConnectivityResult.mobile ||
        _connectivityResult == ConnectivityResult.wifi)) {
      showConnectivityDialog();
    }
  }

  @override
  initState() {
    _isOpen = false;
    // CONNCETIVITY
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    isConnected().then((_) => setState(() {
          isDoneFindingConnection = false;
        }));

    _getSavedCategories();

    _getCategories().then((_) => setState(() {
          downloadCategoriesCheck = false;
        }));
    super.initState();
  }

  @override
  dispose() {
    if (_connectivitySubscription != null) {
      _connectivitySubscription!.cancel();
    }

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
    readContent("categories").then((String? value) {
      setState(() {
        if (value != null) {
          readCategoryList = jsonDecode(value);
        }
      });
    });
  }

  _showDialogCategories() {
    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.deepPurple.withAlpha(20),
        builder: (BuildContext context) {
          List<String> selectedCategoryList = [];
          if (readCategoryList.isNotEmpty) {
            for (var element in readCategoryList) {
              selectedCategoryList.add(element);
            }
          }
          //Here we will build the content of the dialog
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.grey.withAlpha(20),
              child: AlertDialog(
                backgroundColor: Colors.grey.withAlpha(20),
                title: Center(
                  child: Text(
                    "CATEGORIES",
                    style: GoogleFonts.robotoCondensed(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 28,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                content: categoryList.isNotEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                            tag: 'HeroOne',
                            child: Lottie.asset(
                              'assets/groucy_lady.json',
                              repeat: true,
                              reverse: true,
                              animate: true,
                              height: 150,
                              width: 150,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MultiSelectChip(
                            categoryList,
                            readCategoryList,
                            onSelectionChanged: (selectedList) {
                              setState(() {
                                selectedCategoryList = selectedList;
                              });
                            },
                          ),
                        ],
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
                    child: Lottie.asset(
                      'assets/subscribe.json',
                      repeat: false,
                      reverse: false,
                      animate: false,
                      height: 100,
                      width: 150,
                      controller: _animationController,
                    ),
                    onPressed: () async {
                      FBM fbm = FBM();
                      for (var item in categoryList) {
                        fbm.unSubscribeTopic(item.name);
                      }
                      fbm.subscribeTopics(selectedCategoryList);
                      await writeContent("categories", selectedCategoryList);

                      _animationController.forward();
                      await Future.delayed(const Duration(seconds: 2), () {});
                      _animationController.reverse();
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        progressIndicator: Center(
          child: Lottie.asset(
            'assets/loading.json',
            repeat: true,
            reverse: false,
            animate: true,
            height: 150,
            width: MediaQuery.of(context).size.width - 10,
          ),
        ),
        inAsyncCall: isDoneFindingConnection && downloadCategoriesCheck,
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
          Colors.deepPurple.shade300.withOpacity(.3),
          Colors.indigo.shade300.withOpacity(.3),
          Colors.deepPurple.shade300.withOpacity(.3),
          Colors.indigo.shade300.withOpacity(.3),
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
        // NOTIFICATION HISTORY
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            //Here we will build the content of the dialog
            Navigator.push(
                context,
                // MaterialPageRoute(builder: (context) => EventDetail(cli,isMuted)));
                CustomPageRoute(NotificationHistory(
                  subscribedCategories:
                      getListAsCommaSepratedString(readCategoryList, "Uncat"),
                )));
          },
          child: const HomeCardWidget(
            assetName: 'upcoming',
            name: 'NOTIFICATION\nHISTORY',
          ),
        ),
        // UPCOMING EVENTS
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
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

            Navigator.push(
                context,
                CustomPageRoute(UpcomingViewCalendar(
                  subscribedCategories:
                      getListAsCommaSepratedString(readCategoryList, "Uncat"),
                )));

            // Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => UpcomingViewCalendar(
            //       subscribedCategories: _getSavedCategoriesAsString(),
            //     )));
          },
          child: const HomeCardWidget(
            assetName: 'marking_calendar',
            name: 'EVENTS\nCALENDAR',
          ),
        ),
        // GET NOTIFIED
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            _showDialogCategories();
          },
          child: const HomeCardWidget(
              assetName: 'get_notified', name: 'GET\nNOTIFIED'),
        ),
        // EXIT
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            exit(0);
          },
          child: const HomeCardWidget(assetName: 'exit', name: 'EXIT\nAPP'),
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
      ],
    );
  }

  showConnectivityDialog() {
    setState(() {
      _isOpen = true;
    });

    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.deepPurple.withAlpha(20),
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                backgroundColor: Colors.grey.withAlpha(20),
                child: Lottie.asset(
                  'assets/no_internet.json',
                  repeat: true,
                  reverse: false,
                  animate: true,
                  height: MediaQuery.of(context).size.height - 80,
                  width: MediaQuery.of(context).size.width - 10,
                ),
              ),
            ),
          );
        }).then((_) => setState(() => _isOpen = false));
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
          selectedColor: Colors.red.withOpacity(0.1),
          backgroundColor: Colors.transparent.withAlpha(300),
          label: Text(
            item.name.toUpperCase(),
            style: TextStyle(
                letterSpacing: 1.0,
                color: selectedChoices.contains(item.name)
                    ? Colors.deepPurple
                    : Colors.black26),
          ),
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
