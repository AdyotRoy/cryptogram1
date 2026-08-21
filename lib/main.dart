// lib/main.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// Daily Cryptogram — merged single-file build (v2)
//
//   • CryptogramEngine        (unchanged — from lib/models/cryptogram_engine.dart)
//   • MockSentenceService     (unchanged — from lib/services/mock_sentence_service.dart)
//   • LoginScreen             (from "Quiz app design with timer" — full name / email /
//                              password form, validated, hands off to GameScreen)
//   • GameScreen              (from "Quiz app design with timer" — dark theme,
//                              tap-to-select cipher grid, on-screen keyboard,
//                              hint/check/skip pills, pause overlay, timer badges,
//                              per-puzzle progress dots, solved/all-done summaries)
//
// Changes from v1, per feedback:
//   1. Login/register screen restored ahead of the puzzle screen.
//   2. Only 3 puzzles are played per session (dailySentences is capped with
//      .take(3) — MockSentenceService itself is untouched, still returns 5).
//   3. Added a "Skip" control to move past a puzzle without solving it.
//   4. Each puzzle now tracks and displays its OWN elapsed time (header timer
//      badge + solved-overlay stat + final summary breakdown), in addition to
//      the running session total.
//
// No puzzle-solving logic, cipher generation, or sentence data was modified —
// only the presentation layer changed.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CryptogramApp());
}

// ═════════════════════════════════════════════════════════════════════════════
// SOURCE LOGIC — untouched from the original cryptogram-main project
// ═════════════════════════════════════════════════════════════════════════════

// ─── lib/models/cryptogram_engine.dart (unchanged) ────────────────────────────

class CryptogramEngine {
  final String plainText;
  late final Map<String, String> cipherMap;
  late final String encryptedText;

  CryptogramEngine(this.plainText) {
    cipherMap = _generateDerangedMap();
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

// ─── lib/services/mock_sentence_service.dart (unchanged) ──────────────────────

class MockSentenceService {
  // Pool of accessible, easy-to-medium length phrases and quotes
  static const List<String> _sentencePool = [
    "hello world",
    "keep it simple and focus",
    "flutter makes app development fun",
    "accessibility makes technology better for all",
    "practice makes perfect every day",
    "learning to code opens new doors",
    "puzzles sharpen the mind",
    "stay curious and keep learning",
    "consistency brings great success",
    "creativity is intelligence having fun",
    "action is the key to all success",
    "small steps every day lead to big results",
    "never stop exploring new ideas",
    "clarity comes from taking action",
    "believe you can and you are halfway there",
  ];

  /// Returns 5 easy-to-medium sentences for the current date
  static List<String> getDailyPuzzles() {
    final now = DateTime.now();
    // Unique seed based on Year, Month, and Day (YYYYMMDD)
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    final List<String> poolCopy = List.from(_sentencePool);
    poolCopy.shuffle(random);

    // Pick top 5 for today
    return poolCopy.take(5).toList();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// UI — rebuilt from the "Quiz app design with timer" visual design
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
        useMaterial3: true,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          labelStyle: AppText.sans(color: AppColors.muted, size: 10, weight: FontWeight.w600, letterSpacing: 1.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

// ─── Color palette (from quiz app design) ──────────────────────────────────────

class AppColors {
  static const bg      = Color(0xFF0B0F17);
  static const surface = Color(0xFF131921);
  static const header  = Color(0xFF0D1526);
  static const kbd     = Color(0xFF0D1526);
  static const kbdKey  = Color(0xFF162036);
  static const primary = Color(0xFF4A9EFF);
  static const amber   = Color(0xFFF5A623);
  static const green   = Color(0xFF2EA043);
  static const red     = Color(0xFFF85149);
  static const text    = Color(0xFFE6EDF3);
  static const sub     = Color(0xFFCDD5E0);
  static const muted   = Color(0xFF7A8799);
  static const border  = Color(0xFF232D3F);
}

// ─── Text style helpers (system fonts — no extra font package required) ───────

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
  final now = DateTime.now();
  return '${months[now.month - 1]} ${now.day}, ${now.year}';
}


const _kbdRows = [
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
];

// ─── LoginScreen (from "Quiz app design with timer") ──────────────────────────

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

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$', caseSensitive: false);

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (fullName.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }
    if (fullName.split(' ').length < 2) {
      setState(() => _error = 'Please enter both first and last name.');
      return;
    }
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
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
    await Future.delayed(const Duration(milliseconds: 480));

    if (!mounted) return;
    // Derive a display username from the email local part.
    final username = email.split('@').first;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(username: username, fullName: fullName),
      ),
    );
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
                  colors: [AppColors.primary.withOpacity(0.06), Colors.transparent],
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
            border: Border.all(color: AppColors.primary.withOpacity(0.22)),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 40)],
          ),
          child: const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 26),
        ),
        const SizedBox(height: 14),
        Text(
          'CRYPTOGRAMS',
          style: AppText.mono(size: 20, weight: FontWeight.w700, letterSpacing: 4, color: AppColors.text),
        ),
        const SizedBox(height: 5),
        Text(
          'Daily puzzles · ${_todayLabel()}',
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 60, offset: const Offset(0, 24))],
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
            placeholder: 'Enter your email address',
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
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.muted,
                size: 18,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.red.withOpacity(0.22)),
              ),
              child: Text(_error, style: AppText.sans(size: 12, color: AppColors.red)),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text("View Puzzle's →"),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Labeled text field ───────────────────────────────────────────────────────

class _LabeledField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool obscure;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.obscure = false,
    this.suffixIcon,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_LabeledField> createState() => _LabeledFieldState();
}

class _LabeledFieldState extends State<_LabeledField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppText.sans(size: 10, weight: FontWeight.w600, color: AppColors.muted, letterSpacing: 1.0),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: widget.obscure,
          textCapitalization: widget.textCapitalization,
          keyboardType: widget.keyboardType,
          style: AppText.sans(size: 13, color: AppColors.text),
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            suffixIcon: widget.suffixIcon,
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
      ..color = AppColors.primary.withOpacity(0.055)
      ..style = PaintingStyle.fill;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}

// ─── GameScreen (replaces views/cryptogram_screen.dart) ───────────────────────

class GameScreen extends StatefulWidget {
  final String username;
  final String fullName;
  const GameScreen({super.key, required this.username, required this.fullName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Daily puzzles, sourced from the untouched MockSentenceService.
  // Only 3 are played per session (MockSentenceService itself still returns 5).
  late List<String> dailySentences;
  int _puzzleIndex = 0;
  bool get _isLastPuzzle => _puzzleIndex == dailySentences.length - 1;

  // Engine for the current puzzle, sourced from the untouched CryptogramEngine
  late CryptogramEngine _engine;

  // cipher letter (UPPER) -> plain letter (UPPER), derived from engine.cipherMap
  late Map<String, String> _decodeMap;

  // Per-puzzle UI state (reset on advance)
  final Map<String, String> _userMap = {};
  String? _selectedCipher;
  final Set<String> _hintedLetters = {};
  int _hintsLeft = 3;
  bool _checked = false;
  bool _solved = false;

  // Timers: one running total for the session, one for the current puzzle only
  int _timeElapsed = 0;
  int _puzzleTimeElapsed = 0;
  bool _paused = false;


  Timer? _timer;
  bool _sessionComplete = false;

  // Per-puzzle summary tracking (index-aligned with dailySentences)
  final List<int> _hintsUsedPerPuzzle = [];
  final List<int> _puzzleTimes = [];
  final List<bool> _puzzleWasSkipped = [];

  bool get _inputLocked => _paused || _solved || _sessionComplete;

  @override
  void initState() {
    super.initState();
    dailySentences = MockSentenceService.getDailyPuzzles().take(3).toList();
    _loadPuzzle(_puzzleIndex);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadPuzzle(int index) {
    _engine = CryptogramEngine(dailySentences[index]);
    // Derive cipher->plain (UPPER) map from the engine's plain->cipher map,
    // without altering CryptogramEngine itself.
    _decodeMap = {
      for (final e in _engine.cipherMap.entries) e.value.toUpperCase(): e.key.toUpperCase(),
    };
    _userMap.clear();
    _selectedCipher = null;
    _hintedLetters.clear();
    _hintsLeft = 3;
    _checked = false;
    _solved = false;
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
      if (_paused || !mounted) return;
      setState(() {
        if (!_sessionComplete) _timeElapsed++;
        if (!_solved) _puzzleTimeElapsed++;
      });
    });
  }

  void _togglePause() => setState(() => _paused = !_paused);

  // ─── Letter assignment ────────────────────────────────────────────────────

  void _assignLetter(String plain) {
    if (_paused) {
      _showToast('Resume the timer first');
      return;
    }
    if (_solved || _sessionComplete) return;
    if (_selectedCipher == null) {
      _showToast('Select a letter first');
      return;
    }

    setState(() {
      _userMap.removeWhere((k, v) => v == plain && k != _selectedCipher);
      _userMap[_selectedCipher!] = plain;
      _checked = false;
    });

    _checkSolved();
    _advanceSelection();
  }

  void _clearSelected() {
    if (_selectedCipher == null || _inputLocked) return;
    setState(() {
      _userMap.remove(_selectedCipher);
      _checked = false;
    });
  }

  /// Uses the untouched CryptogramEngine.isSolved() to validate the guesses.
  void _checkSolved() {
    final lowerGuesses = {
      for (final e in _userMap.entries) e.key.toLowerCase(): e.value.toLowerCase(),
    };
    if (_engine.isSolved(lowerGuesses)) {
      setState(() => _solved = true);
      _recordPuzzleResult(skipped: false);
      if (_isLastPuzzle) {
        _timer?.cancel();
        setState(() => _sessionComplete = true);
      }
    }
  }

  void _advanceSelection() {
    final inOrder = <String>[];
    for (final ch in _engine.encryptedText.toUpperCase().split('')) {
      if (RegExp(r'[A-Z]').hasMatch(ch) && !inOrder.contains(ch)) inOrder.add(ch);
    }
    final ci = inOrder.indexOf(_selectedCipher!);
    final nxt = inOrder.skip(ci + 1).firstWhere((l) => !_userMap.containsKey(l), orElse: () => '');
    if (nxt.isNotEmpty) setState(() => _selectedCipher = nxt);
  }

  /// Stores this puzzle's stats exactly once (guards against double-recording
  /// if _checkSolved fires more than once for the same puzzle).
  void _recordPuzzleResult({required bool skipped}) {
    if (_puzzleTimes.length > _puzzleIndex) return;
    _hintsUsedPerPuzzle.add(3 - _hintsLeft);
    _puzzleTimes.add(_puzzleTimeElapsed);
    _puzzleWasSkipped.add(skipped);
  }

  // ─── Advance to next puzzle ───────────────────────────────────────────────

  void _nextPuzzle() {
    if (!_solved || _isLastPuzzle) return;
    setState(() {
      _puzzleIndex++;
      _loadPuzzle(_puzzleIndex);
    });
  }

  // ─── Skip ─────────────────────────────────────────────────────────────────
  void _confirmSkip() {
    if (_paused) {
      _showToast('Resume the timer first');
      return;
    }
    if (_solved || _sessionComplete) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 34, color: AppColors.amber),
              const SizedBox(height: 12),
              Text('Skip this puzzle?', style: AppText.mono(size: 16, weight: FontWeight.w700, color: AppColors.text)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Cancel', style: AppText.sans(size: 13, weight: FontWeight.w600, color: AppColors.sub)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Skip Puzzle', style: AppText.sans(size: 13, weight: FontWeight.w700, color: Colors.black)),
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
    if (_paused) {
      _showToast('Resume the timer first');
      return;
    }
    if (_solved || _sessionComplete) return;

    _recordPuzzleResult(skipped: true);
    _showToast('Puzzle skipped');

    if (_isLastPuzzle) {
      _timer?.cancel();
      setState(() => _sessionComplete = true);
    } else {
      setState(() {
        _puzzleIndex++;
        _loadPuzzle(_puzzleIndex);
      });
    }
  }

  // ─── Hint ─────────────────────────────────────────────────────────────────

  void _useHint() {
    if (_paused) {
      _showToast('Resume the timer first');
      return;
    }
    if (_solved || _sessionComplete) return;
    if (_hintsLeft <= 0) {
      _showToast('No hints remaining');
      return;
    }

    final unguessed = _cipherLetters.where((cl) => _userMap[cl] != _decodeMap[cl]).toList()..shuffle();

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
      _checked = false;
    });

    _showToast('Hint: $pick = $correct');
    _checkSolved();
  }

  // ─── Check ────────────────────────────────────────────────────────────────

  void _checkAnswers() {
    if (_inputLocked) return;
    setState(() => _checked = true);

    final letters = _cipherLetters;
    final wrong = letters.where((cl) => _userMap[cl] != null && _userMap[cl] != _decodeMap[cl]).length;
    final right = letters.where((cl) => _userMap[cl] == _decodeMap[cl]).length;

    if (wrong > 0) {
      _showToast('$wrong letter${wrong > 1 ? 's' : ''} incorrect');
    } else if (right == letters.length) {
      _showToast('Perfect! 🎉');
    } else {
      _showToast('No mistakes so far!');
    }
  }

  // ─── Toast ────────────────────────────────────────────────────────────────

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: AppText.sans(size: 12, color: AppColors.sub), textAlign: TextAlign.center),
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


  void _signOut() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
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
        body: Column(
          children: [
            _buildHeader(),
            _buildProgressBars(),
            Expanded(child: _buildPuzzleArea()),
            _buildControlRow(),
            _buildKeyboard(),
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
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              // Puzzle-specific timer (this is the primary badge — matches
              // "time for each puzzle" from the design).
              _TimerBadge(
                timeElapsed: _puzzleTimeElapsed,
                paused: _paused,
                onToggle: _togglePause,
              ),
              Expanded(
                child: Text(
                  'DAILY CRYPTOGRAM',
                  textAlign: TextAlign.center,
                  style: AppText.mono(size: 13, weight: FontWeight.w700, letterSpacing: 3, color: AppColors.text),
                ),
              ),
              _MenuButton(
                fullName: widget.fullName,
                username: widget.username,
                onHowTo: () => _showToast('Tap a cipher letter, then type or tap your guess.'),
                onSignOut: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Progress bars (puzzle steps + letter fill) ───────────────────────────

  Widget _buildProgressBars() {
    final letters = _cipherLetters;
    final solvedCount = letters.where((cl) => _userMap[cl] == _decodeMap[cl]).length;
    final letterProg = letters.isEmpty ? 0.0 : solvedCount / letters.length;

    return Column(
      children: [
        Container(
          color: AppColors.header,
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dailySentences.length, (i) {
              final done = i < _puzzleWasSkipped.length || (i == _puzzleIndex && (_solved || _sessionComplete));
              final skipped = i < _puzzleWasSkipped.length && _puzzleWasSkipped[i];
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
                    ? Icon(skipped ? Icons.skip_next_rounded : Icons.check_rounded, size: 8, color: Colors.white)
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
    final solvedCount = letters.where((cl) => _userMap[cl] == _decodeMap[cl]).length;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                      ),
                      child: Text(
                        'Puzzle ${_puzzleIndex + 1} of ${dailySentences.length}',
                        style: AppText.sans(size: 11, weight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Cipher words
                ImageFiltered(
                  imageFilter: _paused ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: _engine.encryptedText.toUpperCase().split(' ').map(_buildWord).toList(),
                  ),
                ),
                const SizedBox(height: 22),

                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _dotStat('$solvedCount/${letters.length} solved', AppColors.primary),
                    _divider(),
                    _hintStat(),
                    _divider(),
                    _dotStat('Total ${formatTime(_timeElapsed)}', AppColors.muted),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (_paused)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('⏸', style: TextStyle(fontSize: 26)),
                  const SizedBox(height: 6),
                  Text('Game Paused', style: AppText.sans(size: 13, weight: FontWeight.w600, color: AppColors.sub)),
                  const SizedBox(height: 3),
                  Text('Tap ▶ to resume', style: AppText.sans(size: 11, color: AppColors.muted)),
                ]),
              ),
            ),
          ),

        if (_solved && !_isLastPuzzle) Positioned.fill(child: _buildPuzzleSolvedOverlay()),
        if (_sessionComplete) Positioned.fill(child: _buildAllSolvedOverlay()),
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
    final isCorrect = _checked && guess == _decodeMap[ch];
    final isWrong = _checked && guess.isNotEmpty && guess != _decodeMap[ch];
    final isHinted = _hintedLetters.contains(ch);

    Color borderColor = AppColors.border;
    Color guessColor = AppColors.text;
    Color cellBg = Colors.transparent;
    Color cipherColor = AppColors.muted;

    if (isSelected) {
      borderColor = AppColors.primary;
      cellBg = AppColors.primary.withOpacity(0.09);
      cipherColor = AppColors.primary;
    }
    if (isCorrect) {
      borderColor = AppColors.green;
      guessColor = AppColors.green;
      cellBg = AppColors.green.withOpacity(0.07);
    }
    if (isWrong) {
      borderColor = AppColors.red;
      guessColor = AppColors.red;
      cellBg = AppColors.red.withOpacity(0.07);
    }
    if (isHinted && !isSelected) cipherColor = AppColors.amber;

    return GestureDetector(
      onTap: _inputLocked
          ? null
          : () => setState(() {
                _selectedCipher = ch;
                _checked = false;
              }),
      child: AbsorbPointer(
        absorbing: _inputLocked,
        child: SizedBox(
          width: 30,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(ch, style: AppText.mono(size: 10, color: cipherColor, weight: isHinted ? FontWeight.w700 : FontWeight.w400)),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28,
              height: 32,
              decoration: BoxDecoration(color: cellBg, border: Border(bottom: BorderSide(color: borderColor, width: 2))),
              alignment: Alignment.center,
              child: Text(guess, style: AppText.mono(size: 17, weight: FontWeight.w600, color: guessColor)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _dotStat(String label, Color dot) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: AppText.sans(size: 12, color: AppColors.muted)),
        ]),
      );

  Widget _hintStat() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lightbulb_outline_rounded, size: 12, color: _hintsLeft > 0 ? AppColors.amber : AppColors.muted),
          const SizedBox(width: 4),
          Text('$_hintsLeft hint${_hintsLeft != 1 ? 's' : ''} left',
              style: AppText.sans(size: 12, color: _hintsLeft > 0 ? AppColors.amber : AppColors.muted)),
        ]),
      );

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text('·', style: AppText.sans(size: 12, color: AppColors.border)),
      );

  // ─── Puzzle solved overlay (intermediate) ─────────────────────────────────

  Widget _buildPuzzleSolvedOverlay() {
    final myTime = _puzzleTimes.length > _puzzleIndex ? _puzzleTimes[_puzzleIndex] : _puzzleTimeElapsed;
    final hintsUsed = _hintsUsedPerPuzzle.length > _puzzleIndex ? _hintsUsedPerPuzzle[_puzzleIndex] : (3 - _hintsLeft);
    return Container(
      color: AppColors.bg.withOpacity(0.88),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 60)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✓', style: TextStyle(fontSize: 40, color: AppColors.green)),
              const SizedBox(height: 10),
              Text(
                'Puzzle ${_puzzleIndex + 1} Complete!',
                style: AppText.mono(size: 18, weight: FontWeight.w700, color: AppColors.green),
              ),
              const SizedBox(height: 16),
              // Mini stats — this puzzle's own time, not the session total.
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Puzzle ${_puzzleIndex + 2} unlocked',
                        style: AppText.sans(size: 13, weight: FontWeight.w700, color: AppColors.primary),
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
                  child: Text('Next Puzzle →', style: AppText.sans(size: 14, weight: FontWeight.w700, color: Colors.white)),
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
    final anySkipped = _puzzleWasSkipped.contains(true);

    return Container(
      color: AppColors.bg.withOpacity(0.9),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 80)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(anySkipped ? '🏁' : '🎉', style: const TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text('All Done, $firstName!', style: AppText.mono(size: 19, weight: FontWeight.w700, color: AppColors.green)),
                const SizedBox(height: 4),
                Text('You finished all ${dailySentences.length} puzzles', style: AppText.sans(size: 12, color: AppColors.muted)),
                const SizedBox(height: 20),

                Text(formatTime(_timeElapsed), style: AppText.mono(size: 36, weight: FontWeight.w700, color: AppColors.amber)),
                Text('total time', style: AppText.sans(size: 11, color: AppColors.muted)),

                const SizedBox(height: 20),

                // Per-puzzle breakdown — own time + hints + skipped status
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: List.generate(dailySentences.length, (i) {
                      final time = i < _puzzleTimes.length ? _puzzleTimes[i] : 0;
                      final hints = i < _hintsUsedPerPuzzle.length ? _hintsUsedPerPuzzle[i] : 0;
                      final skipped = i < _puzzleWasSkipped.length && _puzzleWasSkipped[i];
                      final isLast = i == dailySentences.length - 1;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: (skipped ? AppColors.amber : AppColors.green).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(skipped ? Icons.skip_next_rounded : Icons.check_rounded,
                                  size: 13, color: skipped ? AppColors.amber : AppColors.green),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Puzzle ${i + 1} · ${formatTime(time)}${skipped ? ' · skipped' : ''}',
                                style: AppText.sans(size: 12, color: AppColors.sub),
                              ),
                            ),
                            Text(
                              hints == 0 ? 'No hints 🌟' : '$hints hint${hints > 1 ? 's' : ''}',
                              style: AppText.sans(size: 11, color: hints == 0 ? AppColors.green : AppColors.muted),
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
                    onPressed: _signOut,
                    child: Text('Sign Out', style: AppText.sans(size: 13, weight: FontWeight.w600, color: AppColors.red)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) => Column(children: [
        Text(value, style: AppText.sans(size: 15, weight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppText.sans(size: 10, color: AppColors.muted, letterSpacing: 0.8)),
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
            label: 'Check',
            icon: Icons.check_rounded,
            color: AppColors.primary,
            disabled: _inputLocked,
            onTap: _checkAnswers,
          ),
          const SizedBox(width: 8),
          _PillButton(
            label: 'Skip',
            icon: Icons.skip_next_rounded,
            color: AppColors.muted,
            disabled: _inputLocked,
            onTap: _confirmSkip,
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
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
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: keys.map(_buildKey).toList()),
      );

  Widget _buildKey(String key) {
    final blocked = _inputLocked;
    final correct = _userMap.entries.any((e) => e.value == key && _decodeMap[e.key] == key);
    final wrong = !correct && _userMap.values.contains(key);

    Color bg = AppColors.kbdKey, fg = AppColors.text, border = Colors.white.withOpacity(0.05);
    if (correct) {
      bg = AppColors.green.withOpacity(0.18);
      fg = AppColors.green;
      border = AppColors.green.withOpacity(0.28);
    } else if (wrong) {
      bg = Colors.white.withOpacity(0.04);
      fg = const Color(0xFF4E5A6A);
      border = Colors.white.withOpacity(0.07);
    }

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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: border)),
            alignment: Alignment.center,
            child: Text(key, style: AppText.mono(size: 13, weight: FontWeight.w600, color: blocked ? fg.withOpacity(0.28) : fg)),
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.backspace_outlined, size: 15, color: blocked ? AppColors.muted.withOpacity(0.28) : AppColors.muted),
            const SizedBox(width: 6),
            Text('Clear', style: AppText.mono(size: 13, color: blocked ? AppColors.muted.withOpacity(0.28) : AppColors.muted)),
          ]),
        ),
      ),
    );
  }
}

// ─── Timer badge ──────────────────────────────────────────────────────────────

class _TimerBadge extends StatelessWidget {
  final int timeElapsed;
  final bool paused;
  final VoidCallback onToggle;
  const _TimerBadge({required this.timeElapsed, required this.paused, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 11, right: 5, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: AppColors.amber.withOpacity(0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.amber.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.schedule_rounded, size: 12, color: AppColors.amber),
        const SizedBox(width: 4),
        SizedBox(
          width: 42,
          child: Text(formatTime(timeElapsed), style: AppText.mono(size: 13, weight: FontWeight.w700, color: AppColors.amber)),
        ),
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: paused ? AppColors.primary.withOpacity(0.18) : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: paused ? AppColors.primary.withOpacity(0.35) : Colors.white.withOpacity(0.09)),
            ),
            child: Icon(paused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 14, color: paused ? AppColors.primary : AppColors.muted),
          ),
        ),
      ]),
    );
  }
}

// ─── Menu button ──────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  final String fullName, username;
  final VoidCallback onHowTo, onSignOut;
  const _MenuButton({required this.fullName, required this.username, required this.onHowTo, required this.onSignOut});

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fullName, style: AppText.sans(size: 13, weight: FontWeight.w600, color: AppColors.text)),
            Text('@$username', style: AppText.sans(size: 11, color: AppColors.muted)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'howto',
          child: Row(children: [
            const SizedBox(width: 20, child: Text('?', style: TextStyle(fontSize: 14))),
            const SizedBox(width: 10),
            Text('How to Play', style: AppText.sans(size: 13, color: AppColors.text)),
          ]),
        ),
        PopupMenuItem(
          value: 'out',
          child: Row(children: [
            const SizedBox(width: 20, child: Text('→', style: TextStyle(fontSize: 14))),
            const SizedBox(width: 10),
            Text('Sign Out', style: AppText.sans(size: 13, color: AppColors.red)),
          ]),
        ),
      ],
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.border)),
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
  const _PillButton({required this.label, required this.icon, required this.color, this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.33 : 1,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.22))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(label, style: AppText.sans(size: 12, weight: FontWeight.w600, color: color)),
            ]),
          ),
        ),
      ),
    );
  }
}
