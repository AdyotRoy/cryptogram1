import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


const String _supabaseUrl = 'https://pnczxyjpydrdochlzclt.supabase.co';
const String _supabaseAnonKey =
    'sb_publishable_yXDnqcTlrGGb8BppNP-6vw_rONAlZuO';

// The *Web application* OAuth client ID (the same one configured in the
// Supabase Google provider).
const String webClientId =
    '2168155933-279hn1tehe64bondv9vcfgsm39g317vd.apps.googleusercontent.com';
const String allowedEmailDomain = 'inspiritvision.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  runApp(const CryptogramApp());
}

final supabase = Supabase.instance.client;

// ─── Google Sign-In (google_sign_in 6.x API) ─────────────────────────────────
// serverClientId is not supported on web, so the mobile instance is only
// created off-web. On web we use Supabase's OAuth redirect instead.
final GoogleSignIn? _googleSignIn = kIsWeb
    ? null
    : GoogleSignIn(
  serverClientId: webClientId,
  clientId: webClientId,
  hostedDomain: allowedEmailDomain,
);
Future<void> signOutEverywhere() async {
  try {
    await supabase.auth.signOut();
  } catch (e) {
    debugPrint('Supabase sign-out error: $e');
  }
  try {
    await _googleSignIn?.signOut();
  } catch (e) {
    debugPrint('Google sign-out error: $e');
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SOURCE LOGIC
// ═════════════════════════════════════════════════════════════════════════════

class CryptogramEngine {
  final String plainText;
  late final Map<String, String> cipherMap;
  late final String encryptedText;

  CryptogramEngine(this.plainText) {
    cipherMap = _generateDerangedMap();
    encryptedText = _encrypt(plainText);
  }

  /// Recreates the exact cipher used by an active session after a refresh.
  CryptogramEngine.restore(
      this.plainText,
      Map<String, String> savedCipherMap,
      ) {
    cipherMap = Map<String, String>.from(savedCipherMap);
    encryptedText = _encrypt(plainText);
  }

  /// Generates a simple substitution map where no letter maps to itself
  Map<String, String> _generateDerangedMap() {
    final alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');
    final shuffled = List<String>.from(alphabet)..shuffle();

    for (int i = 0; i < alphabet.length; i++) {
      if (alphabet[i] == shuffled[i]) {
        final next = (i + 1) % alphabet.length;
        final tmp = shuffled[i];
        shuffled[i] = shuffled[next];
        shuffled[next] = tmp;
      }
    }
    return Map.fromIterables(alphabet, shuffled);
  }

  String _encrypt(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i].toLowerCase();
      if (RegExp(r'[a-z]').hasMatch(char)) {
        buffer.write(cipherMap[char]);
      } else {
        buffer.write(char); // Retain punctuation and spaces
      }
    }
    return buffer.toString();
  }

  /// Validates if current user guesses correctly solve the target sentence
  bool isSolved(Map<String, String> userGuesses) {
    for (int i = 0; i < plainText.length; i++) {
      final targetChar = plainText[i].toLowerCase();

      // Skip spaces and punctuation
      if (!RegExp(r'[a-z]').hasMatch(targetChar)) continue;

      final cipherChar = encryptedText[i].toLowerCase();
      final userGuess = userGuesses[cipherChar]?.toLowerCase() ?? '';

      if (userGuess != targetChar) {
        return false;
      }
    }
    return true;
  }
}

class MockSentenceService {
  // Add more phrases here to widen the daily pool.
  static const List<String> _sentencePool = [
    "stay curious and keep learning",
    "consistency brings great success",
    "creativity is intelligence having fun",
    "action is the key to all success",
    "small steps every day lead to big results",
    "never stop exploring new ideas",
    "clarity comes from taking action",
    "believe you can and you are halfway there",
    "small steps forward still count as progress",
    "every sunrise brings a brand new start",
    "kindness costs nothing but means everything",
    "focus on progress not on perfection",
    "great things take time and patience",
    "believe in yourself before anyone else",
    "hard work always beats natural talent",
    "stay humble stay hungry stay focused",
    "difficult roads often lead to beautiful places",
    "your only limit is your own mind",
    "push yourself because no one else will",
    "success starts with a single decision",
    "dream big and dare to fail",
    "change your thoughts and change your world",
    "the best view comes after the climb",
    "never give up on your goals",
    "do what you can with what you have",
    "wake up with determination sleep with satisfaction",
    "good things come to those who hustle",
    "turn your wounds into wisdom and strength",
    "a little progress each day adds up",
    "doubt kills more dreams than failure does",
    "be stronger than your strongest excuse",
    "learn from yesterday live for today",
    "discipline is choosing what you want most",
    "little by little a little becomes a lot",
    "you are capable of amazing things",
    "trust the process and stay consistent",
    "fall seven times stand up eight",
    "work hard in silence let success speak",
    "positive mindset brings positive outcomes always",
    "nothing worth having comes without effort",
    "chase your dreams not your fears",
    "every expert was once a beginner",
    "keep going you are almost there",
    "great minds discuss ideas not people",
    "actions speak louder than empty words",
    "life rewards those who take chances",
    "stay patient and trust your journey",
    "do more of what makes you happy",
    "your attitude determines your altitude in life",
    "the harder you work the luckier you get",
    "progress not perfection is the goal",
    "start where you are use what you have",
    "courage is grace under real pressure",
    "you miss every shot you never take",
    "consistency beats intensity in the long run",
    "dream it plan it and do it",
    "growth begins at the end of comfort",
    "choose progress over comfort every single day",
    "practice does not make perfect practice makes permanent",
    "be the energy you want to attract",
    "small disciplines repeated daily create huge results",
    "every accomplishment starts with the decision to try",
    "stay focused and never lose sight of goals",
    "hardships often prepare people for greater things",
    "set goals crush them then set new ones",
    "what you focus on tends to expand",
    "motivation gets you started habit keeps you going",
    "winners are not afraid of losing",
    "simplicity is the ultimate form of sophistication",
    "great work comes from great focus",
    "confidence comes from preparation and practice",
    "adaptability is key to long term success",
    "be so good they cannot ignore you",
    "growth is uncomfortable but always worth it",
    "stay curious and never stop learning",
    "champions train when nobody else is watching",
    "every master was once a total disaster",
    "success is a series of small wins",
    "effort is never wasted even in failure",
    "you cannot pour from an empty cup",
    "do the work trust the outcome",
    "the comeback is always stronger than the setback",
    "one day or day one you decide",
    "struggles today build strength for tomorrow",
    "persistence turns failure into extraordinary achievement",
    "great journeys begin with small brave steps",
    "focus on being productive instead of busy",
    "excellence is a habit not an act",
    "better to try and fail than never try",
    "real change happens outside comfort zones",
    "speak less listen more learn faster",
    "patience and persistence conquer almost everything",
    "progress feels slow until suddenly it doesn't",
    "never underestimate the power of consistency",
    "take the risk or lose the chance",
    "your future is created by what you do today",
    "small wins build unstoppable long term momentum",
    "stay grounded but keep reaching higher",
    "discipline outlasts motivation every single time",
    "choose growth even when it is hard",
    "the only failure is giving up early",
    "great things never came from comfort zones",
    "keep learning keep growing keep going",
    "every day is a second chance",
    "do it scared but do it anyway",
    "big journeys start with small commitments",
    "stay grateful stay grounded stay driven",
    "the best time to start is now",
    "the journey matters as much as the destination",
    "plant seeds today and harvest tomorrow",
    "every challenge is a chance to grow",
    "a calm mind makes better decisions",
    "make today so good you smile tomorrow",
    "happiness grows when you share it",
    "listen to your heart and trust your gut",
    "the quiet ones often have the loudest minds",
    "turn obstacles into stepping stones",
    "honesty is the foundation of trust",
    "patience is bitter but its fruit is sweet",
    "small acts of kindness change big things",
    "learn something new every single day",
    "the sky is not the limit it is the start",
    "a smooth sea never made a skilled sailor",
    "bravery means acting despite the fear",
    "good habits are the seeds of success",
    "stars cannot shine without darkness",
    "your story is still being written",
    "wisdom begins with a question",
    "the early bird catches the worm",
    "make time for what truly matters",
    "gratitude turns enough into plenty",
    "mistakes are proof that you are trying",
    "keep your face toward the sunshine",
    "the mountain is climbed one step at a time",
    "rest when you must but never quit",
    "a strong mind creates a strong life",
    "joy is found in the simplest moments",
    "stay true to who you really are",
    "ideas become real when you act on them",
    "the future belongs to the persistent",
    "think big start small act now",
    "doubt is the thief of tomorrow",
    "let your actions tell your story",
    "words can inspire but deeds can change",
    "smooth roads never lead to great heights",
    "a goal without a plan is just a wish",
    "the path to success is always under construction",
    "do something today your future self will love",
    "kind words can be short and easy to speak",
    "every storm eventually runs out of rain",
    "bloom where you are planted and grow",
    "creativity takes courage to share",
    "energy flows where attention goes",
    "opportunities multiply as they are seized",
    "slow progress is still forward progress",
    "the strongest steel is forged in fire",
    "own your today and shape your tomorrow",
    "be the reason someone smiles today",
    "great leaders begin by serving others",
    "your habits shape your destiny",
    "wonder is the beginning of wisdom",
    "begin each day with a grateful heart",
    "nothing changes if nothing changes",
    "trust yourself you know more than you think",
    "fear is only a feeling not a fact",
    "make every moment count toward something good",
    "the best teacher is experience",
    "a quiet mind finds the clearest answers",
    "invest in yourself every single day",
    "hope is the anchor of the soul",
    "perseverance is the secret of all triumphs",
    "light a candle instead of cursing darkness",
    "dedication turns dreams into reality",
    "the present moment is all we really have",
    "reach for the moon and land among stars",
    "every setback carries a lesson inside",
    "keep your eyes on the horizon and walk on",
    "learning never exhausts the mind",
    "choose joy even on ordinary days",
    "strong roots allow tall trees to grow",
    "give more than you take from the world",
    "a brave heart is a powerful tool",
    "hustle in silence and shine in public",
    "build the life you cannot wait to wake up to",
    "the harder the battle the sweeter the victory",
    "take pride in how far you have come",
    "life is short so spend it wisely",
    "your effort today becomes a future reward",
    "peace begins with a single deep breath",
    "the best revenge is massive success",
    "talent is nothing without hard work",
    "even the longest night turns into day",
    "put your heart into everything you do",
    "calm waters teach patience to the sailor",
    "tomorrow rewards those who prepare today",
    "dare to be different and stand out",
    "be a voice and not just an echo",
    "challenges are what make life interesting",
    "the secret of getting ahead is getting started",
    "faith in yourself moves mountains",
    "growth requires leaving comfort behind",
    "do not wait for the perfect moment",
    "take a breath and begin again",
    "perfect practice builds perfect skill",
    "bold choices lead to brilliant outcomes",
    "laughter is the shortest distance between people",
    "when one door closes another one opens",
    "never let fear decide your future",
    "work with passion and the rest follows",
    "each morning is a blank page",
    "stay open to change and new chances",
    "strength grows in moments of struggle",
    "the more you give the more you receive",
    "progress begins the moment you decide",
    "silence is sometimes the best answer",
    "happiness is a direction not a place",
    "a determined spirit cannot be defeated",
    "go the extra mile it is never crowded",
    "turn your pain into your power",
    "good company makes a long road short",
    "focus on solutions instead of problems",
    "without rain there would be no flowers",
    "lead with curiosity and follow with kindness",
    "persevere through the dark to find the dawn",
    "the best investment is in your own mind",
    "keep walking and the road will appear",
    "success is the sum of daily efforts",
    "welcome each day with open arms",
    "believe in the magic of new beginnings",
    "make peace with your past and move on",
    "greatness comes to those who keep trying",
    "let go of what you cannot control",
    "enjoy the little things they matter most",
    "learn to rest but never learn to quit",
    "a thankful heart attracts good things",
    "the road to greatness is paved with effort",
    "every day brings a fresh opportunity",
    "stand tall even when the wind blows hard",
    "your potential is greater than your fear",
    "make your dreams bigger than your doubts",
    "show up every day and do the work",
    "life gets better when you get better",
    "wisdom comes from listening and observing",
    "the sun will rise and so will you",
    "a goal is a dream with a deadline",
    "turn setbacks into setups for success",
    "be patient with yourself you are growing",
    "good things take time to build",
    "start your day with positive thoughts",
    "do small things with great love",
    "the right time is whenever you begin",
    "you become what you repeatedly do",
    "failure is simply practice for success",
    "stay strong the best is yet to come",
    "treat every challenge as a lesson",
    "keep your promises to yourself",
    "rise above the noise and stay focused",
    "a clear goal makes every step easier",
    "love what you do and do it well",
    "gentle words can open the hardest doors",
    "listen first then speak with care",
    "your mindset is your greatest asset",
    "keep pushing until you reach the top",
    "stay committed to your decisions",
    "build bridges instead of walls",
    "ordinary effort never creates extraordinary results",
    "you grow through what you go through",
    "carry hope in your pocket always",
    "embrace the journey and trust the timing",
    "the best way out is always through",
    "courage grows every time you use it",
    "aim high and work hard to get there",
    "a fresh start is always waiting for you",
    "be fearless in the pursuit of your goals",
    "never despise the power of small beginnings",
    "kindness is a language everyone understands",
    "make a plan then follow it through",
    "your life is shaped by your choices",
    "great ideas begin with simple curiosity",
    "what you think about you will become",
    "dreams do not work unless you do",
    "choose to shine even on cloudy days",
    "always do your best and let go",
    "difficult times build resilient people",
    "work smart stay patient and keep moving",
    "the smallest step is better than standing still",
    "refuse to let the past define you",
    "each challenge is a hidden blessing",
    "learn the rules then break them wisely",
    "choose courage over comfort today",
    "everything you want sits beyond your fear",
    "success loves those who keep showing up",
    "make room for joy in every day",
    "happy people build their own sunshine",
    "step outside and surprise yourself",
    "calm is a superpower worth practicing",
    "an hour of focus beats a day of distraction",
    "think positive and positive things happen",
    "the only way forward is to begin",
    "think less worry less and act more",
    "life begins where your fears end",
    "begin with what is right in front of you",
    "be proud of every small victory",
    "great stories start with brave choices",
    "seek progress and the rest will follow",
    "when you feel like quitting remember why you started",
    "the best is yet to be discovered",
    "keep shining and the world will notice",
  ];

  /// Returns the puzzle for a date, using UTC so the app and database agree.
  static String getPuzzleForDate(DateTime date) {
    final utc = date.toUtc();
    final day = DateTime.utc(utc.year, utc.month, utc.day);
    final dayNumber = day.difference(DateTime.utc(2026, 1, 1)).inDays;

    // Fixed seed -> the same shuffled order for everyone, every day.
    final shuffled = List<String>.from(_sentencePool)..shuffle(Random(42));
    final index = ((dayNumber % shuffled.length) + shuffled.length) % shuffled.length;
    return shuffled[index];
  }

  /// Returns today's UTC puzzle. Existing sessions retain their saved sentence.
  static List<String> getDailyPuzzles() => [getPuzzleForDate(DateTime.now().toUtc())];
}

// ═════════════════════════════════════════════════════════════════════════════
// UI
// ═════════════════════════════════════════════════════════════════════════════

class CryptogramApp extends StatelessWidget {
  const CryptogramApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();
    return MaterialApp(
      title: 'Daily Cryptogram',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.primary,
          error: AppColors.red,
        ),
        textTheme: base.textTheme.apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bg,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          hintStyle: AppText.sans(color: AppColors.muted, size: 13),
          labelStyle: AppText.sans(
              color: AppColors.muted,
              size: 10,
              weight: FontWeight.w600,
              letterSpacing: 1.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: AppText.sans(weight: FontWeight.w700, size: 14),
          ),
        ),
        dividerColor: AppColors.border,
      ),
      home: const LoginScreen(),
    );
  }
}

// ─── Color palette ────────────────────────────────────────────────────────────

class AppColors {
  static const bg = Color(0xFF0B0F17);
  static const surface = Color(0xFF131921);
  static const header = Color(0xFF0D1526);
  static const kbd = Color(0xFF0D1526);
  static const kbdKey = Color(0xFF162036);
  static const primary = Color(0xFF4A9EFF);
  static const amber = Color(0xFFF5A623);
  static const green = Color(0xFF2EA043);
  static const red = Color(0xFFF85149);
  static const text = Color(0xFFE6EDF3);
  static const sub = Color(0xFFCDD5E0);
  static const muted = Color(0xFF7A8799);
  static const border = Color(0xFF232D3F);
}

// ─── Text style helpers ───────────────────────────────────────────────────────

class AppText {
  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: 'monospace',
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double? letterSpacing,
    FontStyle style = FontStyle.normal,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        fontStyle: style,
      );
}

String formatTime(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String _todayLabel() {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  final now = DateTime.now().toUtc();
  return '${months[now.month - 1]} ${now.day}, ${now.year}';
}

const _kbdRows = [
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
];

String _friendlySupabaseError(Object error) {
  final message = error.toString().replaceFirst('Exception: ', '').trim();
  final lower = message.toLowerCase();

  if (message.isEmpty) {
    return 'Something went wrong. Please try again.';
  }

  if (lower.contains('failed to fetch') || lower.contains('network')) {
    return 'Could not connect to Supabase. Check your internet connection and Supabase URL/key.';
  }

  if (lower.contains('come back tomorrow')) {
    return "You've already played today's puzzle. Come back tomorrow for a new one!";
  }

  if (lower.contains('invalid email or password') ||
      lower.contains('invalid login') ||
      lower.contains('invalid password') ||
      lower.contains('wrong password')) {
    return 'Incorrect email or password.';
  }

  if (lower.contains('already exists') ||
      lower.contains('duplicate key') ||
      lower.contains('already registered')) {
    return 'An account with this email already exists.';
  }

  return message;
}

/// True when Supabase has rejected this account because it already used
/// today's puzzle.
bool _isDailyPlayBlocked(Object error) {
  return error.toString().toLowerCase().contains('come back tomorrow');
}

/// Atomically claims today's puzzle for this account.
///
/// The update only succeeds when last_active_date is NULL or is a date
/// before today. This means signing out and signing back in cannot be used
/// to play the daily cryptogram a second time.
Future<void> _claimDailyPuzzle(String userId) async {
  final id = int.tryParse(userId);

  if (id == null) {
    throw StateError('Supabase returned an invalid user id.');
  }

  final result = await supabase.rpc(
    'claim_daily_puzzle',
    params: {
      'p_user_id': id,
    },
  );

  if (result != true) {
    throw StateError(
      "You've already played today's puzzle. Come back tomorrow for a new one!",
    );
  }
}

// ─── LoginScreen ──────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _error = '';
  bool _loading = false;
  bool _obscure = true;

  StreamSubscription<AuthState>? _authSub;
  bool _completingGoogle = false;

  static final _emailRegex =
  RegExp(r'^[\w.+-]+@inspiritvision\.com$', caseSensitive: false);

  @override
  void initState() {
    super.initState();

    // Fires after signInWithIdToken (mobile) and after the OAuth redirect
    // returns to the page (web).
    _authSub = supabase.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn && state.session != null) {
        _completeGoogleLogin();
      }
    });

    // Already have a session (e.g. returning from the web redirect).
    if (supabase.auth.currentSession != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _completeGoogleLogin());
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ─── Email / password (custom RPC) login ────────────────────────────────────

  Future<void> _submit() async {
    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (fullName.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }

    if (fullName.split(RegExp(r'\s+')).length < 2) {
      setState(() => _error = 'Please enter both first and last name.');
      return;
    }

    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter your company email address.');
      return;
    }

    if (password.length < 4) {
      setState(() => _error = 'Password must be at least 4 characters.');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      dynamic result;

      // Try to log in with the given credentials first.
      Future<dynamic> tryLogin() => supabase.rpc(
        'authenticate_password_user',
        params: {
          'p_email': email,
          'p_password': password,
        },
      );

      try {
        result = await tryLogin();
      } catch (loginError) {
        // A daily-play block is a real application error, not a missing account.
        // Do NOT fall through to register_user in this case.
        if (_isDailyPlayBlocked(loginError)) {
          rethrow;
        }

        // No matching account yet (or a transient hiccup) — try creating one.
        try {
          result = await supabase.rpc(
            'create_password_user',
            params: {
              'p_full_name': fullName,
              'p_email': email,
              'p_password': password,
            },
          );
        } catch (registerError) {
          if (_isDailyPlayBlocked(registerError)) {
            rethrow;
          }

          final msg = registerError.toString().toLowerCase();
          final accountAlreadyExists = msg.contains('duplicate key') ||
              msg.contains('already exists') ||
              msg.contains('already registered');

          if (accountAlreadyExists) {
            // The account is real, so the first login attempt just didn't go
            // through. Retry login; a wrong password fails here correctly.
            result = await tryLogin();
          } else {
            rethrow;
          }
        }
      }

      final Map<String, dynamic> userData;

      if (result is Map) {
        userData = Map<String, dynamic>.from(result);
      } else if (result is List && result.isNotEmpty && result.first is Map) {
        userData = Map<String, dynamic>.from(result.first as Map);
      } else {
        throw StateError(
          'Supabase returned an unexpected response from login/register. '
              'Expected a user object or a one-row list.',
        );
      }

      // public.user_accounts.user_id (bigint); `id` kept as a fallback.
      final rawUserId = userData['user_id'] ?? userData['id'];
      if (rawUserId == null) {
        throw StateError('Supabase did not return a user id.');
      }

      final userId = rawUserId.toString();
      if (int.tryParse(userId) == null) {
        throw StateError(
          'Supabase returned a non-numeric user id. '
              'login_user/register_user must return user_accounts.user_id.',
        );
      }

      // Claim the daily puzzle before opening GameScreen.
      await _claimDailyPuzzle(userId);

      final storedFullName = (userData['full_name'] ?? fullName).toString();

      if (!mounted) return;

      final username = email.split('@').first;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            userId: userId,
            username: username,
            fullName: storedFullName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _friendlySupabaseError(e);
      });
    }
  }

  // ─── Google login ───────────────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      if (kIsWeb) {
        // Redirects to Google and back; _completeGoogleLogin runs on return.
        await supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          queryParams: {'hd': allowedEmailDomain},
        );
        return;
      }

      final account = await _googleSignIn!.signIn();
      if (account == null) {
        // User closed the Google dialog without choosing an account.
        if (mounted) setState(() => _loading = false);
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw StateError('Google did not return an ID token.');
      }

      // Triggers onAuthStateChange -> _completeGoogleLogin.
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: auth.accessToken,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlySupabaseError(e);
      });
    }
  }

  /// Runs once a Supabase Auth session exists: maps the Google user onto the
  /// app's user_accounts row, claims today's puzzle, then opens the game.
  Future<void> _completeGoogleLogin() async {
    if (_completingGoogle) return;
    _completingGoogle = true;
    if (mounted) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw StateError('Google sign-in did not complete.');
      }
      final email = (user.email ?? '').toLowerCase();
      if (!email.endsWith('@$allowedEmailDomain')) {
        throw Exception('Only @$allowedEmailDomain accounts can sign in with Google.');
      }

      final meta = user.userMetadata ?? {};
      final googleName = (meta['full_name'] ?? meta['name'] ?? '').toString();

      final result = await supabase.rpc(
        'resolve_google_user',
        params: {'p_full_name': googleName},
      );

      final dynamic row =
      (result is List && result.isNotEmpty) ? result.first : result;
      if (row is! Map) {
        throw StateError('Unexpected response from resolve_google_user.');
      }

      final userId = (row['user_id'] ?? row['id']).toString();
      if (int.tryParse(userId) == null) {
        throw StateError(
            'resolve_google_user must return user_accounts.user_id.');
      }

      // Same once-a-day limit as the password login.
      await _claimDailyPuzzle(userId);

      if (!mounted) return;

      final fullName = (row['full_name'] ?? googleName).toString();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            userId: userId,
            username: (user.email ?? 'player').split('@').first,
            fullName: fullName.isEmpty ? 'Player' : fullName,
          ),
        ),
      );
    } catch (e) {
      await signOutEverywhere();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlySupabaseError(e);
      });
    } finally {
      // Always clear the one-time in-flight guard so a later auth state event,
      // or a sign-out/sign-in cycle, can retry cleanly.
      _completingGoogle = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.06),
                    Colors.transparent
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      _buildBrand(),
                      const SizedBox(height: 32),
                      _buildCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF162036), Color(0xFF0D1526)],
            ),
            border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 40)
            ],
          ),
          child: const Icon(Icons.grid_view_rounded,
              color: AppColors.primary, size: 26),
        ),
        const SizedBox(height: 14),
        Text(
          'CRYPTOGRAMS',
          style: AppText.mono(
              size: 20,
              weight: FontWeight.w700,
              letterSpacing: 4,
              color: AppColors.text),
        ),
        const SizedBox(height: 5),
        Text(
          ' ${_todayLabel()}',
          style: AppText.sans(size: 11, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 60,
              offset: const Offset(0, 24))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LabeledField(
            label: 'FULL NAME',
            controller: _fullNameCtrl,
            placeholder: 'Enter your full name',
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: 'EMAIL',
            controller: _emailCtrl,
            placeholder: 'Enter your company email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: 'PASSWORD',
            controller: _passwordCtrl,
            placeholder: 'Enter your password',
            obscure: _obscure,
            keyboardType: TextInputType.visiblePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.muted,
                size: 18,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
                border:
                Border.all(color: AppColors.red.withValues(alpha: 0.22)),
              ),
              child: Text(_error,
                  style: AppText.sans(size: 12, color: AppColors.red)),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2))
                : ElevatedButton(
              onPressed: _submit,
              child: const Text("Today's Puzzle →"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _loading ? null : _handleGoogleSignIn,
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Sign in with Google'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.text,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Labeled text field ───────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool obscure;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.obscure = false,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.sans(
              size: 10,
              weight: FontWeight.w600,
              color: AppColors.muted,
              letterSpacing: 1.0),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          textCapitalization: textCapitalization,
          keyboardType: keyboardType,
          style: AppText.sans(size: 13, color: AppColors.text),
          decoration: InputDecoration(
            hintText: placeholder,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ─── Dot-grid background painter ─────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}

// ─── GameScreen ───────────────────────────────────────────────────────────────

class GameScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String fullName;
  const GameScreen(
      {super.key,
        required this.userId,
        required this.username,
        required this.fullName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<String> dailySentences;
  int _puzzleIndex = 0;
  bool get _isLastPuzzle => _puzzleIndex == dailySentences.length - 1;

  late CryptogramEngine _engine;
  // Cipher letter (UPPER) -> plain letter (UPPER).
  late Map<String, String> _decodeMap;

  final Map<String, String> _userMap = {};
  String? _selectedCipher;
  final Set<String> _hintedLetters = {};
  int _hintsLeft = 3;
  bool _solved = false;
  bool _currentPuzzleSkipped = false;

  int _timeElapsed = 0;
  int _puzzleTimeElapsed = 0;

  int? _currentStreak;
  Timer? _timer;
  bool _sessionComplete = false;
  bool _initializing = true;
  bool _finishing = false;
  String? _sessionLoadError;
  String _completionReason = 'solved';

  int? _sessionId;
  DateTime? _sessionStartedAt;
  Future<void> _saveQueue = Future<void>.value();
  bool _restoringState = false;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  final List<int> _hintsUsedPerPuzzle = [];
  final List<int> _puzzleTimes = [];
  final List<bool> _puzzleWasSkipped = [];

  bool get _inputLocked =>
      _solved || _sessionComplete || _finishing || _initializing;

  @override
  void initState() {
    super.initState();
    dailySentences = MockSentenceService.getDailyPuzzles().take(1).toList();
    _loadPuzzle(0);
    unawaited(_initializeSession());
    unawaited(_fetchStreak());
  }

  int _elapsedSinceStart() {
    final startedAt = _sessionStartedAt;
    if (startedAt == null) return _timeElapsed;
    final seconds = DateTime.now().toUtc().difference(startedAt.toUtc()).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  void _refreshElapsedTime() {
    _timeElapsed = _elapsedSinceStart();
    // The current implementation runs one daily puzzle per session.
    _puzzleTimeElapsed = _timeElapsed;
  }

  Future<void> _initializeSession() async {
    try {
      final userId = int.tryParse(widget.userId);
      if (userId == null) {
        throw StateError('Supabase returned an invalid user id.');
      }

      // claim_daily_puzzle creates this row on first entry and returns true for
      // an already-open row, including one opened on a previous day.
      final dynamic found = await supabase.rpc(
        'get_active_game_session',
        params: {'p_user_id': userId},
      );

      if (found == null) {
        throw StateError(
          'No active session was found. Run the session_lifecycle.sql script in Supabase, then sign in again.',
        );
      }

      final row = Map<String, dynamic>.from(found as Map);
      _sessionId = int.tryParse(row['id'].toString());
      if (_sessionId == null) {
        throw StateError('Supabase returned an invalid session id.');
      }
      _sessionStartedAt = DateTime.parse(row['started_at'].toString()).toUtc();

      final rawState = row['puzzle_state'];
      final state = rawState is Map
          ? Map<String, dynamic>.from(rawState)
          : <String, dynamic>{};

      final sessionDate = DateTime.tryParse(
        (row['game_id'] ?? '').toString().replaceFirst('daily-', ''),
      ) ??
          _sessionStartedAt!;
      final savedSentence = state['sentence']?.toString();
      dailySentences = [
        (savedSentence != null && savedSentence.trim().isNotEmpty)
            ? savedSentence
            : MockSentenceService.getPuzzleForDate(sessionDate),
      ];
      _puzzleIndex = 0;

      _restorePuzzleState(state);
      _refreshElapsedTime();

      // New sessions have an empty puzzle_state. Save the generated cipher
      // immediately so the exact same puzzle can be restored after refresh.
      final cipherState = state['cipher_map'];
      if (cipherState is! Map || cipherState.isEmpty) {
        await _savePuzzleState();
      }
    } catch (e) {
      debugPrint('Session initialization failed: $e');
      _sessionLoadError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _initializing = false);
    }

    if (mounted && _sessionLoadError == null) {
      _startTimer();
      // If the saved guesses already solve the puzzle but the previous finish
      // request failed, retry the normal solve/close flow on resume.
      _checkSolved();
    }
  }

  void _restorePuzzleState(Map<String, dynamic> state) {
    _restoringState = true;
    try {
      final rawCipherMap = state['cipher_map'];
      final savedCipherMap = rawCipherMap is Map
          ? rawCipherMap.map((key, value) => MapEntry(
          key.toString().toLowerCase(), value.toString().toLowerCase()))
          : <String, String>{};

      if (savedCipherMap.isNotEmpty) {
        _engine = CryptogramEngine.restore(
          dailySentences[_puzzleIndex],
          savedCipherMap,
        );
      } else {
        _loadPuzzle(_puzzleIndex);
      }

      _decodeMap = {
        for (final entry in _engine.cipherMap.entries)
          entry.value.toUpperCase(): entry.key.toUpperCase(),
      };

      _userMap
        ..clear()
        ..addAll(_stringMap(state['user_map']));
      _hintedLetters
        ..clear()
        ..addAll(_stringList(state['hinted_letters']));
      _hintsLeft = ((state['hints_left'] as num?)?.toInt() ?? 3).clamp(0, 3).toInt();
      _selectedCipher = state['selected_cipher']?.toString();
      _solved = state['solved'] == true;
      _currentPuzzleSkipped = state['current_puzzle_skipped'] == true;

      _hintsUsedPerPuzzle
        ..clear()
        ..addAll(_intList(state['hints_used_per_puzzle']));
      _puzzleTimes
        ..clear()
        ..addAll(_intList(state['puzzle_times']));
      _puzzleWasSkipped
        ..clear()
        ..addAll(_boolList(state['puzzle_was_skipped']));

      _puzzleTimeElapsed = (state['puzzle_time_elapsed'] as num?)?.toInt() ?? 0;
    } finally {
      _restoringState = false;
    }
  }

  Map<String, String> _stringMap(dynamic value) {
    if (value is! Map) return <String, String>{};
    return value.map((key, item) => MapEntry(
        key.toString().toUpperCase(), item.toString().toUpperCase()));
  }

  List<String> _stringList(dynamic value) => value is List
      ? value.map((item) => item.toString().toUpperCase()).toList()
      : <String>[];

  List<int> _intList(dynamic value) => value is List
      ? value.whereType<num>().map((item) => item.toInt()).toList()
      : <int>[];

  List<bool> _boolList(dynamic value) => value is List
      ? value.map((item) => item == true).toList()
      : <bool>[];

  Map<String, dynamic> _buildPuzzleState({String? completionReason}) {
    return <String, dynamic>{
      'version': 1,
      'sentence': dailySentences[_puzzleIndex],
      'puzzle_index': _puzzleIndex,
      'cipher_map': _engine.cipherMap,
      'user_map': _userMap,
      'hinted_letters': _hintedLetters.toList(),
      'hints_left': _hintsLeft,
      'selected_cipher': _selectedCipher,
      'solved': _solved,
      'current_puzzle_skipped': _currentPuzzleSkipped,
      'puzzle_time_elapsed': _puzzleTimeElapsed,
      'hints_used_per_puzzle': _hintsUsedPerPuzzle,
      'puzzle_times': _puzzleTimes,
      'puzzle_was_skipped': _puzzleWasSkipped,
      if (completionReason != null) 'completionReason': completionReason,
    };
  }

  Future<void> _savePuzzleState() {
    final sessionId = _sessionId;
    final userId = int.tryParse(widget.userId);
    if (sessionId == null || userId == null || _sessionComplete || _finishing) {
      return Future<void>.value();
    }
    if (_restoringState) return Future<void>.value();

    final stateSnapshot = _buildPuzzleState();
    final totalHints = _hintsUsedPerPuzzle.fold<int>(0, (sum, value) => sum + value);
    final totalSkipped = _puzzleWasSkipped.where((skipped) => skipped).length;

    final pending = _saveQueue.catchError((Object _) {}).then((_) async {
      final result = await supabase.rpc(
        'save_game_session_progress',
        params: {
          'p_session_id': sessionId,
          'p_user_id': userId,
          'p_puzzle_state': stateSnapshot,
          'p_hints_used': totalHints,
          'p_puzzles_skipped': totalSkipped,
        },
      );
      if (result != true) {
        throw StateError('The active session could not be saved.');
      }
    });
    _saveQueue = pending;
    return pending;
  }

  void _queuePuzzleSave() {
    if (_restoringState || _initializing || _sessionComplete || _finishing) return;
    unawaited(_savePuzzleState().catchError((Object error) {
      debugPrint('Session autosave error: $error');
    }));
  }

  /// Loads the current streak for this user from user_accounts.
  Future<void> _fetchStreak() async {
    final id = int.tryParse(widget.userId);
    if (id == null) return;

    try {
      final row = await supabase
          .from('user_accounts')
          .select('streak')
          .eq('user_id', id)
          .maybeSingle();

      if (!mounted || row == null) return;
      setState(() => _currentStreak = row['streak'] as int? ?? 0);
    } catch (e) {
      debugPrint('Streak fetch error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _loadPuzzle(int index) {
    _engine = CryptogramEngine(dailySentences[index]);
    _decodeMap = {
      for (final e in _engine.cipherMap.entries)
        e.value.toUpperCase(): e.key.toUpperCase(),
    };
    _userMap.clear();
    _selectedCipher = null;
    _hintedLetters.clear();
    _hintsLeft = 3;
    _solved = false;
    _currentPuzzleSkipped = false;
    _puzzleTimeElapsed = 0;
  }

  List<String> get _cipherLetters {
    final seen = <String>{};
    return _engine.encryptedText
        .toUpperCase()
        .split('')
        .where((c) => RegExp(r'[A-Z]').hasMatch(c) && seen.add(c))
        .toList();
  }

  // ─── Timer ────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _initializing || _sessionComplete || _finishing) return;
      setState(_refreshElapsedTime);
    });
  }

  // ─── Letter assignment ────────────────────────────────────────────────────

  void _assignLetter(String plain) {
    if (_solved || _sessionComplete || _finishing || _initializing) return;
    if (_selectedCipher == null) {
      _showToast('Select a letter first');
      return;
    }

    setState(() {
      _userMap.removeWhere((k, v) => v == plain && k != _selectedCipher);
      _userMap[_selectedCipher!] = plain;
    });

    _checkSolved();
    _advanceSelection();
    _queuePuzzleSave();
  }

  void _clearSelected() {
    if (_selectedCipher == null || _inputLocked) return;
    setState(() {
      _userMap.remove(_selectedCipher);
    });
    _queuePuzzleSave();
  }

  void _checkSolved() {
    if (_sessionComplete || _finishing || _initializing) return;
    if (_solved) {
      if (_isLastPuzzle) {
        unawaited(_submitSessionResults(completionReason: 'solved'));
      }
      return;
    }

    final lowerGuesses = <String, String>{
      for (final entry in _userMap.entries)
        entry.key.toLowerCase(): entry.value.toLowerCase(),
    };
    if (!_engine.isSolved(lowerGuesses)) return;

    _currentPuzzleSkipped = false;
    _recordPuzzleResult(skipped: false);
    if (!mounted) return;

    setState(() => _solved = true);
    if (_isLastPuzzle) {
      unawaited(_submitSessionResults(completionReason: 'solved'));
    } else {
      _queuePuzzleSave();
    }
  }

  void _advanceSelection() {
    if (_solved || _sessionComplete || _finishing) return;
    final current = _selectedCipher;
    if (current == null) return;

    final inOrder = <String>[];
    for (final ch in _engine.encryptedText.toUpperCase().split('')) {
      if (RegExp(r'[A-Z]').hasMatch(ch) && !inOrder.contains(ch)) {
        inOrder.add(ch);
      }
    }
    final ci = inOrder.indexOf(current);
    final nxt = inOrder
        .skip(ci + 1)
        .firstWhere((l) => !_userMap.containsKey(l), orElse: () => '');
    if (nxt.isNotEmpty) setState(() => _selectedCipher = nxt);
  }

  /// Stores this puzzle's stats exactly once.
  void _recordPuzzleResult({required bool skipped}) {
    if (_puzzleTimes.length > _puzzleIndex) return;

    setState(() {
      _puzzleTimes.add(_puzzleTimeElapsed);
      _hintsUsedPerPuzzle.add(3 - _hintsLeft);
      _puzzleWasSkipped.add(skipped);
    });
  }

  /// Closes the existing session. Solving the puzzle closes it automatically;
  /// pressing Submit closes it even when the user has not solved it.
  Future<void> _submitSessionResults({String? completionReason}) async {
    if (_sessionComplete || _finishing || _sessionId == null) return;

    final reason = completionReason ?? (_solved ? 'solved' : 'submitted');
    _refreshElapsedTime();
    if (_puzzleTimes.length <= _puzzleIndex) {
      _recordPuzzleResult(skipped: !_solved);
    }

    if (mounted) setState(() => _finishing = true);

    try {
      // Wait for any earlier autosaves before writing the final state.
      await _saveQueue.catchError((Object error) {
        debugPrint('A previous autosave failed before session closure: $error');
      });

      _refreshElapsedTime();
      final totalHints = _hintsUsedPerPuzzle.fold<int>(0, (sum, h) => sum + h);
      final totalSkipped = _puzzleWasSkipped.where((skipped) => skipped).length;
      final state = _buildPuzzleState(completionReason: reason);
      final userIdInt = int.tryParse(widget.userId);
      if (userIdInt == null) throw StateError('Invalid user id.');

      final result = await supabase.rpc(
        'finish_game_session',
        params: {
          'p_session_id': _sessionId,
          'p_user_id': userIdInt,
          'p_completion_reason': reason,
          'p_puzzle_state': state,
          'p_hints_used': totalHints,
          'p_puzzles_skipped': totalSkipped,
        },
      );
      if (result != true) {
        throw StateError('This session is no longer active. Refresh and sign in again.');
      }

      _timer?.cancel();
      if (!mounted) return;
      setState(() {
        _timeElapsed = _elapsedSinceStart();
        _puzzleTimeElapsed = _timeElapsed;
        _sessionComplete = true;
        _completionReason = reason;
        _finishing = false;
      });
      await _fetchStreak();
      _showToast(reason == 'solved'
          ? 'Puzzle solved — session closed.'
          : 'Session submitted and closed.');
    } catch (e) {
      debugPrint('Session closure failed: $e');
      if (mounted) {
        setState(() => _finishing = false);
        _showToast('Could not close session: $e');
      }
    }
  }

  // ─── Advance to next puzzle ───────────────────────────────────────────────

  void _nextPuzzle() {
    if (!_solved || _isLastPuzzle || _finishing || _sessionComplete) return;
    setState(() {
      _puzzleIndex++;
      _loadPuzzle(_puzzleIndex);
    });
    _queuePuzzleSave();
  }

  // ─── Skip ─────────────────────────────────────────────────────────────────
  void _confirmSkip() {
    if (_solved || _sessionComplete || _finishing) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 34, color: AppColors.amber),
              const SizedBox(height: 12),
              Text('Skip this puzzle?',
                  style: AppText.mono(
                      size: 16,
                      weight: FontWeight.w700,
                      color: AppColors.text)),
              const SizedBox(height: 8),
              Text(
                "You won't get credit for solving it, and this can't be undone.",
                textAlign: TextAlign.center,
                style: AppText.sans(size: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.sub,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Cancel',
                          style: AppText.sans(
                              size: 13,
                              weight: FontWeight.w600,
                              color: AppColors.sub)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _skipPuzzle();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Skip Puzzle',
                          style: AppText.sans(
                              size: 13,
                              weight: FontWeight.w700,
                              color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _skipPuzzle() {
    if (_solved || _sessionComplete || _finishing) return;

    if (_isLastPuzzle) {
      // With one daily puzzle there is nowhere else to advance to. Mark the
      // intent to skip, but keep the session active and the clock running.
      setState(() => _currentPuzzleSkipped = true);
      _queuePuzzleSave();
      _showToast('Puzzle skipped. Submit to close the session, or keep solving.');
      return;
    }

    _recordPuzzleResult(skipped: true);
    setState(() {
      _puzzleIndex++;
      _loadPuzzle(_puzzleIndex);
    });
    _queuePuzzleSave();
    _showToast('Puzzle skipped');
  }

  // ─── Hint ─────────────────────────────────────────────────────────────────

  void _useHint() {
    if (_solved || _sessionComplete || _finishing) return;
    if (_hintsLeft <= 0) {
      _showToast('No hints remaining');
      return;
    }

    final unguessed = _cipherLetters
        .where((cl) => _userMap[cl] != _decodeMap[cl])
        .toList()
      ..shuffle();

    if (unguessed.isEmpty) {
      _showToast('All correct!');
      return;
    }

    final pick = unguessed.first;
    final correct = _decodeMap[pick]!;

    setState(() {
      _userMap.removeWhere((k, v) => v == correct);
      _userMap[pick] = correct;
      _hintedLetters.add(pick);
      _hintsLeft--;
      _selectedCipher = pick;
    });

    _showToast('Hint: $pick = $correct');
    _checkSolved();
    _queuePuzzleSave();
  }

  // ─── Toast ────────────────────────────────────────────────────────────────

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: AppText.sans(size: 18, color: AppColors.sub),
          textAlign: TextAlign.center),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      duration: const Duration(milliseconds: 2400),
      elevation: 6,
    ));
  }

  Future<void> _signOut() async {
    await signOutEverywhere();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _seeLeaderboard() => Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_sessionLoadError != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    'Could not restore your session',
                    style: AppText.sans(size: 18, weight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sessionLoadError!,
                    style: AppText.sans(size: 12, color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Return to sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        final label = event.logicalKey.keyLabel;
        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          _clearSelected();
        } else if (label.length == 1 && RegExp(r'[a-zA-Z]').hasMatch(label)) {
          _assignLetter(label.toUpperCase());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                _buildProgressBars(),
                Expanded(child: _buildPuzzleArea()),
                _buildControlRow(),
                _buildKeyboard(),
              ],
            ),
            if (_solved && !_isLastPuzzle && !_sessionComplete)
              Positioned.fill(child: _buildPuzzleSolvedOverlay()),
            if (_sessionComplete)
              Positioned.fill(
                child: _buildAllSolvedOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.header,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              _TimerBadge(timeElapsed: _puzzleTimeElapsed),
              Expanded(
                child: Text(
                  'DAILY CRYPTOGRAM',
                  textAlign: TextAlign.center,
                  style: AppText.mono(
                      size: 13,
                      weight: FontWeight.w700,
                      letterSpacing: 3,
                      color: AppColors.text),
                ),
              ),
              if (_currentStreak != null) ...[
                _StreakBadge(streak: _currentStreak!),
                const SizedBox(width: 8),
              ],
              _MenuButton(
                fullName: widget.fullName,
                username: widget.username,
                onHowTo: () => _showToast(
                    'Tap a cipher letter, then type or tap your guess.'),
                onSignOut: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Progress bars ────────────────────────────────────────────────────────

  Widget _buildProgressBars() {
    final letters = _cipherLetters;
    final solvedCount =
        letters.where((cl) => _userMap[cl] == _decodeMap[cl]).length;
    final letterProg = letters.isEmpty ? 0.0 : solvedCount / letters.length;

    return Column(
      children: [
        Container(
          color: AppColors.header,
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dailySentences.length, (i) {
              final done = i < _puzzleWasSkipped.length ||
                  (i == _puzzleIndex && (_solved || _sessionComplete));
              final skipped =
                  i < _puzzleWasSkipped.length && _puzzleWasSkipped[i];
              final current = i == _puzzleIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: current ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: done
                      ? (skipped ? AppColors.amber : AppColors.green)
                      : current
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: done
                    ? Icon(
                    skipped
                        ? Icons.skip_next_rounded
                        : Icons.check_rounded,
                    size: 8,
                    color: Colors.white)
                    : null,
              );
            }),
          ),
        ),
        LinearProgressIndicator(
          value: letterProg,
          backgroundColor: AppColors.surface,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 2,
        ),
      ],
    );
  }

  // ─── Puzzle area ──────────────────────────────────────────────────────────

  Widget _buildPuzzleArea() {
    final letters = _cipherLetters;
    final solvedCount =
        letters.where((cl) => _userMap[cl] == _decodeMap[cl]).length;

    return Stack(
      children: [
        Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          'Puzzle ${_puzzleIndex + 1} of ${dailySentences.length}',
                          style: AppText.sans(
                              size: 11,
                              weight: FontWeight.w600,
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Cipher words
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: _engine.encryptedText
                          .toUpperCase()
                          .split(' ')
                          .map(_buildWord)
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 22),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _dotStat('$solvedCount/${letters.length} solved',
                          AppColors.primary),
                      _divider(),
                      _hintStat(),
                      _divider(),
                      _dotStat('Total ${formatTime(_timeElapsed)}',
                          AppColors.muted),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWord(String word) => Row(
    mainAxisSize: MainAxisSize.min,
    children: word.split('').map(_buildCell).toList(),
  );

  Widget _buildCell(String ch) {
    if (!RegExp(r'[A-Z]').hasMatch(ch)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(ch, style: AppText.mono(size: 20, color: AppColors.muted)),
      );
    }

    final isSelected = ch == _selectedCipher;
    final guess = _userMap[ch] ?? '';
    final isHinted = _hintedLetters.contains(ch);

    Color borderColor = AppColors.border;
    Color guessColor = AppColors.text;
    Color cellBg = Colors.transparent;
    Color cipherColor = Colors.white;

    if (isSelected) {
      borderColor = AppColors.primary;
      cellBg = AppColors.primary.withValues(alpha: 0.09);
      cipherColor = AppColors.primary;
    }

    if (isHinted && !isSelected) cipherColor = AppColors.amber;

    return GestureDetector(
      onTap: _inputLocked
          ? null
          : () {
        setState(() => _selectedCipher = ch);
        _queuePuzzleSave();
      },
      child: AbsorbPointer(
        absorbing: _inputLocked,
        child: SizedBox(
          width: 30,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(ch,
                style: AppText.mono(
                    size: 10,
                    color: cipherColor,
                    weight: isHinted ? FontWeight.w700 : FontWeight.w400)),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28,
              height: 32,
              decoration: BoxDecoration(
                  color: cellBg,
                  border:
                  Border(bottom: BorderSide(color: borderColor, width: 2))),
              alignment: Alignment.center,
              child: Text(guess,
                  style: AppText.mono(
                      size: 17, weight: FontWeight.w600, color: guessColor)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _dotStat(String label, Color dot) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: AppText.sans(size: 12, color: AppColors.muted)),
    ]),
  );

  Widget _hintStat() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.lightbulb_outline_rounded,
          size: 12,
          color: _hintsLeft > 0 ? AppColors.amber : AppColors.muted),
      const SizedBox(width: 4),
      Text('$_hintsLeft hint${_hintsLeft != 1 ? 's' : ''} left',
          style: AppText.sans(
              size: 12,
              color: _hintsLeft > 0 ? AppColors.amber : AppColors.muted)),
    ]),
  );

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Text('·', style: AppText.sans(size: 12, color: AppColors.border)),
  );

  // ─── Puzzle solved overlay (intermediate) ─────────────────────────────────

  Widget _buildPuzzleSolvedOverlay() {
    final myTime = _puzzleTimes.length > _puzzleIndex
        ? _puzzleTimes[_puzzleIndex]
        : _puzzleTimeElapsed;
    final hintsUsed = _hintsUsedPerPuzzle.length > _puzzleIndex
        ? _hintsUsedPerPuzzle[_puzzleIndex]
        : (3 - _hintsLeft);
    return Container(
      color: AppColors.bg.withValues(alpha: 0.88),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5), blurRadius: 60)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✓',
                  style: TextStyle(fontSize: 40, color: AppColors.green)),
              const SizedBox(height: 10),
              Text(
                'Puzzle ${_puzzleIndex + 1} Complete!',
                style: AppText.mono(
                    size: 18, weight: FontWeight.w700, color: AppColors.green),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _miniStat(formatTime(myTime), 'Puzzle Time', AppColors.amber),
                  const SizedBox(width: 24),
                  _miniStat(
                    hintsUsed == 0 ? 'None 🌟' : '$hintsUsed',
                    'Hints',
                    hintsUsed == 0 ? AppColors.green : AppColors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Puzzle ${_puzzleIndex + 2} unlocked',
                        style: AppText.sans(
                            size: 13,
                            weight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPuzzle,
                  child: Text('Next Puzzle →',
                      style: AppText.sans(
                          size: 14,
                          weight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── All solved overlay (final) ───────────────────────────────────────────

  Widget _buildAllSolvedOverlay() {
    final totalHints = _hintsUsedPerPuzzle.fold<int>(0, (a, b) => a + b);
    final firstName = widget.fullName.split(' ').first;
    return Container(
      color: AppColors.bg.withValues(alpha: 0.9),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            constraints: const BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6), blurRadius: 80)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_completionReason == 'solved' ? '🎉' : '🏁',
                    style: const TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text(_completionReason == 'solved'
                    ? 'Puzzle Solved, $firstName!'
                    : 'Session Submitted, $firstName!',
                    style: AppText.mono(
                        size: 19,
                        weight: FontWeight.w700,
                        color: AppColors.green)),
                const SizedBox(height: 4),
                Text(
                  _completionReason == 'solved'
                      ? 'Your puzzle is complete.'
                      : 'Your session has been submitted and closed.',
                  textAlign: TextAlign.center,
                  style: AppText.sans(size: 12, color: AppColors.muted),
                ),
                if (_currentStreak != null) ...[
                  const SizedBox(height: 12),
                  _StreakBadge(streak: _currentStreak!, large: true),
                ],
                const SizedBox(height: 20),
                Text(formatTime(_timeElapsed),
                    style: AppText.mono(
                        size: 36,
                        weight: FontWeight.w700,
                        color: AppColors.amber)),
                Text('total time',
                    style: AppText.sans(size: 11, color: AppColors.muted)),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: List.generate(dailySentences.length, (i) {
                      final time = i < _puzzleTimes.length ? _puzzleTimes[i] : 0;
                      final hints = i < _hintsUsedPerPuzzle.length
                          ? _hintsUsedPerPuzzle[i]
                          : 0;
                      final skipped =
                          i < _puzzleWasSkipped.length && _puzzleWasSkipped[i];
                      final isLast = i == dailySentences.length - 1;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : const Border(
                              bottom: BorderSide(color: AppColors.border)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color:
                                (skipped ? AppColors.amber : AppColors.green)
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                  skipped
                                      ? Icons.skip_next_rounded
                                      : Icons.check_rounded,
                                  size: 13,
                                  color: skipped
                                      ? AppColors.amber
                                      : AppColors.green),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Puzzle ${i + 1} · ${formatTime(time)}${skipped ? ' · skipped' : ''}',
                                style: AppText.sans(
                                    size: 12, color: AppColors.sub),
                              ),
                            ),
                            Text(
                              hints == 0
                                  ? 'No hints 🌟'
                                  : '$hints hint${hints > 1 ? 's' : ''}',
                              style: AppText.sans(
                                  size: 11,
                                  color: hints == 0
                                      ? AppColors.green
                                      : AppColors.muted),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 6),
                Text('$totalHints hint${totalHints != 1 ? 's' : ''} used total',
                    style: AppText.sans(size: 11, color: AppColors.muted)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _seeLeaderboard,
                    child: Text('See Leaderboard',
                        style: AppText.sans(
                            size: 13,
                            weight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _signOut,
                    child: Text('Sign Out',
                        style: AppText.sans(
                            size: 13,
                            weight: FontWeight.w600,
                            color: AppColors.red)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) =>
      Column(children: [
        Text(value,
            style: AppText.sans(size: 15, weight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: AppText.sans(
                size: 10, color: AppColors.muted, letterSpacing: 0.8)),
      ]);

  // ─── Control row ──────────────────────────────────────────────────────────

  Widget _buildControlRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PillButton(
            label: 'Hint ($_hintsLeft)',
            icon: Icons.lightbulb_outline_rounded,
            color: AppColors.amber,
            disabled: _hintsLeft <= 0 || _inputLocked,
            onTap: _useHint,
          ),
          const SizedBox(width: 8),
          _PillButton(
            label: 'Skip',
            icon: Icons.skip_next_rounded,
            color: AppColors.muted,
            disabled: _inputLocked,
            onTap: _confirmSkip,
          ),
          const SizedBox(width: 8),
          _PillButton(
            label: _finishing ? 'Submitting' : 'Submit',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.green,
            disabled: _finishing || _sessionComplete || _initializing,
            onTap: () => _submitSessionResults(),
          ),
        ],
      ),
    );
  }

  // ─── Keyboard ─────────────────────────────────────────────────────────────

  Widget _buildKeyboard() {
    return Container(
      color: AppColors.kbd,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ..._kbdRows.map(_buildKbdRow),
            const SizedBox(height: 6),
            _buildClearButton(),
          ]),
        ),
      ),
    );
  }

  Widget _buildKbdRow(List<String> keys) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys.map(_buildKey).toList()),
  );

  Widget _buildKey(String key) {
    final blocked = _inputLocked;
    Color bg = AppColors.kbdKey,
        fg = AppColors.text,
        border = Colors.white.withValues(alpha: 0.05);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: blocked ? null : () => _assignLetter(key),
          child: Container(
            width: 33,
            height: 42,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: border)),
            alignment: Alignment.center,
            child: Text(key,
                style: AppText.mono(
                    size: 13,
                    weight: FontWeight.w600,
                    color: blocked ? fg.withValues(alpha: 0.28) : fg)),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    final blocked = _inputLocked;
    return Material(
      color: AppColors.kbdKey,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: blocked ? null : _clearSelected,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.backspace_outlined,
                size: 15,
                color: blocked
                    ? AppColors.muted.withValues(alpha: 0.28)
                    : AppColors.muted),
            const SizedBox(width: 6),
            Text('Clear',
                style: AppText.mono(
                    size: 13,
                    color: blocked
                        ? AppColors.muted.withValues(alpha: 0.28)
                        : AppColors.muted)),
          ]),
        ),
      ),
    );
  }
}

// ─── LeaderboardScreen ────────────────────────────────────────────────────────

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _signOut() async {
    await signOutEverywhere();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final data = await supabase
          .from('calculated_leaderboard')
          .select(
          'full_name, time_taken, hints_used, puzzles_skipped, points, streak, rank')
          .order('rank', ascending: true)
          .limit(50);

      if (!mounted) return;
      setState(() {
        _entries = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  TextStyle _headStyle() => AppText.sans(
      size: 12,
      weight: FontWeight.w700,
      color: AppColors.muted,
      letterSpacing: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: AppColors.header,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.muted),
                    onPressed: _signOut,
                  ),
                  Expanded(
                    child: Text(
                      'LEADERBOARD',
                      textAlign: TextAlign.center,
                      style: AppText.mono(
                          size: 15,
                          weight: FontWeight.w700,
                          letterSpacing: 3,
                          color: AppColors.text),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (!_loading && _error == null && _entries.isNotEmpty)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: AppColors.header,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 28),
                    Expanded(
                        flex: 2, child: Text('NAME', style: _headStyle())),
                    Expanded(
                      flex: 2,
                      child: Text('TIME',
                          textAlign: TextAlign.center, style: _headStyle()),
                    ),
                    Expanded(
                      child: Text('HINTS',
                          textAlign: TextAlign.center, style: _headStyle()),
                    ),
                    Expanded(
                      child: Text('STREAK',
                          textAlign: TextAlign.center, style: _headStyle()),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text('POINTS',
                          textAlign: TextAlign.right, style: _headStyle()),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                  ? Center(
                child: Text('Could not load leaderboard: $_error',
                    style:
                    AppText.sans(size: 12, color: AppColors.red)),
              )
                  : _entries.isEmpty
                  ? Center(
                child: Text('No results yet — be the first!',
                    style: AppText.sans(
                        size: 13, color: AppColors.muted)),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _entries.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final entry = _entries[i];
                  final rank = entry['rank'] ?? (i + 1);
                  final skippedCount =
                      (entry['puzzles_skipped'] as int?) ?? 0;
                  final skipped = skippedCount > 0;

                  final Color rankColor;
                  if (rank == 1) {
                    rankColor = AppColors.amber;
                  } else if (rank == 2) {
                    rankColor = const Color(0xFFD6D6D6);
                  } else if (rank == 3) {
                    rankColor = const Color(0xFFCD7F32);
                  } else {
                    rankColor = Colors.white;
                  }
                  final rowColor = skipped
                      ? const Color(0xFFC97A7A)
                      : rankColor;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text('#$rank',
                              style: AppText.mono(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: skipped
                                      ? AppColors.red
                                      : rankColor)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                    entry['full_name'] ??
                                        'Anonymous',
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: AppText.sans(
                                        size: 14,
                                        color: rowColor)),
                              ),
                              if (skipped) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                    Icons.skip_next_rounded,
                                    size: 13,
                                    color: AppColors.red),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              formatTime(entry['time_taken'] ?? 0),
                              textAlign: TextAlign.center,
                              style: AppText.mono(
                                  size: 14, color: rowColor)),
                        ),
                        Expanded(
                          child: Text('${entry['hints_used'] ?? 0}',
                              textAlign: TextAlign.center,
                              style: AppText.mono(
                                  size: 14, color: rowColor)),
                        ),
                        Expanded(
                          child: Text(
                            (entry['streak'] ?? 1) == 1
                                ? '🔥1'
                                : '🔥${entry['streak']}',
                            textAlign: TextAlign.center,
                            style: AppText.sans(
                                size: 14, color: rowColor),
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          child: Text('${entry['points'] ?? 0}',
                              textAlign: TextAlign.right,
                              style: AppText.mono(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: rowColor)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Streak badge ─────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  final int streak;
  final bool large;
  const _StreakBadge({required this.streak, this.large = false});

  @override
  Widget build(BuildContext context) {
    final label = streak == 1 ? '1 day streak' : '$streak day streak';
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 14 : 9, vertical: large ? 8 : 5),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(large ? 14 : 22),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('🔥', style: TextStyle(fontSize: large ? 14 : 12)),
        SizedBox(width: large ? 6 : 3),
        Text(
          large ? label : '$streak',
          style: AppText.mono(
              size: 13, weight: FontWeight.w700, color: AppColors.amber),
        ),
      ]),
    );
  }
}

// ─── Timer badge ──────────────────────────────────────────────────────────────

class _TimerBadge extends StatelessWidget {
  final int timeElapsed;
  const _TimerBadge({required this.timeElapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.schedule_rounded, size: 12, color: AppColors.amber),
        const SizedBox(width: 4),
        SizedBox(
          width: 42,
          child: Text(formatTime(timeElapsed),
              style: AppText.mono(
                  size: 13, weight: FontWeight.w700, color: AppColors.amber)),
        ),
      ]),
    );
  }
}

// ─── Menu button ──────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  final String fullName, username;
  final VoidCallback onHowTo, onSignOut;
  const _MenuButton(
      {required this.fullName,
        required this.username,
        required this.onHowTo,
        required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'howto') {
          onHowTo();
        } else if (v == 'out') {
          onSignOut();
        }
      },
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border)),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fullName,
                style: AppText.sans(
                    size: 13, weight: FontWeight.w600, color: AppColors.text)),
            Text('@$username',
                style: AppText.sans(size: 11, color: AppColors.muted)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'howto',
          child: Row(children: [
            const SizedBox(
                width: 20, child: Text('?', style: TextStyle(fontSize: 14))),
            const SizedBox(width: 10),
            Text('How to Play',
                style: AppText.sans(size: 13, color: AppColors.text)),
          ]),
        ),
        PopupMenuItem(
          value: 'out',
          child: Row(children: [
            const SizedBox(
                width: 20, child: Text('→', style: TextStyle(fontSize: 14))),
            const SizedBox(width: 10),
            Text('Sign Out',
                style: AppText.sans(size: 13, color: AppColors.red)),
          ]),
        ),
      ],
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.border)),
        child: const Icon(Icons.menu_rounded, size: 15, color: AppColors.muted),
      ),
    );
  }
}

// ─── Pill button ──────────────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool disabled;
  const _PillButton(
      {required this.label,
        required this.icon,
        required this.color,
        this.onTap,
        this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.33 : 1,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.22))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(label,
                  style: AppText.sans(
                      size: 12, weight: FontWeight.w600, color: color)),
            ]),
          ),
        ),
      ),
    );
  }
}