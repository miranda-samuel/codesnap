import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../services/api_service.dart';
import '../../../services/user_preferences.dart';
import '../../../services/music_service.dart';
import '../../../services/daily_challenge_service.dart';

class SqlLevel1Hard extends StatefulWidget {
  const SqlLevel1Hard({super.key});

  @override
  State<SqlLevel1Hard> createState() => _SqlLevel1HardState();
}

class _SqlLevel1HardState extends State<SqlLevel1Hard> {
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
      'CREATE DATABASE company;',
      'USE company;',
      'CREATE TABLE employees (',
      'id INT PRIMARY KEY AUTO_INCREMENT,',
      'name VARCHAR(100) NOT NULL,',
      'department VARCHAR(50),',
      'salary DECIMAL(10,2),',
      'hire_date DATE',
      ');',
      'CREATE TABLE departments (',
      'dept_id INT PRIMARY KEY,',
      'dept_name VARCHAR(50) UNIQUE',
      ');',
      'INSERT INTO employees VALUES',
      '(1, "Juan Dela Cruz", "IT", 50000.00, "2023-01-15"),',
      '(2, "Maria Santos", "HR", 45000.00, "2022-06-20");',
      'INSERT INTO departments VALUES',
      '(101, "IT"),',
      '(102, "HR");',
      'ALTER TABLE employees',
      'ADD FOREIGN KEY (department)',
      'REFERENCES departments(dept_name);'
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
    return "HARD: Create a complete database schema with relationships!\n\nCorrect code uses:\n• CREATE DATABASE and USE statements\n• Multiple CREATE TABLE with proper constraints\n• PRIMARY KEY, FOREIGN KEY, AUTO_INCREMENT\n• Data types: INT, VARCHAR, DECIMAL, DATE\n• INSERT statements with sample data\n• ALTER TABLE to add foreign key relationship";
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
      'CREATE DATABASE company;',
      'USE company;',
      'CREATE TABLE employees (',
      'id INT PRIMARY KEY AUTO_INCREMENT,',
      'name VARCHAR(100) NOT NULL,',
      'department VARCHAR(50),',
      'salary DECIMAL(10,2),',
      'hire_date DATE',
      ');',
      'CREATE TABLE departments (',
      'dept_id INT PRIMARY KEY,',
      'dept_name VARCHAR(50) UNIQUE',
      ');',
      'INSERT INTO employees VALUES',
      '(1, "Juan Dela Cruz", "IT", 50000.00, "2023-01-15"),',
      '(2, "Maria Santos", "HR", 45000.00, "2022-06-20");',
      'INSERT INTO departments VALUES',
      '(101, "IT"),',
      '(102, "HR");',
      'ALTER TABLE employees',
      'ADD FOREIGN KEY (department)',
      'REFERENCES departments(dept_name);'
    ];

    List<String> incorrectBlocks = [
      'CREATE DATABASE company',
      'USE company',
      'CREATE TABLE employees',
      'id INT PRIMARY KEY',
      'name STRING NOT NULL',
      'department TEXT',
      'salary FLOAT',
      'hire_date DATETIME',
      'CREATE TABLE departments',
      'dept_id INTEGER PRIMARY',
      'dept_name VARCHAR(50)',
      'INSERT INTO employees',
      'VALUES (1, "Juan", "IT", 50000, "2023-01-15")',
      'INSERT departments VALUES',
      '(101, "IT")',
      'ALTER employees',
      'ADD FOREIGN KEY department',
      'REFERENCES departments dept_name',
      'CREATE DATABASE IF NOT EXISTS company;',
      'SELECT * FROM employees;',
      'UPDATE employees SET salary = 55000;'
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
        'SQL',
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

        print('Score saved successfully: $score for SQL Hard Level 1');
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
          'SQL',
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
          print('Loaded previous score: $previousScore for SQL Hard Level 1');
        }
      }
    } catch (e) {
      print('Error loading score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    List<String> incorrectBlocks = [
      'CREATE DATABASE company',
      'USE company',
      'CREATE TABLE employees',
      'id INT PRIMARY KEY',
      'name STRING NOT NULL',
      'department TEXT',
      'salary FLOAT',
      'hire_date DATETIME',
      'CREATE TABLE departments',
      'dept_id INTEGER PRIMARY',
      'dept_name VARCHAR(50)',
      'INSERT INTO employees',
      'VALUES (1, "Juan", "IT", 50000, "2023-01-15")',
      'INSERT departments VALUES',
      '(101, "IT")',
      'ALTER employees',
      'ADD FOREIGN KEY department',
      'REFERENCES departments dept_name',
      'CREATE DATABASE IF NOT EXISTS company;',
      'SELECT * FROM employees;',
      'UPDATE employees SET salary = 55000;'
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
            content: Text("❌ You used incorrect SQL syntax! -1 point. Current score: $score"),
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
            content: Text("You used incorrect SQL syntax and lost all points!"),
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

    bool hasCreateDatabase = normalizedAnswer.contains('createdatabasecompany;');
    bool hasUseDatabase = normalizedAnswer.contains('usecompany;');
    bool hasCreateEmployees = normalizedAnswer.contains('createtableemployees(');
    bool hasIdPrimary = normalizedAnswer.contains('idintprimarykeyauto_increment,');
    bool hasNameNotNull = normalizedAnswer.contains('namevarchar(100)notnull,');
    bool hasDepartment = normalizedAnswer.contains('departmentvarchar(50),');
    bool hasSalary = normalizedAnswer.contains('salarydecimal(10,2),');
    bool hasHireDate = normalizedAnswer.contains('hire_datedate');
    bool hasEmployeesClose = normalizedAnswer.contains(');');
    bool hasCreateDepartments = normalizedAnswer.contains('createtabledepartments(');
    bool hasDeptId = normalizedAnswer.contains('dept_idintprimarykey,');
    bool hasDeptNameUnique = normalizedAnswer.contains('dept_namevarchar(50)unique');
    bool hasDepartmentsClose = normalizedAnswer.contains(');');
    bool hasInsertEmployees = normalizedAnswer.contains('insertintoemployeesvalues');
    bool hasEmployee1 = normalizedAnswer.contains('(1,"juandelacruz","it",50000.00,"2023-01-15"),');
    bool hasEmployee2 = normalizedAnswer.contains('(2,"mariasantos","hr",45000.00,"2022-06-20");');
    bool hasInsertDepartments = normalizedAnswer.contains('insertintodepartmentsvalues');
    bool hasDept1 = normalizedAnswer.contains('(101,"it"),');
    bool hasDept2 = normalizedAnswer.contains('(102,"hr");');
    bool hasAlterTable = normalizedAnswer.contains('altertableemployees');
    bool hasAddForeignKey = normalizedAnswer.contains('addforeignkey(department)');
    bool hasReferences = normalizedAnswer.contains('referencesdepartments(dept_name);');

    if (hasCreateDatabase && hasUseDatabase && hasCreateEmployees && hasIdPrimary &&
        hasNameNotNull && hasDepartment && hasSalary && hasHireDate && hasEmployeesClose &&
        hasCreateDepartments && hasDeptId && hasDeptNameUnique && hasDepartmentsClose &&
        hasInsertEmployees && hasEmployee1 && hasEmployee2 && hasInsertDepartments &&
        hasDept1 && hasDept2 && hasAlterTable && hasAddForeignKey && hasReferences) {
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
              Text("Excellent! You built a complete database schema with relationships!"),
              SizedBox(height: 10),
              Text("Game Score: $gameScore/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              Text("Leaderboard Points: $leaderboardPoints/90", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 Perfect! You've mastered SQL Hard Level!",
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
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(
                  "🎯 Hard Difficulty: 30× Points Multiplier!",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("Database Schema Created:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("✓ Database: company", style: TextStyle(color: Colors.lightGreen, fontFamily: 'monospace')),
                    Text("✓ Table: employees (5 columns)", style: TextStyle(color: Colors.lightGreen, fontFamily: 'monospace')),
                    Text("✓ Table: departments (2 columns)", style: TextStyle(color: Colors.lightGreen, fontFamily: 'monospace')),
                    Text("✓ Foreign Key: employees.department → departments.dept_name", style: TextStyle(color: Colors.lightGreen, fontFamily: 'monospace')),
                    Text("✓ Sample data inserted for both tables", style: TextStyle(color: Colors.lightGreen, fontFamily: 'monospace')),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "💎 Advanced Features: Database creation, table relationships, constraints, data insertion!",
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
                  Navigator.pushReplacementNamed(context, '/sql_level2_hard');
                } else {
                  Navigator.pushReplacementNamed(context, '/levels',
                      arguments: {'language': 'SQL', 'difficulty': 'hard'});
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
          SnackBar(content: Text("❌ Incomplete database schema. -1 point. Current score: $score")),
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
            content: Text("Remember to build the complete database schema with tables, relationships, and sample data."),
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
          color: Colors.orange.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12 * _scaleFactor),
          border: Border.all(color: Colors.orangeAccent, width: 2 * _scaleFactor),
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
                Icon(Icons.storage, color: Colors.grey[400], size: 16 * _scaleFactor),
                SizedBox(width: 8 * _scaleFactor),
                Text(
                  'database_schema.sql',
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
            '-- Drag blocks to build your database schema',
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
      bool isCreate = block.contains('CREATE');
      bool isUse = block.contains('USE');
      bool isInsert = block.contains('INSERT');
      bool isAlter = block.contains('ALTER');
      bool isDataType = block.contains('INT') || block.contains('VARCHAR') || block.contains('DECIMAL') || block.contains('DATE');
      bool isConstraint = block.contains('PRIMARY') || block.contains('FOREIGN') || block.contains('UNIQUE') || block.contains('NOT NULL');
      bool isIncorrect = isIncorrectBlock(block);

      Color textColor = Colors.white;
      if (isCreate) {
        textColor = Color(0xFF569CD6);
      } else if (isUse) {
        textColor = Color(0xFFDCDCAA);
      } else if (isInsert) {
        textColor = Color(0xFFCE9178);
      } else if (isAlter) {
        textColor = Color(0xFFC586C0);
      } else if (isDataType) {
        textColor = Color(0xFF4EC9B0);
      } else if (isConstraint) {
        textColor = Color(0xFFDCDCAA);
      } else if (isIncorrect) {
        textColor = Colors.red;
      }

      String displayCode = block;

      codeLines.add(_buildCodeLineWithNumber(lineNumber++, displayCode,
          textColor: textColor,
          isIncorrect: isIncorrect
      ));

      // Add spacing between major statements
      if (block == ');' || block.contains(';') && !block.contains(',')) {
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
        title: Text("⚡ SQL - Level 1 (Hard)", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.orange,
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
              Color(0xFF2D1B00),
              Color(0xFF3B2600),
              Color(0xFF5A3A00),
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
                      color: _availableHintCards > 0 ? Colors.orange : Colors.grey,
                      borderRadius: BorderRadius.circular(20 * _scaleFactor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4 * _scaleFactor,
                          offset: Offset(0, 2 * _scaleFactor),
                        )
                      ],
                      border: Border.all(
                        color: _availableHintCards > 0 ? Colors.orangeAccent : Colors.grey,
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
                backgroundColor: Colors.orange,
              ),
            ),
            SizedBox(height: 20 * _scaleFactor),

            Container(
              padding: EdgeInsets.all(12 * _scaleFactor),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20 * _scaleFactor),
                  SizedBox(width: 8 * _scaleFactor),
                  Text(
                    'Hint Cards: $_availableHintCards',
                    style: TextStyle(
                      color: Colors.orange,
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
                color: Colors.orange[50]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12 * _scaleFactor),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    "🎯 Hard Level Objective",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "Build a complete database schema with multiple tables, relationships, and sample data using all 13 blocks",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.orange[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Container(
                    padding: EdgeInsets.all(8 * _scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8 * _scaleFactor),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      "🎁 Hard Difficulty: 30× Points Multiplier!",
                      style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        color: Colors.orange[800],
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
                ? 'Ang Company XYZ ay nangangailangan ng bagong database system para sa kanilang employees! Kailangan mong gumawa ng database schema na may relationships between employees at departments. Tulungan silang buuin ang complete database!'
                : 'Company XYZ needs a new database system for their employees! You need to create a database schema with relationships between employees and departments. Help them build the complete database!',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text('🧩 Build the complete database schema with relationships using all 13 blocks',
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
              border: Border.all(color: Colors.orange, width: 2.5 * _scaleFactor),
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
                          child: puzzleBlock(blockItem.text, Colors.orangeAccent),
                        ),
                        childWhenDragging: puzzleBlock(blockItem.text, Colors.orangeAccent.withOpacity(0.5)),
                        child: puzzleBlock(blockItem.text, Colors.orangeAccent),
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
          Text('💻 SQL Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
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
            label: Text("Execute", style: TextStyle(fontSize: 16 * _scaleFactor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
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