import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBmDj_4UNz8kRrIlJ0Ac8FZ0bJSu63IJrI",
      authDomain: "focuslockversion2.firebaseapp.com",
      projectId: "focuslockversion2",
      storageBucket: "focuslockversion2.appspot.com",
      messagingSenderId: "20642518242",
      appId: "1:20642518242:web:0e67c9f5366db3ee423abb",
    ),
  );
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  runApp(const FocusBeeApp());
}

/* ================= APP ROOT ================= */

class FocusBeeApp extends StatelessWidget {
  const FocusBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Bee',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return const FocusHome();
          return const LoginScreen();
        },
      ),
    );
  }
}

/* ================= LOGIN ================= */

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  String error = "";

  Future<void> submit() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      }
    } catch (_) {
      setState(() => error = "Authentication failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bug_report, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              const Text("Focus Bee 🐝",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              if (error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus(); // VERY IMPORTANT for mobile
                    await submit();
                    },

                  child: Text(isLogin ? "Login" : "Sign Up"),
                ),
              ),

              TextButton(
                onPressed: () =>
                    setState(() => isLogin = !isLogin),
                child: Text(isLogin
                    ? "Don’t have an account? Sign up"
                    : "Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= FOCUS HOME ================= */

class FocusHome extends StatefulWidget {
  const FocusHome({super.key});

  @override
  State<FocusHome> createState() => _FocusHomeState();
}

class _FocusHomeState extends State<FocusHome> {
  int hours = 0;
  int minutes = 25;
  int remainingSeconds = 0;
  bool focusing = false;
  Timer? timer;

  final AudioPlayer player = AudioPlayer();

  Future<void> startFocus() async {
    remainingSeconds = (hours * 3600) + (minutes * 60);
    if (remainingSeconds == 0) return;

    await player.setSource(AssetSource('sounds/alert.wav'));

    setState(() => focusing = true);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 0) {
        t.cancel();
        setState(() => focusing = false);
        showAlert();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  Future<void> showAlert() async {
    await player.resume();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Buzz! Focus Complete 🐝"),
        content: const Text("Great job! Stay productive."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String formatTime(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    return "${h.toString().padLeft(2, '0')} : "
        "${m.toString().padLeft(2, '0')} : "
        "${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Focus Bee 🐝"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Center(child: focusing ? activeUI() : setupUI()),
    );
  }

  /* ================= SETUP UI ================= */

  Widget setupUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${hours.toString().padLeft(2, '0')} : "
          "${minutes.toString().padLeft(2, '0')} : 00",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildWheel(2, hours, (v) => setState(() => hours = v)),
            const SizedBox(width: 16),
            buildWheel(60, minutes, (v) => setState(() => minutes = v)),
          ],
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: startFocus,
          child: const Text("Start Focus"),
        ),

        const SizedBox(height: 16),

        OutlinedButton.icon(
          icon: const Icon(Icons.auto_awesome),
          label: const Text("AI Suggest Focus Time"),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text("AI Recommendation 🐝"),
                content: Text(
                    "Recommended: 25–30 minutes focus\nStay consistent & avoid distractions."),
              ),
            );
          },
        ),
      ],
    );
  }

  /* ================= ACTIVE UI ================= */

  Widget activeUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock, size: 64, color: Colors.amber),
        const SizedBox(height: 12),
        const Text("FOCUS MODE ACTIVE",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          children: const [
            Chip(label: Text("Instagram")),
            Chip(label: Text("YouTube")),
            Chip(label: Text("Facebook")),
            Chip(label: Text("Games")),
          ],
        ),

        const SizedBox(height: 20),

        Text(formatTime(remainingSeconds),
            style: const TextStyle(fontSize: 36)),
      ],
    );
  }

  Widget buildWheel(int count, int value, Function(int) onChanged) {
    return SizedBox(
      height: 150,
      width: 80,
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(initialItem: value),
        onSelectedItemChanged: onChanged,
        children: List.generate(
          count,
          (i) => Center(
            child: Text(i.toString().padLeft(2, '0'),
                style: const TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }
}

