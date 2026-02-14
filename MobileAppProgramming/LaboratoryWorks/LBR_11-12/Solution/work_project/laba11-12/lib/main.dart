// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'models/adapters.dart';
import 'services/hive_boxes.dart';
import 'services/secure_key_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'services/messaging_service.dart';
import 'services/user_status_service.dart';
import 'ui/users_page.dart';
import 'ui/user_dashboard_page.dart';
import 'ui/user_profile_page.dart';
import 'ui/products_page.dart';
import 'models/user.dart';
import 'ui/encryption_demo_page.dart';
import 'providers/app_provider.dart';
import 'bloc/app_bloc.dart';
import 'ui/auth/login_page.dart';
import 'ui/widgets/feedback_form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  // Initialize Hive (still used for some local data)
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);
  await HiveBoxes.registerAdapters();
  final keyService = SecureKeyService();
  final primaryKey = await keyService.getOrCreatePrimaryKey();
  await HiveBoxes.openAll(key: primaryKey);
  
  // Initialize Firebase Messaging
  final messagingService = MessagingService();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await messagingService.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: BlocProvider(
        create: (context) => AppBloc(appProvider: context.read<AppProvider>())..add(const AppStarted()),
        child: const TravelApp(),
      ),
    ),
  );
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Учет услуг',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/login': (_) => const LoginPage(),
        '/pageview': (_) => const PageViewScreen(),
        '/platform': (_) => const PlatformDemoScreen(),
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  final UserStatusService _userStatusService = UserStatusService();

  String? _initializedUid;
  bool _initInProgress = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const LoginPage();
        }

        if (snapshot.hasData) {
          final firebaseUser = snapshot.data;
          if (firebaseUser != null && _initializedUid != firebaseUser.uid && !_initInProgress) {
            _initializedUid = firebaseUser.uid;
            _initInProgress = true;
            _initializeUser(context, firebaseUser.uid).whenComplete(() {
              _initInProgress = false;
            });
          }
          return const SearchScreen();
        }

        _initializedUid = null;
        return const LoginPage();
      },
    );
  }

  Future<void> _initializeUser(BuildContext context, String userId) async {
    final appProvider = context.read<AppProvider>();
    final appBloc = context.read<AppBloc>();

    var appUser = await appProvider.userProvider.getUserByFirebaseId(userId);
    if (!mounted) return;
    if (appUser != null) {
      await appProvider.setCurrentUser(appUser);
      appBloc.add(SetCurrentUser(appUser));
      await _userStatusService.setUserOnline(userId);
    }
  }
}

/// SearchScreen -> ResultsScreen (передаём direction)
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String tripType = "One Way";
  final fromController = TextEditingController(text: "Rome, Italy");
  final toController = TextEditingController(text: "Florence, Italy");
  
  Future<void> _saveSearchHistory() async {
    try {
      final state = context.read<AppBloc>().state;
      if (state.currentUser != null) {
        context.read<AppBloc>().add(AddSearchHistoryEvent("${fromController.text} → ${toController.text}"));
        // Track search event
        FirebaseService.analytics.logSearch(
          searchTerm: "${fromController.text} → ${toController.text}",
        );
      }
    } catch (_) {}
  }

  Widget _buildTripTypeButton(String label) {
    final isSelected = tripType == label;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isSelected ? Colors.orange : Colors.grey),
        backgroundColor: isSelected ? Colors.orange : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          tripType = label;
        });
      },
      icon: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Colors.white : Colors.grey,
      ),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
        onTap: (i) async {
          if (i == 1) {
            final appProvider = context.read<AppProvider>();
            if (state.currentUser == null) {
              final selected = await Navigator.push<AppUser>(
                context,
                MaterialPageRoute(
                  builder: (_) => UsersPage(
                    onSelect: (u) => Navigator.pop(_, u),
                  ),
                ),
              );
              if (selected == null) return;
              context.read<AppBloc>().add(SetCurrentUser(selected));
            }
            if (state.currentUser != null) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserDashboardPage(currentUser: state.currentUser!)),
              );
            }
          } else if (i == 2) {
            if (state.currentUser != null) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfilePage()),
              );
            } else {
              final selected = await Navigator.push<AppUser>(
                context,
                MaterialPageRoute(
                  builder: (_) => UsersPage(
                    onSelect: (u) => Navigator.pop(_, u),
                  ),
                ),
              );
              if (selected != null) {
                context.read<AppBloc>().add(SetCurrentUser(selected));
              }
            }
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.34,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.indigo.shade200,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_taxi,
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2841E3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF132CC6)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTripTypeButton("One Way"),
                            const SizedBox(width: 12),
                            _buildTripTypeButton("Round Trip"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: fromController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      hintText: "From",
                                      hintStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.indigo),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: toController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      hintText: "To",
                                      hintStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.indigo),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: IconButton(
                                icon: const Icon(Icons.swap_vert, color: Colors.white),
                                onPressed: () {
                                  final temp = fromController.text;
                                  fromController.text = toController.text;
                                  toController.text = temp;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today),
                      labelText: "Date",
                      hintText: "Friday, 10 Sep",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      labelText: "Passengers",
                      hintText: "Adult: 02, Child: 03",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await _saveSearchHistory();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultsScreen(
                            direction: "${fromController.text} → ${toController.text}",
                          ),
                        ),
                      );
                    },
                    child: const Text("Search"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PageViewScreen()));
                    },
                    child: const Text("PageView Demo (pushReplacement)"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/platform');
                    },
                    child: const Text("Platform Demo (pushNamed)"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EncryptionDemoPage()));
                    },
                    child: const Text('Шифрование и сжатие (демо)'),
                  ),
                  if (state.currentUser != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductsPage(currentUser: state.currentUser!),
                          ),
                        );
                      },
                      child: const Text('Поездки'),
                    ),
                  ],
                  const FeedbackForm(),
                ],
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }
}

class ResultsScreen extends StatelessWidget {
  final String direction;
  const ResultsScreen({super.key, required this.direction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            direction,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.home, color: Colors.white),
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.directions_bus, size: 28, color: Colors.white),
                        SizedBox(width: 16),
                        Icon(Icons.train, size: 28, color: Colors.white),
                        SizedBox(width: 16),
                        Icon(Icons.flight, size: 28, color: Colors.white),
                        SizedBox(width: 16),
                        Icon(Icons.directions_car, size: 28, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                RouteCard(
                  company: "EuroLines",
                  price: "\$122",
                  time: "18:30 → 19:25",
                  duration: "0h 35m",
                  from: "Rome Leonardo da Vinci (FCO)",
                  to: "Florence Peretola (FLR)",
                ),
                SizedBox(height: 14),
                RouteCard(
                  company: "EuroLines",
                  price: "\$122",
                  time: "12:30 → 18:29",
                  duration: "1h 42m",
                  from: "Beijing Capital Intl",
                  to: "Al Ghaidah Intl",
                ),
                SizedBox(height: 14),
                RouteCard(
                  company: "EuroLines",
                  price: "\$122",
                  time: "07:10 → 10:33",
                  duration: "3h 12m",
                  from: "Dubai Intl",
                  to: "Hartsfield Atlanta Intl",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final String company;
  final String price;
  final String time;
  final String duration;
  final String from;
  final String to;

  const RouteCard({
    super.key,
    required this.company,
    required this.price,
    required this.time,
    required this.duration,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$company • Cheapest & Fastest",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time, style: const TextStyle(fontSize: 16)),
                Text(price,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Text(duration, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text("From: $from"),
            Text("To: $to"),
          ],
        ),
      ),
    );
  }
}

/// PageView Screen (демо)
class PageViewScreen extends StatelessWidget {
  const PageViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PageView Demo"),
    leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    },
    ),
      ),
    body: PageView(
        children: [
          Container(color: Colors.red, child: const Center(child: Text("Page 1"))),
          Container(color: Colors.green, child: const Center(child: Text("Page 2"))),
          Container(color: Colors.blue, child: const Center(child: Text("Page 3"))),
        ],
      ),
    );
  }
}

/// Platform Demo: два канала для батареи (android/ios), общий канал для Bluetooth и launchBrowser
class PlatformDemoScreen extends StatefulWidget {
  const PlatformDemoScreen({super.key});

  @override
  State<PlatformDemoScreen> createState() => _PlatformDemoScreenState();
}

class _PlatformDemoScreenState extends State<PlatformDemoScreen> {
  static const MethodChannel platformCommon = MethodChannel('demo.flutter/platform');
  static const MethodChannel batteryAndroid = MethodChannel('demo.flutter/battery_android');
  static const MethodChannel batteryIos = MethodChannel('demo.flutter/battery_ios');

  String _batteryAndroid = 'Unknown';
  String _batteryIos = 'Unknown';
  String _bluetoothStatus = 'Unknown';
  File? _image;

  Future<void> _getBatteryAndroid() async {
    try {
      final int result = await batteryAndroid.invokeMethod('getBatteryLevel');
      setState(() {
        _batteryAndroid = '$result%';
      });
    } on PlatformException catch (e) {
      setState(() {
        _batteryAndroid = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _getBatteryIos() async {
    try {
      final int result = await batteryIos.invokeMethod('getBatteryLevel');
      setState(() {
        _batteryIos = '$result%';
      });
    } on PlatformException catch (e) {
      setState(() {
        _batteryIos = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _getBluetooth() async {
    try {
      final bool result = await platformCommon.invokeMethod('getBluetoothStatus');
      setState(() {
        _bluetoothStatus = result ? "ON" : "OFF";
      });
    } on PlatformException catch (e) {
      setState(() {
        _bluetoothStatus = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _launchBrowser() async {
    try {
      await platformCommon.invokeMethod('launchBrowser', {'url': 'https://flutter.dev'});
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot launch browser: ${e.message}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Platform Demo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Battery (Android channel)"),
            ElevatedButton(onPressed: _getBatteryAndroid, child: const Text("Get Battery (Android)")),
            Text("Android channel: $_batteryAndroid"),
            const SizedBox(height: 12),
            const Text("Battery (iOS channel)"),
            ElevatedButton(onPressed: _getBatteryIos, child: const Text("Get Battery (iOS)")),
            Text("iOS channel: $_batteryIos"),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _getBluetooth, child: const Text("Get Bluetooth Status")),
            Text("Bluetooth: $_bluetoothStatus"),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _pickImage, child: const Text("Take Photo (Camera)")),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Image.file(_image!, width: 200, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _launchBrowser, child: const Text("Launch Browser (Platform)")),
            const SizedBox(height: 12),
            const Text(
              'Примечание:\n - Для Android >= 12 может потребоваться BLUETOOTH_CONNECT разрешение.\n - iOS: чтобы увидеть корректный статус Bluetooth, приложение должно иметь права и CoreBluetooth подключение.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
