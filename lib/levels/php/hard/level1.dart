import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../services/api_service.dart';
import '../../../services/user_preferences.dart';
import '../../../services/music_service.dart';
import '../../../services/daily_challenge_service.dart';

class PhpLevel1Hard extends StatefulWidget {
  const PhpLevel1Hard({super.key});

  @override
  State<PhpLevel1Hard> createState() => _PhpLevel1HardState();
}

class _PhpLevel1HardState extends State<PhpLevel1Hard> {
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool level1Completed = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 300;
  Timer? countdownTimer;
  Timer? scoreReductionTimer;
  Map<String, dynamic>? currentUser;

  String? currentlyDraggedBlock;
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  int _availableHintCards = 0;
  bool _showHint = false;
  String _currentHint = '';
  bool _isUsingHint = false;

  // Track block instances with unique IDs
  List<BlockItem> allBlockItems = [];
  List<BlockItem> droppedBlockItems = [];

  @override
  void initState() {
    super.initState();
    resetBlocks();
    _loadUserData();
    _calculateScaleFactor();
    _startGameMusic();
    _loadHintCards();
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic();
      await musicService.playSoundEffect('game_start_hard.mp3');
      await Future.delayed(Duration(milliseconds: 500));
      await musicService.playSoundEffect('game_music_hard.mp3');
    });
  }

  void _calculateScaleFactor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;

      setState(() {
        if (screenWidth < _baseScreenWidth) {
          _scaleFactor = screenWidth / _baseScreenWidth;
        } else {
          _scaleFactor = 1.0;
        }
      });
    });
  }

  Future<void> _loadHintCards() async {
    final user = await UserPreferences.getUser();
    if (user['id'] != null) {
      final hintCards = await DailyChallengeService.getUserHintCards(user['id']);
      setState(() {
        _availableHintCards = hintCards;
      });
    }
  }

  void _useHintCard() async {
    if (_availableHintCards > 0 && !_isUsingHint) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('hint_use_hard.mp3');

      setState(() {
        _isUsingHint = true;
        _showHint = true;
        _currentHint = _getLevelHint();
        _availableHintCards--;
      });

      final user = await UserPreferences.getUser();
      if (user['id'] != null) {
        await DailyChallengeService.useHintCard(user['id']);
      }

      _autoDragCorrectBlocks();
    } else if (_availableHintCards <= 0) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('error_hard.mp3');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hint cards! Complete challenges to earn more.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _autoDragCorrectBlocks() {
    List<String> correctBlocks = [
      '<?php',
      'function calculateTotal(\$price, \$quantity) {',
      '\$total = \$price * \$quantity;',
      'return \$total;',
      '}',
      'function displayReceipt(\$items) {',
      'echo "=== RECEIPT ===\\n";',
      '\$grandTotal = 0;',
      'foreach (\$items as \$item) {',
      '\$itemTotal = calculateTotal(\$item["price"], \$item["quantity"]);',
      'echo \$item["name"] . ": " . \$itemTotal . "\\n";',
      '\$grandTotal += \$itemTotal;',
      '}',
      'echo "Total: " . \$grandTotal;',
      '}',
      '\$shoppingCart = [',
      '["name" => "Apple", "price" => 25, "quantity" => 3],',
      '["name" => "Banana", "price" => 10, "quantity" => 5]',
      '];',
      'displayReceipt(\$shoppingCart);',
      '?>'
    ];

    setState(() {
      droppedBlockItems.clear();
    });

    int delay = 0;
    for (String block in correctBlocks) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          setState(() {
            // Find the block in allBlockItems and move it to droppedBlockItems
            var blockItem = allBlockItems.firstWhere(
                  (item) => item.text == block && !droppedBlockItems.contains(item),
              orElse: () => BlockItem(block, UniqueKey()),
            );

            if (!droppedBlockItems.contains(blockItem)) {
              droppedBlockItems.add(blockItem);
            }
            allBlockItems.remove(blockItem);
          });
        }
      });
      delay += 350;
    }

    Future.delayed(Duration(milliseconds: delay + 1000), () {
      if (mounted) {
        setState(() {
          _showHint = false;
          _isUsingHint = false;
        });
      }
    });
  }

  String _getLevelHint() {
    return "HARD: Create a PHP program with functions and arrays!\n\nCorrect code uses:\n• PHP opening and closing tags\n• Functions with parameters\n• Arrays and associative arrays\n• foreach loop\n• Function calls and return values\n• String concatenation and output";
  }

  void _loadUserData() async {
    final user = await UserPreferences.getUser();
    setState(() {
      currentUser = user;
    });
    loadScoreFromDatabase();
    _loadHintCards();
  }

  void resetBlocks() {
    List<String> correctBlocks = [
      '<?php',
      'function calculateTotal(\$price, \$quantity) {',
      '\$total = \$price * \$quantity;',
      'return \$total;',
      '}',
      'function displayReceipt(\$items) {',
      'echo "=== RECEIPT ===\\n";',
      '\$grandTotal = 0;',
      'foreach (\$items as \$item) {',
      '\$itemTotal = calculateTotal(\$item["price"], \$item["quantity"]);',
      'echo \$item["name"] . ": " . \$itemTotal . "\\n";',
      '\$grandTotal += \$itemTotal;',
      '}',
      'echo "Total: " . \$grandTotal;',
      '}',
      '\$shoppingCart = [',
      '["name" => "Apple", "price" => 25, "quantity" => 3],',
      '["name" => "Banana", "price" => 10, "quantity" => 5]',
      '];',
      'displayReceipt(\$shoppingCart);',
      '?>'
    ];

    List<String> incorrectBlocks = [
      '<?php',
      'function calculateTotal(price, quantity) {',
      'total = price * quantity;',
      'return total;',
      '}',
      'function displayReceipt(items) {',
      'print "=== RECEIPT ===";',
      'grandTotal = 0;',
      'for (item in items) {',
      'itemTotal = calculateTotal(item.price, item.quantity);',
      'echo item.name + ": " + itemTotal;',
      'grandTotal = grandTotal + itemTotal;',
      '}',
      'echo "Total: " . grandTotal;',
      '}',
      '\$shoppingCart = array(',
      'array("name" => "Apple", "price" => 25, "quantity" => 3)',
      'array("name" => "Banana", "price" => 10, "quantity" => 5)',
      ');',
      'displayReceipt(shoppingCart);',
      '?>',
      'console.log("Total: " + grandTotal);',
      'def calculateTotal(price, quantity):',
      'return price * quantity',
      'var shoppingCart = [...]',
      'foreach (\$items as &\$item)'
    ];

    incorrectBlocks.shuffle();
    List<String> selectedIncorrectBlocks = incorrectBlocks.take(5).toList();

    // Create block items with unique keys
    allBlockItems.clear();
    droppedBlockItems.clear();

    // Add all blocks with unique identifiers
    for (String block in [...correctBlocks, ...selectedIncorrectBlocks]) {
      allBlockItems.add(BlockItem(block, UniqueKey()));
    }

    allBlockItems.shuffle();
  }

  void startGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start_hard.mp3');

    setState(() {
      gameStarted = true;
      score = 3;
      remainingSeconds = 300;
      droppedBlockItems.clear();
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
      resetBlocks();
    });
    startTimers();
  }

  void startTimers() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isAnsweredCorrectly) {
        timer.cancel();
        return;
      }

      setState(() {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          score = 0;
          timer.cancel();
          scoreReductionTimer?.cancel();
          saveScoreToDatabase(score);

          final musicService = Provider.of<MusicService>(context, listen: false);
          musicService.playSoundEffect('time_up_hard.mp3');

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("⏰ Time's Up!"),
              content: Text("Score: $score"),
              actions: [
                TextButton(
                  onPressed: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('click.mp3');
                    resetGame();
                    Navigator.pop(context);
                  },
                  child: Text("Retry"),
                )
              ],
            ),
          );
        }
      });
    });

    scoreReductionTimer = Timer.periodic(Duration(seconds: 180), (timer) {
      if (isAnsweredCorrectly || score <= 1) {
        timer.cancel();
        return;
      }

      setState(() {
        score--;
        final musicService = Provider.of<MusicService>(context, listen: false);
        musicService.playSoundEffect('penalty_hard.mp3');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⏰ Time penalty! -1 point. Current score: $score")),
        );
      });
    });
  }

  void resetGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('reset.mp3');

    setState(() {
      score = 3;
      remainingSeconds = 300;
      gameStarted = false;
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
      droppedBlockItems.clear();
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();
      resetBlocks();
    });
  }

  Future<void> saveScoreToDatabase(int score) async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.saveScoreWithDifficulty(
        currentUser!['id'],
        'PHP',
        'Hard',
        1,
        score,
        score == 3,
      );

      if (response['success'] == true) {
        setState(() {
          level1Completed = score == 3;
          previousScore = score;
          hasPreviousScore = true;
        });

        print('Score saved successfully: $score for PHP Hard Level 1');
      } else {
        print('Failed to save score: ${response['message']}');
      }
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScoresWithDifficulty(
          currentUser!['id'],
          'PHP',
          'Hard'
      );

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level1Data = scoresData['1'];

        if (level1Data != null) {
          setState(() {
            previousScore = level1Data['score'] ?? 0;
            level1Completed = level1Data['completed'] ?? false;
            hasPreviousScore = true;
            score = previousScore;
          });
          print('Loaded previous score: $previousScore for PHP Hard Level 1');
        }
      }
    } catch (e) {
      print('Error loading score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'function calculateTotal(price, quantity) {',
      'total = price * quantity;',
      'return total;',
      'function displayReceipt(items) {',
      'print "=== RECEIPT ===";',
      'grandTotal = 0;',
      'for (item in items) {',
      'itemTotal = calculateTotal(item.price, item.quantity);',
      'echo item.name + ": " + itemTotal;',
      'grandTotal = grandTotal + itemTotal;',
      'echo "Total: " . grandTotal;',
      '\$shoppingCart = array(',
      'array("name" => "Apple", "price" => 25, "quantity" => 3)',
      'array("name" => "Banana", "price" => 10, "quantity" => 5)',
      ');',
      'displayReceipt(shoppingCart);',
      'console.log("Total: " + grandTotal);',
      'def calculateTotal(price, quantity):',
      'return price * quantity',
      'var shoppingCart = [...]',
      'foreach (\$items as &\$item)'
    ];
    return incorrectBlocks.contains(block);
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlockItems.isEmpty) return;

    final musicService = Provider.of<MusicService>(context, listen: false);

    // Convert to text for checking
    List<String> droppedBlocksText = droppedBlockItems.map((item) => item.text).toList();

    bool hasIncorrectBlock = droppedBlocksText.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
      musicService.playSoundEffect('error_hard.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ You used incorrect PHP syntax! -1 point. Current score: $score"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        scoreReductionTimer?.cancel();
        saveScoreToDatabase(score);

        musicService.playSoundEffect('game_over_hard.mp3');

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("You used incorrect PHP syntax and lost all points!"),
            actions: [
              TextButton(
                onPressed: () {
                  musicService.playSoundEffect('click.mp3');
                  Navigator.pop(context);
                  resetGame();
                },
                child: Text("Retry"),
              )
            ],
          ),
        );
      }
      return;
    }

    String answer = droppedBlocksText.join(' ');
    String normalizedAnswer = answer.replaceAll(' ', '').replaceAll('\n', '').toLowerCase();

    bool hasPhpOpen = normalizedAnswer.contains('<?php');
    bool hasCalculateFunction = normalizedAnswer.contains('functioncalculatetotal(\$price,\$quantity){');
    bool hasTotalCalculation = normalizedAnswer.contains('\$total=\$price*\$quantity;');
    bool hasReturnTotal = normalizedAnswer.contains('return\$total;');
    bool hasFunctionClose = normalizedAnswer.contains('}');
    bool hasDisplayFunction = normalizedAnswer.contains('functiondisplayreceipt(\$items){');
    bool hasEchoReceipt = normalizedAnswer.contains('echo"===receipt===\\n";');
    bool hasGrandTotal = normalizedAnswer.contains('\$grandtotal=0;');
    bool hasForeachLoop = normalizedAnswer.contains('foreach(\$itemsas\$item){');
    bool hasItemTotal = normalizedAnswer.contains('\$itemtotal=calculatetotal(\$item["price"],\$item["quantity"]);');
    bool hasEchoItem = normalizedAnswer.contains('echo\$item["name"].":".\$itemtotal."\\n";');
    bool hasAddToGrandTotal = normalizedAnswer.contains('\$grandtotal+=\$itemtotal;');
    bool hasEchoTotal = normalizedAnswer.contains('echo"total:".\$grandtotal;');
    bool hasShoppingCart = normalizedAnswer.contains('\$shoppingcart=[');
    bool hasAppleItem = normalizedAnswer.contains('["name"=>"apple","price"=>25,"quantity"=>3],');
    bool hasBananaItem = normalizedAnswer.contains('["name"=>"banana","price"=>10,"quantity"=>5]');
    bool hasArrayClose = normalizedAnswer.contains('];');
    bool hasFunctionCall = normalizedAnswer.contains('displayreceipt(\$shoppingcart);');
    bool hasPhpClose = normalizedAnswer.contains('?>');

    if (hasPhpOpen && hasCalculateFunction && hasTotalCalculation && hasReturnTotal &&
        hasFunctionClose && hasDisplayFunction && hasEchoReceipt && hasGrandTotal &&
        hasForeachLoop && hasItemTotal && hasEchoItem && hasAddToGrandTotal &&
        hasEchoTotal && hasShoppingCart && hasAppleItem && hasBananaItem &&
        hasArrayClose && hasFunctionCall && hasPhpClose) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);

      if (score == 3) {
        musicService.playSoundEffect('perfect_hard.mp3');
      } else {
        musicService.playSoundEffect('success_hard.mp3');
      }

      final gameScore = score;
      final leaderboardPoints = score * 30;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Correct!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Excellent! You built an advanced PHP program with functions and arrays!"),
              SizedBox(height: 10),
              Text("Game Score: $gameScore/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              Text("Leaderboard Points: $leaderboardPoints/90", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've mastered PHP Hard Level!",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚠️ Get a perfect score (3/3) for full completion!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple),
                ),
                child: Text(
                  "🎯 Hard Difficulty: 30× Points Multiplier!",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("Program Output:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("=== RECEIPT ===", style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
                    Text("Apple: 75", style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
                    Text("Banana: 50", style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
                    Text("Total: 125", style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "💎 Advanced Features: Functions, arrays, foreach loops, string concatenation!",
                style: TextStyle(color: Colors.cyan, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                musicService.playSoundEffect('click.mp3');
                Navigator.pop(context);
                if (score == 3) {
                  musicService.playSoundEffect('level_complete.mp3');
                  Navigator.pushReplacementNamed(context, '/php_level2_hard');
                } else {
                  Navigator.pushReplacementNamed(context, '/levels',
                      arguments: {'language': 'PHP', 'difficulty': 'hard'});
                }
              },
              child: Text(score == 3 ? "Next Level" : "Go Back"),
            )
          ],
        ),
      );
    } else {
      musicService.playSoundEffect('wrong_hard.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Incomplete PHP program. -1 point. Current score: $score")),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        scoreReductionTimer?.cancel();
        saveScoreToDatabase(score);

        musicService.playSoundEffect('game_over_hard.mp3');

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("Remember to build the complete PHP program with functions, arrays, and proper syntax."),
            actions: [
              TextButton(
                onPressed: () {
                  musicService.playSoundEffect('click.mp3');
                  Navigator.pop(context);
                  resetGame();
                },
                child: Text("Retry"),
              )
            ],
          ),
        );
      }
    }
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget _buildHintDisplay() {
    if (!_showHint) return SizedBox();

    return Positioned(
      top: 60 * _scaleFactor,
      left: 20 * _scaleFactor,
      right: 20 * _scaleFactor,
      child: Container(
        padding: EdgeInsets.all(16 * _scaleFactor),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12 * _scaleFactor),
          border: Border.all(color: Colors.purpleAccent, width: 2 * _scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8 * _scaleFactor,
              offset: Offset(0, 4 * _scaleFactor),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.white, size: 20 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  '💡 Hint Activated!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * _scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              _currentHint,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * _scaleFactor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Correct blocks are being placed automatically...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * _scaleFactor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCodePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8 * _scaleFactor),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor, vertical: 6 * _scaleFactor),
            decoration: BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8 * _scaleFactor),
                topRight: Radius.circular(8 * _scaleFactor),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.grey[400], size: 16 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  'shopping_cart.php',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12 * _scaleFactor,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12 * _scaleFactor),
            child: _buildCodeContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeContent() {
    if (droppedBlockItems.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '// Drag blocks to build your PHP program',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12 * _scaleFactor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      );
    }

    List<Widget> codeLines = [];
    int lineNumber = 1;

    for (BlockItem blockItem in droppedBlockItems) {
      String block = blockItem.text;
      bool isPhpTag = block.contains('<?') || block.contains('?>');
      bool isFunction = block.contains('function ');
      bool isVariable = block.contains('\$') && block.contains('=');
      bool isEcho = block.contains('echo ');
      bool isLoop = block.contains('foreach');
      bool isArray = block.contains('[') && block.contains(']');
      bool isReturn = block.contains('return ');
      bool isIncorrect = isIncorrectBlock(block);

      Color textColor = Colors.white;
      if (isPhpTag) {
        textColor = Color(0xFF569CD6);
      } else if (isFunction) {
        textColor = Color(0xFFDCDCAA);
      } else if (isVariable) {
        textColor = Color(0xFF9CDCFE);
      } else if (isEcho) {
        textColor = Color(0xFFCE9178);
      } else if (isLoop) {
        textColor = Color(0xFFC586C0);
      } else if (isArray) {
        textColor = Color(0xFFCE9178);
      } else if (isReturn) {
        textColor = Color(0xFF569CD6);
      } else if (isIncorrect) {
        textColor = Colors.red;
      }

      String displayCode = block;

      // Add proper indentation
      if (block.startsWith('\$') ||
          block.contains('echo ') ||
          block.contains('return ') ||
          block.contains('\$itemTotal =') ||
          block.contains('\$grandTotal +=')) {
        displayCode = '    \$block';
      }

      // Additional indentation for loop body
      if (block.contains('\$itemTotal = calculateTotal') ||
          block.contains('echo \$item["name"]') ||
          block.contains('\$grandTotal += \$itemTotal')) {
        displayCode = '        $block';
      }

      codeLines.add(_buildCodeLineWithNumber(lineNumber++, displayCode,
          textColor: textColor,
          isIncorrect: isIncorrect
      ));

      // Add spacing between functions
      if (block == '}' || block == '];') {
        codeLines.add(SizedBox(height: 8 * _scaleFactor));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: codeLines,
    );
  }

  Widget _buildCodeLineWithNumber(int lineNumber, String code, {Color? textColor, bool isIncorrect = false}) {
    Color finalTextColor = textColor ?? Colors.white;

    if (isIncorrect) {
      finalTextColor = Colors.red;
    }

    return Container(
      height: 20 * _scaleFactor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30 * _scaleFactor,
            child: Text(
              lineNumber.toString().padLeft(2, ' '),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12 * _scaleFactor,
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(width: 16 * _scaleFactor),
          Expanded(
            child: Text(
              code,
              style: TextStyle(
                color: finalTextColor,
                fontSize: 12 * _scaleFactor,
                fontFamily: 'monospace',
                fontWeight: isIncorrect ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    scoreReductionTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.playBackgroundMusic();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newScreenWidth = MediaQuery.of(context).size.width;
      final newScaleFactor = newScreenWidth < _baseScreenWidth ? newScreenWidth / _baseScreenWidth : 1.0;

      if (newScaleFactor != _scaleFactor) {
        setState(() {
          _scaleFactor = newScaleFactor;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("⚡ PHP - Level 1 (Hard)", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.purple,
        actions: gameStarted ? [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * _scaleFactor),
            child: Row(
              children: [
                Icon(Icons.timer, size: 18 * _scaleFactor),
                SizedBox(width: 4 * _scaleFactor),
                Text(formatTime(remainingSeconds), style: TextStyle(fontSize: 14 * _scaleFactor)),
                SizedBox(width: 16 * _scaleFactor),
                Icon(Icons.star, color: Colors.yellowAccent, size: 18 * _scaleFactor),
                Text(" $score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * _scaleFactor)),
              ],
            ),
          ),
        ] : [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D1B69),
              Color(0xFF3B267B),
              Color(0xFF5A2A8C),
            ],
          ),
        ),
        child: Stack(
          children: [
            gameStarted ? buildGameUI() : buildStartScreen(),
            if (gameStarted && !isAnsweredCorrectly) ...[
              _buildHintDisplay(),
              Positioned(
                bottom: 20 * _scaleFactor,
                right: 20 * _scaleFactor,
                child: GestureDetector(
                  onTap: _useHintCard,
                  child: Container(
                    padding: EdgeInsets.all(12 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: _availableHintCards > 0 ? Colors.purple : Colors.grey,
                      borderRadius: BorderRadius.circular(20 * _scaleFactor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4 * _scaleFactor,
                          offset: Offset(0, 2 * _scaleFactor),
                        )
                      ],
                      border: Border.all(
                        color: _availableHintCards > 0 ? Colors.purpleAccent : Colors.grey,
                        width: 2 * _scaleFactor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.white, size: 20 * _scaleFactor),
                        SizedBox(width: 6 * _scaleFactor),
                        Text(
                          '$_availableHintCards',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18 * _scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildStartScreen() {
    final displayGameScore = previousScore;
    final displayLeaderboardPoints = previousScore * 30;
    final maxGameScore = 3;
    final maxLeaderboardPoints = 90;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16 * _scaleFactor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('button_click.mp3');
                startGame();
              },
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text("Start Hard", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: Colors.purple,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            Container(
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.purple, size: 20 * _scaleFactor),
                  SizedBox(width: 8 * _scaleFactor),
                  Text(
                    'Hint Cards: $_availableHintCards',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16 * _scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Use hint cards during the game for help!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12 * _scaleFactor,
              ),
            ),

            if (level1Completed)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "✅ Hard Level completed with perfect score!",
                      style: TextStyle(color: Colors.green, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "🎮 Game Score: $displayGameScore/$maxGameScore",
                      style: TextStyle(color: Colors.green, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "🏆 Leaderboard Points: $displayLeaderboardPoints/$maxLeaderboardPoints",
                      style: TextStyle(color: Colors.blue, fontSize: 14 * _scaleFactor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (hasPreviousScore && previousScore > 0)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "📊 Your previous hard score:",
                      style: TextStyle(color: Colors.blue, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Game: $displayGameScore/$maxGameScore",
                      style: TextStyle(color: Colors.white, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Leaderboard: $displayLeaderboardPoints/$maxLeaderboardPoints",
                      style: TextStyle(color: Colors.blue, fontSize: 14 * _scaleFactor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Try again to get a perfect score!",
                      style: TextStyle(color: Colors.orange, fontSize: 14 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (hasPreviousScore && previousScore == 0)
                Padding(
                  padding: EdgeInsets.only(top: 10 * _scaleFactor),
                  child: Column(
                    children: [
                      Text(
                        "😅 Your previous score: $displayGameScore/$maxGameScore",
                        style: TextStyle(color: Colors.red, fontSize: 16 * _scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5 * _scaleFactor),
                      Text(
                        "Don't give up! You can do better this time!",
                        style: TextStyle(color: Colors.orange, fontSize: 14 * _scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

            SizedBox(height: 30 * _scaleFactor),
            Container(
              padding: EdgeInsets.all(16 * _scaleFactor),
              margin: EdgeInsets.all(16 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.purple[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 Hard Level Objective",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.purple[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Build an advanced PHP program with functions, arrays, and loops for a shopping cart system using all 13 blocks",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.purple[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(8 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8 * _scaleFactor),
                      border: Border.all(color: Colors.purple),
                    ),
                    child: Text(
                      "🎁 Hard Difficulty: 30× Points Multiplier!",
                      style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        color: Colors.purple[800],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "🎮 Perfect Score (3/3) = 90 Leaderboard Points",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                  SizedBox(height: 5 * _scaleFactor),
                  Text(
                    "(Easy: 30 points, Medium: 60 points, Hard: 90 points)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11 * _scaleFactor,
                        color: Colors.purple,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGameUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * _scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('📖 Short Story',
                    style: TextStyle(fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              TextButton.icon(
                onPressed: () {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('toggle.mp3');
                  setState(() {
                    isTagalog = !isTagalog;
                  });
                },
                icon: Icon(Icons.translate, size: 16 * _scaleFactor, color: Colors.white),
                label: Text(isTagalog ? 'English' : 'Tagalog',
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 10 * _scaleFactor),
          Text(
            isTagalog
                ? 'Si Juan ay gustong gumawa ng online shopping cart system gamit ang PHP! Kailangan niyang gumawa ng functions para kalkulahin ang total at mag-display ng receipt. Tulungan siyang buuin ang program!'
                : 'Juan wants to create an online shopping cart system using PHP! He needs to create functions to calculate totals and display receipts. Help him build the program!',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🧩 Build the advanced PHP program with functions and arrays using all 13 blocks',
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          // UPDATED: Larger target area to fit all blocks
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 280 * _scaleFactor, // Increased height
              maxHeight: 400 * _scaleFactor, // Increased max height
            ),
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.purple, width: 2.5 * _scaleFactor),
              borderRadius: BorderRadius.circular(20 * _scaleFactor),
            ),
            child: DragTarget<BlockItem>(
              onWillAccept: (data) {
                // Allow any block to be dropped
                return true;
              },
              onAccept: (BlockItem data) {
                if (!isAnsweredCorrectly) {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('block_drop.mp3');

                  setState(() {
                    // Only add if not already in dropped blocks
                    if (!droppedBlockItems.contains(data)) {
                      droppedBlockItems.add(data);
                    }
                    allBlockItems.remove(data);
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 6 * _scaleFactor, // Reduced spacing
                    runSpacing: 6 * _scaleFactor, // Reduced run spacing
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: droppedBlockItems.map((blockItem) {
                      return Draggable<BlockItem>(
                        data: blockItem,
                        feedback: Material(
                          color: Colors.transparent,
                          child: puzzleBlock(blockItem.text, Colors.purpleAccent),
                        ),
                        childWhenDragging: puzzleBlock(blockItem.text, Colors.purpleAccent.withOpacity(0.5)),
                        child: puzzleBlock(blockItem.text, Colors.purpleAccent),
                        onDragStarted: () {
                          final musicService = Provider.of<MusicService>(context, listen: false);
                          musicService.playSoundEffect('block_pickup.mp3');
                          setState(() {
                            currentlyDraggedBlock = blockItem.text;
                          });
                        },
                        onDragEnd: (details) {
                          setState(() {
                            currentlyDraggedBlock = null;
                          });

                          if (!isAnsweredCorrectly && !details.wasAccepted) {
                            Future.delayed(Duration(milliseconds: 50), () {
                              if (mounted) {
                                setState(() {
                                  if (!allBlockItems.contains(blockItem)) {
                                    allBlockItems.add(blockItem);
                                  }
                                  droppedBlockItems.remove(blockItem);
                                });
                              }
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20 * _scaleFactor),
          Text('💻 Code Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getCodePreview(),
          SizedBox(height: 20 * _scaleFactor),

          // UPDATED: Larger available blocks area
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 180 * _scaleFactor, // Increased height
            ),
            padding: EdgeInsets.all(12 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
            ),
            child: Wrap(
              spacing: 6 * _scaleFactor, // Reduced spacing
              runSpacing: 8 * _scaleFactor, // Reduced run spacing
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: allBlockItems.map((blockItem) {
                return isAnsweredCorrectly
                    ? puzzleBlock(blockItem.text, Colors.grey)
                    : Draggable<BlockItem>(
                  data: blockItem,
                  feedback: Material(
                    color: Colors.transparent,
                    child: puzzleBlock(blockItem.text, Colors.deepPurple),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(blockItem.text, Colors.deepPurple),
                  ),
                  child: puzzleBlock(blockItem.text, Colors.deepPurple),
                  onDragStarted: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('block_pickup.mp3');
                    setState(() {
                      currentlyDraggedBlock = blockItem.text;
                    });
                  },
                  onDragEnd: (details) {
                    setState(() {
                      currentlyDraggedBlock = null;
                    });

                    if (!isAnsweredCorrectly && !details.wasAccepted) {
                      Future.delayed(Duration(milliseconds: 50), () {
                        if (mounted) {
                          setState(() {
                            if (!allBlockItems.contains(blockItem)) {
                              allBlockItems.add(blockItem);
                            }
                          });
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 30 * _scaleFactor),
          ElevatedButton.icon(
            onPressed: isAnsweredCorrectly ? null : () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('compile_hard.mp3');
              checkAnswer();
            },
            icon: Icon(Icons.play_arrow, size: 18 * _scaleFactor),
            label: Text("Run", style: TextStyle(fontSize: 16 * _scaleFactor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: EdgeInsets.symmetric(
                horizontal: 24 * _scaleFactor,
                vertical: 16 * _scaleFactor,
              ),
            ),
          ),

          SizedBox(height: 10 * _scaleFactor),
          TextButton(
            onPressed: () {
              final musicService = Provider.of<MusicService>(context, listen: false);
              musicService.playSoundEffect('button_click.mp3');
              resetGame();
            },
            child: Text("🔁 Retry", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // UPDATED: Smaller puzzle blocks to fit more in the target area
  Widget puzzleBlock(String text, Color color) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 70 * _scaleFactor, // Smaller minimum width
        maxWidth: 160 * _scaleFactor, // Smaller maximum width
      ),
      margin: EdgeInsets.symmetric(horizontal: 2 * _scaleFactor),
      padding: EdgeInsets.symmetric(
        horizontal: 10 * _scaleFactor, // Reduced padding
        vertical: 8 * _scaleFactor, // Reduced padding
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15 * _scaleFactor),
          bottomRight: Radius.circular(15 * _scaleFactor),
        ),
        border: Border.all(color: Colors.black87, width: 1.5 * _scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 4 * _scaleFactor,
            offset: Offset(2 * _scaleFactor, 2 * _scaleFactor),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 10 * _scaleFactor, // Smaller font size
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        softWrap: true,
      ),
    );
  }
}

class BlockItem {
  final String text;
  final Key key;

  BlockItem(this.text, this.key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BlockItem &&
              runtimeType == other.runtimeType &&
              key == other.key;

  @override
  int get hashCode => key.hashCode;
}