import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

double? _screenWidth;
double getScreenWidth(BuildContext context) {
  _screenWidth ??= MediaQuery.of(context).size.width;
  return _screenWidth!;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favourites = <WordPair>[];

  void toggleFavourites(BuildContext context) {
    if (favourites.contains(current)) {
      favourites.remove(current);
    } else {
      favourites.add(current);
    }
    notifyListeners();
  }

  void deleteFavourites(WordPair pair,) {
    favourites.remove(pair);
    notifyListeners();
  }

  void deleteAll() {
    favourites.removeRange(0, favourites.length);
    notifyListeners();
  }

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void switchToGen() {
    _selectedIndex = 0;
    notifyListeners();
  }

  void switchToFav() {
    _selectedIndex = 1;
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var selectedIndex = appState.selectedIndex;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavouritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Set status bar color to white
      statusBarIconBrightness: Brightness.dark, // Set status bar icons to dark (optional)
    ));

    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 450) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: PageView(
                        controller: _pageController,
                        children: [
                          GeneratorPage(),
                          FavouritesPage(),
                        ],
                        onPageChanged: (index) {
                          setState(() {
                            appState._selectedIndex = index;
                          });
                        },
                      )
                  ),
                  SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 0.0,
                        ),
                        child: BottomNavigationBar(
                          elevation: 0.0,
                          items: [
                            BottomNavigationBarItem(
                              icon: Icon(Icons.home),
                              label: 'Home',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.favorite),
                              label: 'Favourites',
                            ),
                          ],
                          currentIndex: selectedIndex,
                          onTap: (value) {
                            _pageController.animateToPage(
                                value,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                            );
                            /*setState(() {
                              if (value==0) {
                                appState.switchToGen();
                              } else if (value==1) {
                                appState.switchToFav();
                              }
                            });*/
                          },
                        ),
                      )
                  )
                ],
              );
            } else {
              return Row(
                children: [
                  SafeArea(
                      child: NavigationRail(
                        extended: constraints.maxWidth >= 600,
                        destinations: [
                          NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.favorite),
                            label: Text('Favourites'),
                          ),
                        ],
                        selectedIndex: null,
                        onDestinationSelected: (value) {
                          setState(() {
                            if (value==0) {
                              appState.switchToGen();
                            } else if (value==1) {
                              appState.switchToFav();
                            }
                          });
                        },
                        groupAlignment: 0.0,
                      )
                  ),
                  Expanded(child: page),
                ],
              );
            }
          }
        ),
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favouritesList = appState.favourites;


    if (favouritesList.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('You have no favourites saved yet.'),
                SizedBox(height: 10.0),
                ElevatedButton(
                    onPressed: () {
                      //appState.switchToGen();
                      final pageController = context.findAncestorStateOfType<_MyHomePageState>()?._pageController;
                      pageController?.animateToPage(
                        0, // Index of GeneratorPage
                        duration: Duration(milliseconds: 300), // Adjust duration as needed
                        curve: Curves.easeInOut, // Adjust curve as needed
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15.0
                      ),
                      elevation: 0.0,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Start adding Favourites',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w400,
                        fontSize: getScreenWidth(context)*0.048,
                      ),
                    )
                )
              ],
            ),
          ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 30.0,
                    bottom: 20.0
                  ),
                  child: Text(
                    'You have ${favouritesList.length} favourites!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                for (var fav in favouritesList)
                  ListTile(
                    leading: Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(fav.asLowerCase),
                    trailing: IconButton(
                        onPressed: () {
                          appState.deleteFavourites(fav);
                        },
                        icon: Icon(Icons.delete),
                    ),
                  ),
              ],
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.9,
            child: ElevatedButton(
              onPressed: () {
                appState.deleteAll();
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(250, 45),
                elevation: 0.0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
              ),
              child: Text(
                'Delete all Favourites',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0)
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    final theme = Theme.of(context);

    IconData icon;
    Color iconColor;
    if (appState.favourites.contains(pair)) {
      icon = Icons.favorite;
      iconColor = Colors.redAccent;
    } else {
      icon = Icons.favorite_border;
      iconColor = theme.colorScheme.primary;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFavourites(context);
                    },
                    icon: Icon(icon, color: iconColor),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    label: Text(
                        'Like',
                        style: TextStyle(
                            color: theme.colorScheme.primary
                        )
                    )
                ),
                SizedBox(width: 15),
                ElevatedButton(
                    onPressed: () {
                      appState.getNext();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(color: theme.colorScheme.onPrimary,);

    return Card(
      color: theme.colorScheme.primary,
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pair.first.toLowerCase(),
                style: style.copyWith(
                  fontWeight: FontWeight.w300,
                ),
                semanticsLabel: pair.first,
              ),
              Text(
                pair.second.toLowerCase(),
                style: style.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                semanticsLabel: pair.second,
              ),
            ],
          ),
      ),
    );
  }
}