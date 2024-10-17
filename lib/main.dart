import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Open 💘',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: IntroPage(),
    );
  }
}


final nameProvider = StateProvider<String>((ref) => '');
final currentQuestionIndexProvider = StateProvider<int>((ref) => 0);
final noButtonPositionProvider = StateProvider<Offset>((ref) => Offset.zero);
final noButtonMovedProvider = StateProvider<bool>((ref) => false);

final questionsProvider = Provider<List<String>>((ref) => [
  "Hey [name], would you blush if I told you how amazing you are? 😊🌟",
  "[name], would you say yes if I asked you out on a date? 🥰🍽️",
  "So, [name], is it true that you've been looking for someone like me? 😉💘",
  "Is your smile the reason for my heart skipping a beat, [name]? 😍💓",
  "[name], have you been thinking about me as much as I've been thinking about you? 🤔💭💕",
]);

class IntroPage extends ConsumerWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(nameProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[100]!, Colors.pink[50]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText(
                      'Enter Your Name',
                      textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                  isRepeatingAnimation: true,
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onChanged: (value) => ref.read(nameProvider.notifier).state = value,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  child: Text('Start'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    if (name.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DateProposalPage(phoneNumber: '+916202792769'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DateProposalPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  DateProposalPage({required this.phoneNumber});

  @override
  _DateProposalPageState createState() => _DateProposalPageState();
}

class _DateProposalPageState extends ConsumerState<DateProposalPage> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _emojiBgChars = ['💖', '😍', '💕', '💘', '🌟', '✨', '💫', '🌈'];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showNextQuestion() {
    final questions = ref.read(questionsProvider);
    final currentIndex = ref.read(currentQuestionIndexProvider);
    if (currentIndex < questions.length - 1) {
      _animationController.reverse().then((_) {
        ref.read(currentQuestionIndexProvider.notifier).state++;
        ref.read(noButtonMovedProvider.notifier).state = false;
        _animationController.forward();
      });
      _confettiController.play();
    } else {
      _launchWhatsApp();
    }
  }

  void _launchWhatsApp() async {
    String phoneNumber = widget.phoneNumber.replaceAll(RegExp(r'[^\d]+'), '');
    String message = "Hey, I couldn't stop myself from saying yes to everything! 😏 What do you have in mind next?😊";
    String encodedMessage = Uri.encodeComponent(message);
    String whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$encodedMessage";

    try {
      await launch(whatsappUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t open WhatsApp. Is it installed on your device?')),
      );
    }
  }

  void _moveNoButton() {
    final size = MediaQuery.of(context).size;
    ref.read(noButtonMovedProvider.notifier).state = true;
    ref.read(noButtonPositionProvider.notifier).state = Offset(
      20 + Random().nextDouble() * (size.width - 140),
      20 + Random().nextDouble() * (size.height - 140),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(nameProvider);
    final currentQuestionIndex = ref.watch(currentQuestionIndexProvider);
    final noButtonPosition = ref.watch(noButtonPositionProvider);
    final noButtonMoved = ref.watch(noButtonMovedProvider);
    final questions = ref.watch(questionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('PRINCE KUMAR💬'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.pink[100]!, Colors.purple[100]!],
              ),
            ),
          ),
          ...List.generate(50, (index) {
            return Positioned(
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: 0.2,
                child: Text(
                  _emojiBgChars[Random().nextInt(_emojiBgChars.length)],
                  style: TextStyle(fontSize: 30),
                ),
              ),
            );
          }),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _animation,
                    child: Text(
                      questions[currentQuestionIndex].replaceAll('[name]', name),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _showNextQuestion,
                        child: Text('Yes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                      SizedBox(width: 20),
                      if (!noButtonMoved)
                        ElevatedButton(
                          onPressed: _moveNoButton,
                          child: Text('No'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.05,
            ),
          ),
          if (noButtonMoved)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: noButtonPosition.dx,
              top: noButtonPosition.dy,
              child: ElevatedButton(
                onPressed: _moveNoButton,
                child: Text('No'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:confetti/confetti.dart';
// import 'dart:math';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: ' Just Open 💘',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.pink,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         fontFamily: 'Roboto',
//       ),
//       home: IntroPage(),
//     );
//   }
// }

// class IntroPage extends StatefulWidget {
//   @override
//   _IntroPageState createState() => _IntroPageState();
// }

// class _IntroPageState extends State<IntroPage> {
//   final TextEditingController _nameController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData();
//   }

//   void _loadSavedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _nameController.text = prefs.getString('name') ?? '';
//     });
//   }

//   void _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString('name', _nameController.text);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.pink[100]!, Colors.pink[50]!],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AnimatedTextKit(
//                   animatedTexts: [
//                     WavyAnimatedText(
//                       'Enter Your Name',
//                       textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                   isRepeatingAnimation: true,
//                 ),
//                 SizedBox(height: 40),
//                 TextField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: "Name",
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                   ),
//                 ),
//                 SizedBox(height: 40),
//                 ElevatedButton(
//                   child: Text('Start'),
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                   ),
//                   onPressed: () {
//                     if (_nameController.text.isNotEmpty) {
//                       _saveData();
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => DateProposalPage(
//                             name: _nameController.text,
//                             phoneNumber: '+916202792769',
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DateProposalPage extends StatefulWidget {
//   final String name;
//   final String phoneNumber;
//   DateProposalPage({required this.name, required this.phoneNumber});

//   @override
//   _DateProposalPageState createState() => _DateProposalPageState();
// }

// class _DateProposalPageState extends State<DateProposalPage> with SingleTickerProviderStateMixin {
//   int _currentQuestionIndex = 0;
//   late ConfettiController _confettiController;
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   Offset _noButtonPosition = Offset.zero;
//   bool _noButtonMoved = false;

//   final List<String> _questions = [
//   "Hey [name], would you blush if I told you how amazing you are? 😊🌟",
//   "[name], would you say yes if I asked you out on a date? 🥰🍽️",
//   "So, [name], is it true that you've been looking for someone like me? 😉💘",
//   "Is your smile the reason for my heart skipping a beat, [name]? 😍💓",
//   "[name], have you been thinking about me as much as I've been thinking about you? 🤔💭💕",


//   ];

//   final List<String> _emojiBgChars = ['💖', '😍', '💕', '💘', '🌟', '✨', '💫', '🌈'];

//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(duration: Duration(seconds: 2));
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _showNextQuestion() {
//     if (_currentQuestionIndex < _questions.length - 1) {
//       _animationController.reverse().then((_) {
//         setState(() {
//           _currentQuestionIndex++;
//           _noButtonMoved = false;
//         });
//         _animationController.forward();
//       });
//       _confettiController.play();
//     } else {
//       _launchWhatsApp();
//     }
//   }

//   void _launchWhatsApp() async {
   
//     String phoneNumber = widget.phoneNumber.replaceAll(RegExp(r'[^\d]+'), '');
//     String message = "Hey, I couldn't stop myself from saying yes to everything! 😏 What do you have in mind next?😊";
//     String encodedMessage = Uri.encodeComponent(message);
//     String whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$encodedMessage";

//     try {
//       await launch(whatsappUrl);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Couldn\'t open WhatsApp. Is it installed on your device?')),
//       );
//     }
//   }

//   void _moveNoButton() {
//     setState(() {
//       _noButtonMoved = true;
//       _noButtonPosition = Offset(
//         20 + Random().nextDouble() * (MediaQuery.of(context).size.width - 140),
//         20 + Random().nextDouble() * (MediaQuery.of(context).size.height - 140),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Prince Kumar 💬'),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//       ),
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.pink[100]!, Colors.purple[100]!],
//               ),
//             ),
//           ),
//           ...List.generate(50, (index) {
//             return Positioned(
//               left: Random().nextDouble() * MediaQuery.of(context).size.width,
//               top: Random().nextDouble() * MediaQuery.of(context).size.height,
//               child: Opacity(
//                 opacity: 0.2,
//                 child: Text(
//                   _emojiBgChars[Random().nextInt(_emojiBgChars.length)],
//                   style: TextStyle(fontSize: 30),
//                 ),
//               ),
//             );
//           }),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   FadeTransition(
//                     opacity: _animation,
//                     child: Text(
//                       _questions[_currentQuestionIndex].replaceAll('[name]', widget.name),
//                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   SizedBox(height: 40),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: _showNextQuestion,
//                         child: Text('Yes'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.pink,
//                           padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                         ),
//                       ),
//                       SizedBox(width: 20),
//                       if (!_noButtonMoved)
//                         ElevatedButton(
//                           onPressed: _moveNoButton,
//                           child: Text('No'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey,
//                             padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.topCenter,
//             child: ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirection: pi / 2,
//               maxBlastForce: 5,
//               minBlastForce: 2,
//               emissionFrequency: 0.05,
//               numberOfParticles: 50,
//               gravity: 0.05,
//             ),
//           ),
//           if (_noButtonMoved)
//             AnimatedPositioned(
//               duration: Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               left: _noButtonPosition.dx,
//               top: _noButtonPosition.dy,
//               child: ElevatedButton(
//                 onPressed: _moveNoButton,
//                 child: Text('No'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }




























// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:confetti/confetti.dart';
// import 'dart:math';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Just Open 💘',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.pink,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         fontFamily: 'Roboto',
//       ),
//       home: IntroPage(),
//     );
//   }
// }
// class IntroPage extends StatefulWidget {
//   @override
//   _IntroPageState createState() => _IntroPageState();
// }

// class _IntroPageState extends State<IntroPage> {
//   final TextEditingController _nameController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData();
//   }

//   void _loadSavedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _nameController.text = prefs.getString('name') ?? '';
//     });
//   }

//   void _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString('name', _nameController.text);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.pink[100]!, Colors.pink[50]!],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AnimatedTextKit(
//                   animatedTexts: [
//                     WavyAnimatedText(
//                       'Enter Your Name',
//                       textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                   isRepeatingAnimation: true,
//                 ),
//                 SizedBox(height: 40),
//                 TextField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: "Name",
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                   ),
//                 ),
//                 SizedBox(height: 40),
//                 ElevatedButton(
//                   child: Text('Start'),
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                   ),
//                   onPressed: () {
//                     if (_nameController.text.isNotEmpty) {
//                       _saveData();
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => DateProposalPage(
//                             name: _nameController.text,
//                             phoneNumber: '+916202792769',
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DateProposalPage extends StatefulWidget {
//   final String name;
//   final String phoneNumber;
//   DateProposalPage({required this.name, required this.phoneNumber});

//   @override
//   _DateProposalPageState createState() => _DateProposalPageState();
// }

// class _DateProposalPageState extends State<DateProposalPage> with SingleTickerProviderStateMixin {
//   int _currentQuestionIndex = 0;
//   late ConfettiController _confettiController;
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   Offset _noButtonPosition = Offset.zero;
//   bool _noButtonMoved = false;

//   final List<String> _questions = [
//     "Hey [name], would you blush if I told you how amazing you are? 😊🌟",
//     "[name], would you say yes if I asked you out on a date? 🥰🍽️",
//     "So, [name], is it true that you've been looking for someone like me? 😉💘",
//     "Is your smile the reason for my heart skipping a beat, [name]? 😍💓",
//     "[name], have you been thinking about me as much as I've been thinking about you? 🤔💭💕",
//   ];

//   final List<String> _emojiBgChars = ['💖', '😍', '💕', '💘', '🌟', '✨', '💫', '🌈'];

//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(duration: Duration(seconds: 2));
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _showNextQuestion() {
//     if (_currentQuestionIndex < _questions.length - 1) {
//       _animationController.reverse().then((_) {
//         setState(() {
//           _currentQuestionIndex++;
//           _noButtonMoved = false;
//         });
//         _animationController.forward();
//       });
//       _confettiController.play();
//     } else {
//       _launchWhatsApp();
//     }
//   }

//   void _launchWhatsApp() async {
//     String phoneNumber = widget.phoneNumber.replaceAll(RegExp(r'[^\d]+'), '');
//     String message = "Hey, I couldn't stop myself from saying yes to everything! 😏 What do you have in mind next?😊";
//     String encodedMessage = Uri.encodeComponent(message);
//     String whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$encodedMessage";

//     try {
//       await launch(whatsappUrl);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Couldn\'t open WhatsApp. Is it installed on your device?')),
//       );
//     }
//   }

//   void _moveNoButton() {
//     setState(() {
//       _noButtonMoved = true;
//       _noButtonPosition = Offset(
//         20 + Random().nextDouble() * (MediaQuery.of(context).size.width - 140),
//         20 + Random().nextDouble() * (MediaQuery.of(context).size.height - 140),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PRINCE KUMAR💬'),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//       ),
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.pink[100]!, Colors.purple[100]!],
//               ),
//             ),
//           ),
//           ...List.generate(50, (index) {
//             return Positioned(
//               left: Random().nextDouble() * MediaQuery.of(context).size.width,
//               top: Random().nextDouble() * MediaQuery.of(context).size.height,
//               child: Opacity(
//                 opacity: 0.2,
//                 child: Text(
//                   _emojiBgChars[Random().nextInt(_emojiBgChars.length)],
//                   style: TextStyle(fontSize: 30),
//                 ),
//               ),
//             );
//           }),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   FadeTransition(
//                     opacity: _animation,
//                     child: Text(
//                       _questions[_currentQuestionIndex].replaceAll('[name]', widget.name),
//                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   SizedBox(height: 40),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: _showNextQuestion,
//                         child: Text('Yes'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.pink,
//                           padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                         ),
//                       ),
//                       SizedBox(width: 20),
//                       if (!_noButtonMoved)
//                         ElevatedButton(
//                           onPressed: _moveNoButton,
//                           child: Text('No'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey,
//                             padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.topCenter,
//             child: ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirection: pi / 2,
//               maxBlastForce: 5,
//               minBlastForce: 2,
//               emissionFrequency: 0.05,
//               numberOfParticles: 50,
//               gravity: 0.05,
//             ),
//           ),
//           if (_noButtonMoved)
//             AnimatedPositioned(
//               duration: Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               left: _noButtonPosition.dx,
//               top: _noButtonPosition.dy,
//               child: ElevatedButton(
//                 onPressed: _moveNoButton,
//                 child: Text('No'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }



