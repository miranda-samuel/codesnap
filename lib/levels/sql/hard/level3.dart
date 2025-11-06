import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import '../../../../services/api_service.dart';
import '../../../../services/user_preferences.dart';
import '../../../../services/music_service.dart';
import '../../../../services/daily_challenge_service.dart';

class SqlLevel3Hard extends StatefulWidget {
  const SqlLevel3Hard({super.key});

  @override
  State<SqlLevel3Hard> createState() => _SqlLevel3HardState();
}

class _SqlLevel3HardState extends State<SqlLevel3Hard> {
  List<String> allBlocks = [];
  List<String> droppedBlocks = [];
  bool gameStarted = false;
  bool isTagalog = false;
  bool isAnsweredCorrectly = false;
  bool levelCompleted = false;
  bool hasPreviousScore = false;
  int previousScore = 0;

  int score = 3;
  int remainingSeconds = 360; // 6 minutes for expert level
  Timer? countdownTimer;
  Timer? scoreReductionTimer;
  Map<String, dynamic>? currentUser;

  String? currentlyDraggedBlock;
  double _scaleFactor = 1.0;
  final double _baseScreenWidth = 360.0;

  Map<String, dynamic>? gameConfig;
  bool isLoading = true;
  String? errorMessage;

  int _availableHintCards = 0;
  bool _showHint = false;
  String _currentHint = '';
  bool _isUsingHint = false;

  String _codePreviewTitle = '💻 SQL Grand Master Query Preview:';
  String _instructionText = '🧩 Arrange the blocks to form an expert-level SQL query with recursive CTEs, advanced window functions, and complex analytics';
  List<String> _codeStructure = [];
  String _expectedOutput = '';

  // Database tables preview for Grand Master level
  List<Map<String, dynamic>> _employeesTable = [];
  List<Map<String, dynamic>> _departmentsTable = [];
  List<Map<String, dynamic>> _projectsTable = [];
  List<Map<String, dynamic>> _salariesTable = [];
  List<Map<String, dynamic>> _employeeHierarchyTable = [];
  List<Map<String, dynamic>> _projectAssignmentsTable = [];

  String _employeesTableName = 'employees';
  String _departmentsTableName = 'departments';
  String _projectsTableName = 'projects';
  String _salariesTableName = 'salaries';
  String _employeeHierarchyTableName = 'employee_hierarchy';
  String _projectAssignmentsTableName = 'project_assignments';

  @override
  void initState() {
    super.initState();
    _loadGameConfig();
    _loadUserData();
    _calculateScaleFactor();
    _startGameMusic();
    _loadHintCards();
  }

  Future<void> _loadGameConfig() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await ApiService.getGameConfigWithDifficulty('SQL', 'Hard', 3);

      print('🔍 SQL HARD LEVEL 3 GAME CONFIG RESPONSE:');
      print('   Success: ${response['success']}');
      print('   Message: ${response['message']}');

      if (response['success'] == true && response['game'] != null) {
        setState(() {
          gameConfig = response['game'];
          _initializeGameFromConfig();
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load SQL Hard Level 3 game configuration from database';
        });
      }
    } catch (e) {
      print('❌ Error loading SQL Hard Level 3 game config: $e');
      setState(() {
        errorMessage = 'Connection error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeGameFromConfig() {
    if (gameConfig == null) return;

    try {
      print('🔄 INITIALIZING SQL HARD LEVEL 3 GAME FROM CONFIG');

      // Load timer duration from database
      if (gameConfig!['timer_duration'] != null) {
        int timerDuration = int.tryParse(gameConfig!['timer_duration'].toString()) ?? 360;
        setState(() {
          remainingSeconds = timerDuration;
        });
        print('⏰ Timer duration loaded: $timerDuration seconds');
      }

      // Load instruction text from database
      if (gameConfig!['instruction_text'] != null) {
        setState(() {
          _instructionText = gameConfig!['instruction_text'].toString();
        });
        print('📝 Instruction text loaded: $_instructionText');
      }

      // Load code preview title from database
      if (gameConfig!['code_preview_title'] != null) {
        setState(() {
          _codePreviewTitle = gameConfig!['code_preview_title'].toString();
        });
        print('💻 Code preview title loaded: $_codePreviewTitle');
      }

      // Load code structure from database
      if (gameConfig!['code_structure'] != null) {
        if (gameConfig!['code_structure'] is List) {
          setState(() {
            _codeStructure = List<String>.from(gameConfig!['code_structure']);
          });
        } else {
          String codeStructureStr = gameConfig!['code_structure']?.toString() ?? '[]';
          try {
            List<dynamic> codeStructureJson = json.decode(codeStructureStr);
            setState(() {
              _codeStructure = List<String>.from(codeStructureJson);
            });
          } catch (e) {
            print('❌ Error parsing SQL Hard Level 3 code structure: $e');
            setState(() {
              _codeStructure = _getDefaultCodeStructure();
            });
          }
        }
        print('📝 SQL Hard Level 3 code structure loaded: $_codeStructure');
      } else {
        setState(() {
          _codeStructure = _getDefaultCodeStructure();
        });
      }

      // Load expected output from database
      if (gameConfig!['expected_output'] != null) {
        setState(() {
          _expectedOutput = gameConfig!['expected_output'].toString();
        });
        print('🎯 Expected output loaded: $_expectedOutput');
      }

      // Load table data from database
      _initializeTableData();

      // Load hint from database
      if (gameConfig!['hint_text'] != null) {
        setState(() {
          _currentHint = gameConfig!['hint_text'].toString();
        });
        print('💡 SQL Hard Level 3 hint loaded from database: $_currentHint');
      } else {
        setState(() {
          _currentHint = _getDefaultHint();
        });
        print('💡 Using default SQL Hard Level 3 hint');
      }

      // Parse blocks with better error handling
      List<String> correctBlocks = _parseBlocks(gameConfig!['correct_blocks'], 'correct');
      List<String> incorrectBlocks = _parseBlocks(gameConfig!['incorrect_blocks'], 'incorrect');

      print('✅ SQL Hard Level 3 Correct Blocks from DB: $correctBlocks');
      print('✅ SQL Hard Level 3 Incorrect Blocks from DB: $incorrectBlocks');

      // Combine and shuffle blocks
      allBlocks = [
        ...correctBlocks,
        ...incorrectBlocks,
      ]..shuffle();

      print('🎮 SQL Hard Level 3 All Blocks Final: $allBlocks');

      // DEBUG: Print the expected correct answer from database
      if (gameConfig!['correct_answer'] != null) {
        print('🎯 SQL Hard Level 3 Expected Correct Answer from DB: ${gameConfig!['correct_answer']}');
      }

    } catch (e) {
      print('❌ Error parsing SQL Hard Level 3 game config: $e');
      _initializeDefaultBlocks();
    }
  }

  void _initializeTableData() {
    // Load employees table data
    if (gameConfig!['employees_table_data'] != null) {
      try {
        String tableDataStr = gameConfig!['employees_table_data'].toString();
        List<dynamic> tableDataJson = json.decode(tableDataStr);
        setState(() {
          _employeesTable = List<Map<String, dynamic>>.from(tableDataJson);
        });
        print('📊 Employees table data loaded: ${_employeesTable.length} rows');
      } catch (e) {
        print('❌ Error parsing employees table data: $e');
        setState(() {
          _employeesTable = _getDefaultEmployeesTable();
        });
      }
    } else {
      setState(() {
        _employeesTable = _getDefaultEmployeesTable();
      });
    }

    // Load departments table data
    if (gameConfig!['departments_table_data'] != null) {
      try {
        String tableDataStr = gameConfig!['departments_table_data'].toString();
        List<dynamic> tableDataJson = json.decode(tableDataStr);
        setState(() {
          _departmentsTable = List<Map<String, dynamic>>.from(tableDataJson);
        });
        print('📊 Departments table data loaded: ${_departmentsTable.length} rows');
      } catch (e) {
        print('❌ Error parsing departments table data: $e');
        setState(() {
          _departmentsTable = _getDefaultDepartmentsTable();
        });
      }
    } else {
      setState(() {
        _departmentsTable = _getDefaultDepartmentsTable();
      });
    }

    // Load projects table data
    if (gameConfig!['projects_table_data'] != null) {
      try {
        String tableDataStr = gameConfig!['projects_table_data'].toString();
        List<dynamic> tableDataJson = json.decode(tableDataStr);
        setState(() {
          _projectsTable = List<Map<String, dynamic>>.from(tableDataJson);
        });
        print('📊 Projects table data loaded: ${_projectsTable.length} rows');
      } catch (e) {
        print('❌ Error parsing projects table data: $e');
        setState(() {
          _projectsTable = _getDefaultProjectsTable();
        });
      }
    } else {
      setState(() {
        _projectsTable = _getDefaultProjectsTable();
      });
    }

    // Load salaries table data
    if (gameConfig!['salaries_table_data'] != null) {
      try {
        String tableDataStr = gameConfig!['salaries_table_data'].toString();
        List<dynamic> tableDataJson = json.decode(tableDataStr);
        setState(() {
          _salariesTable = List<Map<String, dynamic>>.from(tableDataJson);
        });
        print('📊 Salaries table data loaded: ${_salariesTable.length} rows');
      } catch (e) {
        print('❌ Error parsing salaries table data: $e');
        setState(() {
          _salariesTable = _getDefaultSalariesTable();
        });
      }
    } else {
      setState(() {
        _salariesTable = _getDefaultSalariesTable();
      });
    }

    // Load employee hierarchy table data
    if (gameConfig!['employee_hierarchy_table_data'] != null) {
      try {
        String tableDataStr = gameConfig!['employee_hierarchy_table_data'].toString();
        List<dynamic> tableDataJson = json.decode(tableDataStr);
        setState(() {
          _employeeHierarchyTable = List<Map<String, dynamic>>.from(tableDataJson);
        });
        print('📊 Employee hierarchy table data loaded: ${_employeeHierarchyTable.length} rows');
      } catch (e) {
        print('❌ Error parsing employee hierarchy table data: $e');
        setState(() {
          _employeeHierarchyTable = _getDefaultEmployeeHierarchyTable();
        });
      }
    } else {
      setState(() {
        _employeeHierarchyTable = _getDefaultEmployeeHierarchyTable();
      });
    }

    // Load project assignments table data
    if (gameConfig!['project_assignments_table_data'] != null) {
      try {
        String tableDataStr = gameConfig!['project_assignments_table_data'].toString();
        List<dynamic> tableDataJson = json.decode(tableDataStr);
        setState(() {
          _projectAssignmentsTable = List<Map<String, dynamic>>.from(tableDataJson);
        });
        print('📊 Project assignments table data loaded: ${_projectAssignmentsTable.length} rows');
      } catch (e) {
        print('❌ Error parsing project assignments table data: $e');
        setState(() {
          _projectAssignmentsTable = _getDefaultProjectAssignmentsTable();
        });
      }
    } else {
      setState(() {
        _projectAssignmentsTable = _getDefaultProjectAssignmentsTable();
      });
    }

    // Load table names
    if (gameConfig!['employees_table_name'] != null) {
      setState(() {
        _employeesTableName = gameConfig!['employees_table_name'].toString();
      });
    }
    if (gameConfig!['departments_table_name'] != null) {
      setState(() {
        _departmentsTableName = gameConfig!['departments_table_name'].toString();
      });
    }
    if (gameConfig!['projects_table_name'] != null) {
      setState(() {
        _projectsTableName = gameConfig!['projects_table_name'].toString();
      });
    }
    if (gameConfig!['salaries_table_name'] != null) {
      setState(() {
        _salariesTableName = gameConfig!['salaries_table_name'].toString();
      });
    }
    if (gameConfig!['employee_hierarchy_table_name'] != null) {
      setState(() {
        _employeeHierarchyTableName = gameConfig!['employee_hierarchy_table_name'].toString();
      });
    }
    if (gameConfig!['project_assignments_table_name'] != null) {
      setState(() {
        _projectAssignmentsTableName = gameConfig!['project_assignments_table_name'].toString();
      });
    }
  }

  List<String> _getDefaultCodeStructure() {
    return [
      "-- SQL Grand Master Challenge: Advanced Organizational Analytics",
      "-- Complete the recursive CTE query below to analyze employee hierarchy and performance",
      "",
      "WITH RECURSIVE EmployeeHierarchy AS (",
      "  -- Anchor: Find top-level managers (no manager)",
      "  SELECT e.employee_id,",
      "         e.name,",
      "         e.position,",
      "         d.department_name,",
      "         eh.manager_id,",
      "         0 as hierarchy_level,",
      "         CAST(e.name AS VARCHAR(255)) as hierarchy_path",
      "  FROM employees e",
      "  JOIN employee_hierarchy eh ON e.employee_id = eh.employee_id",
      "  JOIN departments d ON e.department_id = d.department_id",
      "  WHERE eh.manager_id IS NULL",
      "",
      "  UNION ALL",
      "",
      "  -- Recursive: Find subordinates for each manager",
      "  SELECT e.employee_id,",
      "         e.name,",
      "         e.position,",
      "         d.department_name,",
      "         eh.manager_id,",
      "         eh_parent.hierarchy_level + 1,",
      "         CAST(eh_parent.hierarchy_path || ' -> ' || e.name AS VARCHAR(255))",
      "  FROM employees e",
      "  JOIN employee_hierarchy eh ON e.employee_id = eh.employee_id",
      "  JOIN departments d ON e.department_id = d.department_id",
      "  JOIN EmployeeHierarchy eh_parent ON eh.manager_id = eh_parent.employee_id",
      "),",
      "",
      "DepartmentPerformance AS (",
      "  SELECT d.department_id,",
      "         d.department_name,",
      "         COUNT(DISTINCT e.employee_id) as total_employees,",
      "         AVG(s.salary_amount) as avg_salary,",
      "         COUNT(DISTINCT p.project_id) as total_projects,",
      "         SUM(p.budget) as total_budget,",
      "         COUNT(DISTINCT pa.assignment_id) as total_assignments",
      "  FROM departments d",
      "  LEFT JOIN employees e ON d.department_id = e.department_id",
      "  LEFT JOIN salaries s ON e.employee_id = s.employee_id",
      "  LEFT JOIN projects p ON d.department_id = p.department_id",
      "  LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id",
      "  GROUP BY d.department_id, d.department_name",
      "),",
      "",
      "EmployeePerformance AS (",
      "  SELECT e.employee_id,",
      "         e.name,",
      "         d.department_name,",
      "         s.salary_amount,",
      "         COUNT(pa.assignment_id) as project_count,",
      "         AVG(COUNT(pa.assignment_id)) OVER (PARTITION BY d.department_id) as dept_avg_projects,",
      "         RANK() OVER (PARTITION BY d.department_id ORDER BY s.salary_amount DESC) as salary_rank_in_dept,",
      "         PERCENT_RANK() OVER (PARTITION BY d.department_id ORDER BY s.salary_amount) as salary_percentile",
      "  FROM employees e",
      "  JOIN departments d ON e.department_id = d.department_id",
      "  LEFT JOIN salaries s ON e.employee_id = s.employee_id",
      "  LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id",
      "  GROUP BY e.employee_id, e.name, d.department_name, s.salary_amount, d.department_id",
      ")",
      "",
      "SELECT eh.hierarchy_level,",
      "       eh.name as employee_name,",
      "       eh.position,",
      "       eh.department_name,",
      "       eh.hierarchy_path,",
      "       ep.salary_amount,",
      "       ep.project_count,",
      "       ep.salary_rank_in_dept,",
      "       ROUND(ep.salary_percentile * 100, 2) as salary_percentile",
      "FROM EmployeeHierarchy eh",
      "LEFT JOIN EmployeePerformance ep ON eh.employee_id = ep.employee_id",
      "WHERE eh.hierarchy_level <= 3",
      "ORDER BY eh.hierarchy_level, eh.hierarchy_path;"
    ];
  }

  List<Map<String, dynamic>> _getDefaultEmployeesTable() {
    return [
      {'employee_id': 1, 'name': 'Maria Santos', 'department_id': 1, 'position': 'CEO'},
      {'employee_id': 2, 'name': 'Juan Dela Cruz', 'department_id': 1, 'position': 'CTO'},
      {'employee_id': 3, 'name': 'Ana Lopez', 'department_id': 2, 'position': 'HR Director'},
      {'employee_id': 4, 'name': 'Pedro Reyes', 'department_id': 3, 'position': 'Sales Director'},
      {'employee_id': 5, 'name': 'Luis Garcia', 'department_id': 1, 'position': 'Senior Developer'},
      {'employee_id': 6, 'name': 'Sofia Martinez', 'department_id': 2, 'position': 'HR Manager'},
      {'employee_id': 7, 'name': 'Carlos Lim', 'department_id': 3, 'position': 'Sales Manager'},
      {'employee_id': 8, 'name': 'Elena Torres', 'department_id': 1, 'position': 'Junior Developer'},
      {'employee_id': 9, 'name': 'Miguel Ramos', 'department_id': 2, 'position': 'Recruitment Specialist'},
      {'employee_id': 10, 'name': 'Isabel Chen', 'department_id': 3, 'position': 'Sales Executive'},
    ];
  }

  List<Map<String, dynamic>> _getDefaultDepartmentsTable() {
    return [
      {'department_id': 1, 'department_name': 'Executive'},
      {'department_id': 2, 'department_name': 'HR'},
      {'department_id': 3, 'department_name': 'Sales'},
      {'department_id': 4, 'department_name': 'IT'},
    ];
  }

  List<Map<String, dynamic>> _getDefaultProjectsTable() {
    return [
      {'project_id': 1, 'project_name': 'Digital Transformation', 'department_id': 1, 'budget': 2000000},
      {'project_id': 2, 'project_name': 'Mobile App Development', 'department_id': 4, 'budget': 1500000},
      {'project_id': 3, 'project_name': 'Sales Training Program', 'department_id': 3, 'budget': 500000},
      {'project_id': 4, 'project_name': 'HR System Upgrade', 'department_id': 2, 'budget': 800000},
      {'project_id': 5, 'project_name': 'Market Expansion', 'department_id': 3, 'budget': 1200000},
      {'project_id': 6, 'project_name': 'Cloud Migration', 'department_id': 4, 'budget': 1800000},
    ];
  }

  List<Map<String, dynamic>> _getDefaultSalariesTable() {
    return [
      {'salary_id': 1, 'employee_id': 1, 'salary_amount': 250000},
      {'salary_id': 2, 'employee_id': 2, 'salary_amount': 200000},
      {'salary_id': 3, 'employee_id': 3, 'salary_amount': 150000},
      {'salary_id': 4, 'employee_id': 4, 'salary_amount': 140000},
      {'salary_id': 5, 'employee_id': 5, 'salary_amount': 120000},
      {'salary_id': 6, 'employee_id': 6, 'salary_amount': 90000},
      {'salary_id': 7, 'employee_id': 7, 'salary_amount': 95000},
      {'salary_id': 8, 'employee_id': 8, 'salary_amount': 60000},
      {'salary_id': 9, 'employee_id': 9, 'salary_amount': 65000},
      {'salary_id': 10, 'employee_id': 10, 'salary_amount': 70000},
    ];
  }

  List<Map<String, dynamic>> _getDefaultEmployeeHierarchyTable() {
    return [
      {'hierarchy_id': 1, 'employee_id': 1, 'manager_id': null},
      {'hierarchy_id': 2, 'employee_id': 2, 'manager_id': 1},
      {'hierarchy_id': 3, 'employee_id': 3, 'manager_id': 1},
      {'hierarchy_id': 4, 'employee_id': 4, 'manager_id': 1},
      {'hierarchy_id': 5, 'employee_id': 5, 'manager_id': 2},
      {'hierarchy_id': 6, 'employee_id': 6, 'manager_id': 3},
      {'hierarchy_id': 7, 'employee_id': 7, 'manager_id': 4},
      {'hierarchy_id': 8, 'employee_id': 8, 'manager_id': 5},
      {'hierarchy_id': 9, 'employee_id': 9, 'manager_id': 6},
      {'hierarchy_id': 10, 'employee_id': 10, 'manager_id': 7},
    ];
  }

  List<Map<String, dynamic>> _getDefaultProjectAssignmentsTable() {
    return [
      {'assignment_id': 1, 'employee_id': 1, 'project_id': 1, 'role': 'Project Sponsor'},
      {'assignment_id': 2, 'employee_id': 2, 'project_id': 1, 'role': 'Technical Lead'},
      {'assignment_id': 3, 'employee_id': 2, 'project_id': 2, 'role': 'Project Manager'},
      {'assignment_id': 4, 'employee_id': 3, 'project_id': 4, 'role': 'HR Lead'},
      {'assignment_id': 5, 'employee_id': 4, 'project_id': 3, 'role': 'Sales Lead'},
      {'assignment_id': 6, 'employee_id': 4, 'project_id': 5, 'role': 'Strategy Lead'},
      {'assignment_id': 7, 'employee_id': 5, 'project_id': 2, 'role': 'Lead Developer'},
      {'assignment_id': 8, 'employee_id': 5, 'project_id': 6, 'role': 'Cloud Architect'},
      {'assignment_id': 9, 'employee_id': 6, 'project_id': 4, 'role': 'HR Analyst'},
      {'assignment_id': 10, 'employee_id': 7, 'project_id': 3, 'role': 'Trainer'},
      {'assignment_id': 11, 'employee_id': 7, 'project_id': 5, 'role': 'Sales Analyst'},
      {'assignment_id': 12, 'employee_id': 8, 'project_id': 2, 'role': 'Developer'},
      {'assignment_id': 13, 'employee_id': 8, 'project_id': 6, 'role': 'Support'},
      {'assignment_id': 14, 'employee_id': 9, 'project_id': 4, 'role': 'Recruiter'},
      {'assignment_id': 15, 'employee_id': 10, 'project_id': 3, 'role': 'Assistant'},
      {'assignment_id': 16, 'employee_id': 10, 'project_id': 5, 'role': 'Researcher'},
    ];
  }

  List<String> _parseBlocks(dynamic blocksData, String type) {
    List<String> blocks = [];

    if (blocksData == null) {
      print('⚠️ SQL Hard Level 3 $type blocks are NULL in database');
      return _getDefaultBlocks(type);
    }

    try {
      if (blocksData is List) {
        blocks = List<String>.from(blocksData);
        print('✅ SQL Hard Level 3 $type blocks parsed as List: $blocks');
      } else if (blocksData is String) {
        String blocksStr = blocksData.trim();
        print('🔍 Raw SQL Hard Level 3 $type blocks string: $blocksStr');

        if (blocksStr.startsWith('[') && blocksStr.endsWith(']')) {
          // Parse as JSON array
          try {
            List<dynamic> blocksJson = json.decode(blocksStr);
            blocks = List<String>.from(blocksJson);
            print('✅ SQL Hard Level 3 $type blocks parsed as JSON: $blocks');
          } catch (e) {
            print('❌ JSON parsing failed for SQL Hard Level 3 $type blocks: $e');
            blocks = _parseCommaSeparated(blocksStr);
          }
        } else {
          // Parse as comma-separated string
          blocks = _parseCommaSeparated(blocksStr);
        }
      }
    } catch (e) {
      print('❌ Error parsing SQL Hard Level 3 $type blocks: $e');
      blocks = _getDefaultBlocks(type);
    }

    // Remove any empty strings
    blocks = blocks.where((block) => block.trim().isNotEmpty).toList();

    print('🎯 Final SQL Hard Level 3 $type blocks: $blocks');
    return blocks;
  }

  List<String> _parseCommaSeparated(String input) {
    try {
      String cleaned = input.replaceAll('[', '').replaceAll(']', '').trim();
      List<String> items = [];
      StringBuffer current = StringBuffer();
      bool inQuotes = false;

      for (int i = 0; i < cleaned.length; i++) {
        String char = cleaned[i];

        if (char == '"') {
          inQuotes = !inQuotes;
          current.write(char);
        } else if (char == ',' && !inQuotes) {
          String item = current.toString().trim();
          if (item.isNotEmpty) {
            if (item.startsWith('"') && item.endsWith('"')) {
              item = item.substring(1, item.length - 1);
            }
            items.add(item);
          }
          current.clear();
        } else {
          current.write(char);
        }
      }

      String lastItem = current.toString().trim();
      if (lastItem.isNotEmpty) {
        if (lastItem.startsWith('"') && lastItem.endsWith('"')) {
          lastItem = lastItem.substring(1, lastItem.length - 1);
        }
        items.add(lastItem);
      }

      print('✅ SQL Hard Level 3 Comma-separated parsing result: $items');
      return items;
    } catch (e) {
      print('❌ SQL Hard Level 3 Comma-separated parsing failed: $e');
      List<String> fallback = input.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
      print('🔄 Using simple split fallback: $fallback');
      return fallback;
    }
  }

  List<String> _getDefaultBlocks(String type) {
    if (type == 'correct') {
      return [
        'WITH RECURSIVE EmployeeHierarchy AS (',
        'SELECT e.employee_id,',
        'e.name,',
        'e.position,',
        'd.department_name,',
        'eh.manager_id,',
        '0 as hierarchy_level,',
        'CAST(e.name AS VARCHAR(255)) as hierarchy_path',
        'FROM employees e',
        'JOIN employee_hierarchy eh ON e.employee_id = eh.employee_id',
        'JOIN departments d ON e.department_id = d.department_id',
        'WHERE eh.manager_id IS NULL',
        'UNION ALL',
        'SELECT e.employee_id,',
        'e.name,',
        'e.position,',
        'd.department_name,',
        'eh.manager_id,',
        'eh_parent.hierarchy_level + 1,',
        'CAST(eh_parent.hierarchy_path || \' -> \' || e.name AS VARCHAR(255))',
        'FROM employees e',
        'JOIN employee_hierarchy eh ON e.employee_id = eh.employee_id',
        'JOIN departments d ON e.department_id = d.department_id',
        'JOIN EmployeeHierarchy eh_parent ON eh.manager_id = eh_parent.employee_id',
        '),',
        'DepartmentPerformance AS (',
        'SELECT d.department_id,',
        'd.department_name,',
        'COUNT(DISTINCT e.employee_id) as total_employees,',
        'AVG(s.salary_amount) as avg_salary,',
        'COUNT(DISTINCT p.project_id) as total_projects,',
        'SUM(p.budget) as total_budget,',
        'COUNT(DISTINCT pa.assignment_id) as total_assignments',
        'FROM departments d',
        'LEFT JOIN employees e ON d.department_id = e.department_id',
        'LEFT JOIN salaries s ON e.employee_id = s.employee_id',
        'LEFT JOIN projects p ON d.department_id = p.department_id',
        'LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id',
        'GROUP BY d.department_id, d.department_name',
        '),',
        'EmployeePerformance AS (',
        'SELECT e.employee_id,',
        'e.name,',
        'd.department_name,',
        's.salary_amount,',
        'COUNT(pa.assignment_id) as project_count,',
        'AVG(COUNT(pa.assignment_id)) OVER (PARTITION BY d.department_id) as dept_avg_projects,',
        'RANK() OVER (PARTITION BY d.department_id ORDER BY s.salary_amount DESC) as salary_rank_in_dept,',
        'PERCENT_RANK() OVER (PARTITION BY d.department_id ORDER BY s.salary_amount) as salary_percentile',
        'FROM employees e',
        'JOIN departments d ON e.department_id = d.department_id',
        'LEFT JOIN salaries s ON e.employee_id = s.employee_id',
        'LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id',
        'GROUP BY e.employee_id, e.name, d.department_name, s.salary_amount, d.department_id',
        ')',
        'SELECT eh.hierarchy_level,',
        'eh.name as employee_name,',
        'eh.position,',
        'eh.department_name,',
        'eh.hierarchy_path,',
        'ep.salary_amount,',
        'ep.project_count,',
        'ep.salary_rank_in_dept,',
        'ROUND(ep.salary_percentile * 100, 2) as salary_percentile',
        'FROM EmployeeHierarchy eh',
        'LEFT JOIN EmployeePerformance ep ON eh.employee_id = ep.employee_id',
        'WHERE eh.hierarchy_level <= 3',
        'ORDER BY eh.hierarchy_level, eh.hierarchy_path;'
      ];
    } else {
      return [
        'WITH EmployeeData AS (',
        'SELECT * FROM employees',
        'WHERE salary > 100000',
        'GROUP BY department',
        'HAVING COUNT(*) > 5',
        'ORDER BY salary DESC',
        'LIMIT 10',
        'UNION ALL',
        'SELECT name, position, salary',
        'FROM managers',
        'INNER JOIN departments ON managers.dept_id = departments.id',
        'CROSS JOIN projects',
        'NATURAL JOIN salaries',
        'FULL OUTER JOIN employee_history',
        'USING (employee_id)',
        'WINDOW w AS (PARTITION BY department ORDER BY salary)',
        'LAG(salary) OVER w as prev_salary',
        'LEAD(salary) OVER w as next_salary',
        'FIRST_VALUE(salary) OVER w as first_salary',
        'LAST_VALUE(salary) OVER w as last_salary',
        'NTILE(4) OVER w as salary_quartile',
        'CUME_DIST() OVER w as cumulative_dist',
        'ROLLUP(department, position)',
        'CUBE(region, department)',
        'GROUPING SETS ((department), (position), ())'
      ];
    }
  }

  String _getDefaultHint() {
    return "💡 SQL Grand Master Hint: Use RECURSIVE CTE for hierarchical data, multiple window functions (RANK, PERCENT_RANK) for analytics, complex JOINs across 6+ tables, and advanced aggregation with PARTITION BY.";
  }

  void _initializeDefaultBlocks() {
    allBlocks = [
      'WITH RECURSIVE EmployeeHierarchy AS (',
      'SELECT e.employee_id,',
      'e.name,',
      'e.position,',
      'd.department_name,',
      'eh.manager_id,',
      '0 as hierarchy_level,',
      'CAST(e.name AS VARCHAR(255)) as hierarchy_path',
      'FROM employees e',
      'JOIN employee_hierarchy eh ON e.employee_id = eh.employee_id',
      'JOIN departments d ON e.department_id = d.department_id',
      'WHERE eh.manager_id IS NULL',
      'UNION ALL',
      'SELECT e.employee_id,',
      'e.name,',
      'e.position,',
      'd.department_name,',
      'eh.manager_id,',
      'eh_parent.hierarchy_level + 1,',
      'CAST(eh_parent.hierarchy_path || \' -> \' || e.name AS VARCHAR(255))',
      'FROM employees e',
      'JOIN employee_hierarchy eh ON e.employee_id = eh.employee_id',
      'JOIN departments d ON e.department_id = d.department_id',
      'JOIN EmployeeHierarchy eh_parent ON eh.manager_id = eh_parent.employee_id',
      '),',
      'DepartmentPerformance AS (',
      'SELECT d.department_id,',
      'd.department_name,',
      'COUNT(DISTINCT e.employee_id) as total_employees,',
      'AVG(s.salary_amount) as avg_salary,',
      'COUNT(DISTINCT p.project_id) as total_projects,',
      'SUM(p.budget) as total_budget,',
      'COUNT(DISTINCT pa.assignment_id) as total_assignments',
      'FROM departments d',
      'LEFT JOIN employees e ON d.department_id = e.department_id',
      'LEFT JOIN salaries s ON e.employee_id = s.employee_id',
      'LEFT JOIN projects p ON d.department_id = p.department_id',
      'LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id',
      'GROUP BY d.department_id, d.department_name',
      '),',
      'EmployeePerformance AS (',
      'SELECT e.employee_id,',
      'e.name,',
      'd.department_name,',
      's.salary_amount,',
      'COUNT(pa.assignment_id) as project_count,',
      'AVG(COUNT(pa.assignment_id)) OVER (PARTITION BY d.department_id) as dept_avg_projects,',
      'RANK() OVER (PARTITION BY d.department_id ORDER BY s.salary_amount DESC) as salary_rank_in_dept,',
      'PERCENT_RANK() OVER (PARTITION BY d.department_id ORDER BY s.salary_amount) as salary_percentile',
      'FROM employees e',
      'JOIN departments d ON e.department_id = d.department_id',
      'LEFT JOIN salaries s ON e.employee_id = s.employee_id',
      'LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id',
      'GROUP BY e.employee_id, e.name, d.department_name, s.salary_amount, d.department_id',
      ')',
      'SELECT eh.hierarchy_level,',
      'eh.name as employee_name,',
      'eh.position,',
      'eh.department_name,',
      'eh.hierarchy_path,',
      'ep.salary_amount,',
      'ep.project_count,',
      'ep.salary_rank_in_dept,',
      'ROUND(ep.salary_percentile * 100, 2) as salary_percentile',
      'FROM EmployeeHierarchy eh',
      'LEFT JOIN EmployeePerformance ep ON eh.employee_id = ep.employee_id',
      'WHERE eh.hierarchy_level <= 3',
      'ORDER BY eh.hierarchy_level, eh.hierarchy_path;',
      'WITH EmployeeData AS (',
      'SELECT * FROM employees',
      'WHERE salary > 100000',
      'GROUP BY department',
      'HAVING COUNT(*) > 5',
      'ORDER BY salary DESC',
      'LIMIT 10',
      'UNION ALL',
      'SELECT name, position, salary',
      'FROM managers',
      'INNER JOIN departments ON managers.dept_id = departments.id',
      'CROSS JOIN projects',
      'NATURAL JOIN salaries',
      'FULL OUTER JOIN employee_history',
      'USING (employee_id)',
      'WINDOW w AS (PARTITION BY department ORDER BY salary)',
      'LAG(salary) OVER w as prev_salary',
      'LEAD(salary) OVER w as next_salary',
      'FIRST_VALUE(salary) OVER w as first_salary',
      'LAST_VALUE(salary) OVER w as last_salary',
      'NTILE(4) OVER w as salary_quartile',
      'CUME_DIST() OVER w as cumulative_dist',
      'ROLLUP(department, position)',
      'CUBE(region, department)',
      'GROUPING SETS ((department), (position), ())'
    ]..shuffle();
  }

  void _startGameMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);
      await musicService.stopBackgroundMusic();
      await musicService.playSoundEffect('game_start.mp3');
      await Future.delayed(Duration(milliseconds: 500));
      await musicService.playSoundEffect('game_music.mp3');
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
      musicService.playSoundEffect('hint_use.mp3');

      setState(() {
        _isUsingHint = true;
        _showHint = true;
        _availableHintCards--;
      });

      final user = await UserPreferences.getUser();
      if (user['id'] != null) {
        await DailyChallengeService.useHintCard(user['id']);
      }

      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showHint = false;
            _isUsingHint = false;
          });
        }
      });
    } else if (_availableHintCards <= 0) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('error.mp3');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hint cards available! Complete daily challenges to earn more.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    if (gameConfig != null) {
      _initializeGameFromConfig();
    } else {
      _initializeDefaultBlocks();
    }
    setState(() {});
  }

  void startGame() {
    if (gameConfig == null) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSoundEffect('error.mp3');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SQL Hard Level 3 game configuration not loaded. Please retry.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('level_start.mp3');

    int timerDuration = gameConfig!['timer_duration'] != null
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 360
        : 360;

    setState(() {
      gameStarted = true;
      score = 3;
      remainingSeconds = timerDuration;
      droppedBlocks.clear();
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
      resetBlocks();
    });

    print('🎮 SQL HARD LEVEL 3 GAME STARTED - Initial Score: $score, Timer: $timerDuration seconds');
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
          musicService.playSoundEffect('time_up.mp3');

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

    scoreReductionTimer = Timer.periodic(Duration(seconds: 45), (timer) {
      if (isAnsweredCorrectly || score <= 1) {
        timer.cancel();
        return;
      }

      setState(() {
        score--;
        final musicService = Provider.of<MusicService>(context, listen: false);
        musicService.playSoundEffect('penalty.mp3');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⏰ Time penalty! -1 point. Current score: $score"),
          ),
        );
      });
    });
  }

  void resetGame() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSoundEffect('reset.mp3');

    int timerDuration = gameConfig!['timer_duration'] != null
        ? int.tryParse(gameConfig!['timer_duration'].toString()) ?? 360
        : 360;

    setState(() {
      score = 3;
      remainingSeconds = timerDuration;
      gameStarted = false;
      isAnsweredCorrectly = false;
      _showHint = false;
      _isUsingHint = false;
      droppedBlocks.clear();
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();
      resetBlocks();
    });
  }

  Future<void> saveScoreToDatabase(int score) async {
    if (currentUser?['id'] == null) {
      print('❌ Cannot save SQL Hard Level 3 score: No user ID');
      return;
    }

    try {
      print('💾 SAVING SQL HARD LEVEL 3 SCORE:');
      print('   User ID: ${currentUser!['id']}');
      print('   Language: SQL_Hard');
      print('   Level: 3');
      print('   Score: $score/3');

      final response = await ApiService.saveScoreWithDifficulty(
        currentUser!['id'],
        'SQL',
        'Hard',
        3,
        score,
        score == 3,
      );

      print('📡 SQL HARD LEVEL 3 SERVER RESPONSE: $response');

      if (response['success'] == true) {
        setState(() {
          levelCompleted = score == 3;
          previousScore = score;
          hasPreviousScore = true;
        });

        print('✅ SQL HARD LEVEL 3 SCORE SAVED SUCCESSFULLY');
      } else {
        print('❌ FAILED TO SAVE SQL HARD LEVEL 3 SCORE: ${response['message']}');
      }
    } catch (e) {
      print('❌ ERROR SAVING SQL HARD LEVEL 3 SCORE: $e');
    }
  }

  Future<void> loadScoreFromDatabase() async {
    if (currentUser?['id'] == null) return;

    try {
      final response = await ApiService.getScoresWithDifficulty(currentUser!['id'], 'SQL', 'Hard');

      if (response['success'] == true && response['scores'] != null) {
        final scoresData = response['scores'];
        final level3Data = scoresData['3'];

        if (level3Data != null) {
          setState(() {
            previousScore = level3Data['score'] ?? 0;
            levelCompleted = level3Data['completed'] ?? false;
            hasPreviousScore = true;
          });
        }
      }
    } catch (e) {
      print('Error loading SQL Hard Level 3 score: $e');
    }
  }

  bool isIncorrectBlock(String block) {
    if (gameConfig != null) {
      try {
        List<String> incorrectBlocks = _parseBlocks(gameConfig!['incorrect_blocks'], 'incorrect');
        bool isIncorrect = incorrectBlocks.contains(block);
        if (isIncorrect) {
          print('❌ SQL Hard Level 3 Block "$block" is in incorrect blocks list');
        }
        return isIncorrect;
      } catch (e) {
        print('Error checking SQL Hard Level 3 incorrect block: $e');
      }
    }

    // Default incorrect blocks for SQL Hard Level 3
    List<String> incorrectBlocks = [
      'WITH EmployeeData AS (',
      'SELECT * FROM employees',
      'WHERE salary > 100000',
      'GROUP BY department',
      'HAVING COUNT(*) > 5',
      'ORDER BY salary DESC',
      'LIMIT 10',
      'UNION ALL',
      'SELECT name, position, salary',
      'FROM managers',
      'INNER JOIN departments ON managers.dept_id = departments.id',
      'CROSS JOIN projects',
      'NATURAL JOIN salaries',
      'FULL OUTER JOIN employee_history',
      'USING (employee_id)',
      'WINDOW w AS (PARTITION BY department ORDER BY salary)',
      'LAG(salary) OVER w as prev_salary',
      'LEAD(salary) OVER w as next_salary',
      'FIRST_VALUE(salary) OVER w as first_salary',
      'LAST_VALUE(salary) OVER w as last_salary',
      'NTILE(4) OVER w as salary_quartile',
      'CUME_DIST() OVER w as cumulative_dist',
      'ROLLUP(department, position)',
      'CUBE(region, department)',
      'GROUPING SETS ((department), (position), ())'
    ];
    return incorrectBlocks.contains(block);
  }

  void checkAnswer() async {
    if (isAnsweredCorrectly || droppedBlocks.isEmpty) return;

    final musicService = Provider.of<MusicService>(context, listen: false);

    // DEBUG: Print what we're checking
    print('🔍 CHECKING SQL HARD LEVEL 3 ANSWER:');
    print('   Dropped blocks: $droppedBlocks');

    // Check if any incorrect blocks are used
    bool hasIncorrectBlock = droppedBlocks.any((block) => isIncorrectBlock(block));

    if (hasIncorrectBlock) {
      print('❌ SQL HARD LEVEL 3 HAS INCORRECT BLOCK');
      musicService.playSoundEffect('error.mp3');

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

        musicService.playSoundEffect('game_over.mp3');

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

    // GRAND MASTER SQL ANSWER CHECKING LOGIC
    bool isCorrect = false;

    if (gameConfig != null) {
      // Get expected correct blocks from database
      List<String> expectedCorrectBlocks = _parseBlocks(gameConfig!['correct_blocks'], 'correct');

      print('🎯 SQL HARD LEVEL 3 EXPECTED CORRECT BLOCKS: $expectedCorrectBlocks');
      print('🎯 SQL HARD LEVEL 3 USER DROPPED BLOCKS: $droppedBlocks');

      // METHOD 1: Check if user has all correct blocks and no extra correct blocks
      bool hasAllCorrectBlocks = expectedCorrectBlocks.every((block) => droppedBlocks.contains(block));
      bool noExtraCorrectBlocks = droppedBlocks.every((block) => expectedCorrectBlocks.contains(block));

      // METHOD 2: Check string comparison (normalized for SQL)
      String userAnswer = droppedBlocks.join(' ');
      String normalizedUserAnswer = userAnswer
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .replaceAll('"', "'")
          .toLowerCase();

      if (gameConfig!['correct_answer'] != null) {
        String expectedAnswer = gameConfig!['correct_answer'].toString();
        String normalizedExpected = expectedAnswer
            .replaceAll(' ', '')
            .replaceAll('\n', '')
            .replaceAll('"', "'")
            .toLowerCase();

        print('📝 SQL HARD LEVEL 3 USER ANSWER: $userAnswer');
        print('📝 SQL HARD LEVEL 3 NORMALIZED USER: $normalizedUserAnswer');
        print('🎯 SQL HARD LEVEL 3 EXPECTED ANSWER: $expectedAnswer');
        print('🎯 SQL HARD LEVEL 3 NORMALIZED EXPECTED: $normalizedExpected');

        bool stringMatch = normalizedUserAnswer == normalizedExpected;

        // Use both methods for verification
        isCorrect = (hasAllCorrectBlocks && noExtraCorrectBlocks) || stringMatch;

        print('✅ SQL HARD LEVEL 3 BLOCK CHECK: hasAllCorrectBlocks=$hasAllCorrectBlocks, noExtraCorrectBlocks=$noExtraCorrectBlocks');
        print('✅ SQL HARD LEVEL 3 STRING CHECK: stringMatch=$stringMatch');
        print('✅ SQL HARD LEVEL 3 FINAL RESULT: $isCorrect');
      } else {
        // Fallback: only use block comparison
        isCorrect = hasAllCorrectBlocks && noExtraCorrectBlocks;
        print('⚠️ No correct_answer in DB, using block comparison only: $isCorrect');
      }
    } else {
      // Fallback check for grand master SQL requirements
      print('⚠️ No SQL Hard Level 3 game config, using fallback check');
      bool hasRecursiveCTE = droppedBlocks.any((block) => block.toLowerCase().contains('recursive'));
      bool hasMultipleCTEs = droppedBlocks.where((block) => block.toLowerCase().contains('as (')).length >= 2;
      bool hasAdvancedWindowFunctions = droppedBlocks.any((block) => block.toLowerCase().contains('percent_rank'));
      bool hasComplexJoins = droppedBlocks.where((block) => block.toLowerCase().contains('join')).length >= 4;
      bool hasHierarchicalQuery = droppedBlocks.any((block) => block.toLowerCase().contains('hierarchy_level'));

      isCorrect = hasRecursiveCTE && hasMultipleCTEs && hasAdvancedWindowFunctions && hasComplexJoins && hasHierarchicalQuery;
      print('✅ SQL HARD LEVEL 3 FALLBACK CHECK: $isCorrect');
    }

    if (isCorrect) {
      countdownTimer?.cancel();
      scoreReductionTimer?.cancel();

      setState(() {
        isAnsweredCorrectly = true;
      });

      saveScoreToDatabase(score);

      if (score == 3) {
        musicService.playSoundEffect('perfect.mp3');
      } else {
        musicService.playSoundEffect('success.mp3');
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("🏆 SQL Grand Master Achievement!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Incredible! You've mastered the most complex SQL challenge!"),
              SizedBox(height: 10),
              Text("Your Score: $score/3", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              if (score == 3)
                Text(
                  "🎉 PERFECT SCORE! You are now a SQL Grand Master!",
                  style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  "⚠️ Get a perfect score (3/3) to achieve Grand Master status!",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              Text("Query Result Preview:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: _buildQueryResultPreview(),
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
                  Navigator.pushReplacementNamed(context, '/levels', arguments: {
                    'language': 'SQL',
                    'difficulty': 'Hard',
                    'completed': true
                  });
                } else {
                  Navigator.pushReplacementNamed(context, '/levels', arguments: {
                    'language': 'SQL',
                    'difficulty': 'Hard'
                  });
                }
              },
              child: Text(score == 3 ? "Complete Mastery" : "Go Back"),
            )
          ],
        ),
      );
    } else {
      print('❌ SQL HARD LEVEL 3 ANSWER INCORRECT');
      musicService.playSoundEffect('wrong.mp3');

      if (score > 1) {
        setState(() {
          score--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Incorrect SQL arrangement. -1 point. Current score: $score"),
          ),
        );
      } else {
        setState(() {
          score = 0;
        });
        countdownTimer?.cancel();
        scoreReductionTimer?.cancel();
        saveScoreToDatabase(score);

        musicService.playSoundEffect('game_over.mp3');

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("💀 Game Over"),
            content: Text("You lost all your points."),
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

  Widget _buildQueryResultPreview() {
    // Simulate the complex recursive CTE query result
    List<Map<String, dynamic>> hierarchyResults = [];

    // Build hierarchy manually for preview
    Map<int, Map<String, dynamic>> employeeMap = {};
    for (var emp in _employeesTable) {
      employeeMap[emp['employee_id']] = {
        'name': emp['name'],
        'position': emp['position'],
        'department_name': _departmentsTable.firstWhere(
                (dept) => dept['department_id'] == emp['department_id'],
            orElse: () => {'department_name': 'Unknown'}
        )['department_name'],
      };
    }

    // Add top-level (level 0)
    var ceo = _employeeHierarchyTable.firstWhere((h) => h['manager_id'] == null);
    hierarchyResults.add({
      'hierarchy_level': 0,
      'employee_name': employeeMap[ceo['employee_id']]!['name'],
      'position': employeeMap[ceo['employee_id']]!['position'],
      'department_name': employeeMap[ceo['employee_id']]!['department_name'],
      'hierarchy_path': employeeMap[ceo['employee_id']]!['name'],
      'salary_amount': _salariesTable.firstWhere((s) => s['employee_id'] == ceo['employee_id'])['salary_amount'],
      'project_count': _projectAssignmentsTable.where((pa) => pa['employee_id'] == ceo['employee_id']).length,
      'salary_rank_in_dept': 1,
      'salary_percentile': 100.0,
    });

    // Add level 1
    var level1 = _employeeHierarchyTable.where((h) => h['manager_id'] == ceo['employee_id']);
    for (var emp in level1) {
      hierarchyResults.add({
        'hierarchy_level': 1,
        'employee_name': employeeMap[emp['employee_id']]!['name'],
        'position': employeeMap[emp['employee_id']]!['position'],
        'department_name': employeeMap[emp['employee_id']]!['department_name'],
        'hierarchy_path': '${employeeMap[ceo['employee_id']]!['name']} -> ${employeeMap[emp['employee_id']]!['name']}',
        'salary_amount': _salariesTable.firstWhere((s) => s['employee_id'] == emp['employee_id'])['salary_amount'],
        'project_count': _projectAssignmentsTable.where((pa) => pa['employee_id'] == emp['employee_id']).length,
        'salary_rank_in_dept': 1,
        'salary_percentile': 100.0,
      });
    }

    // Add level 2
    for (var l1 in level1) {
      var level2 = _employeeHierarchyTable.where((h) => h['manager_id'] == l1['employee_id']);
      for (var emp in level2) {
        hierarchyResults.add({
          'hierarchy_level': 2,
          'employee_name': employeeMap[emp['employee_id']]!['name'],
          'position': employeeMap[emp['employee_id']]!['position'],
          'department_name': employeeMap[emp['employee_id']]!['department_name'],
          'hierarchy_path': '${employeeMap[ceo['employee_id']]!['name']} -> ${employeeMap[l1['employee_id']]!['name']} -> ${employeeMap[emp['employee_id']]!['name']}',
          'salary_amount': _salariesTable.firstWhere((s) => s['employee_id'] == emp['employee_id'])['salary_amount'],
          'project_count': _projectAssignmentsTable.where((pa) => pa['employee_id'] == emp['employee_id']).length,
          'salary_rank_in_dept': 1,
          'salary_percentile': 100.0,
        });
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Level', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Employee', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Position', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Department', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Salary', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Projects', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Rank', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Percentile', style: TextStyle(color: Colors.white))),
        ],
        rows: hierarchyResults.map((row) {
          return DataRow(cells: [
            DataCell(Text(row['hierarchy_level'].toString(), style: TextStyle(color: Colors.white))),
            DataCell(Text(row['employee_name'].toString(), style: TextStyle(color: Colors.white))),
            DataCell(Text(row['position'].toString(), style: TextStyle(color: Colors.white))),
            DataCell(Text(row['department_name'].toString(), style: TextStyle(color: Colors.white))),
            DataCell(Text('₱${row['salary_amount']}', style: TextStyle(color: Colors.greenAccent))),
            DataCell(Text(row['project_count'].toString(), style: TextStyle(color: Colors.white))),
            DataCell(Text(row['salary_rank_in_dept'].toString(), style: TextStyle(color: Colors.yellowAccent))),
            DataCell(Text('${row['salary_percentile']}%', style: TextStyle(color: Colors.blueAccent))),
          ]);
        }).toList(),
      ),
    );
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
                  '💡 SQL Grand Master Hint Activated!',
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
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10 * _scaleFactor),
            Text(
              'Hint will disappear in 5 seconds...',
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

  Widget _buildHintButton() {
    return Positioned(
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
    );
  }

  // Database Tables Preview Widget
  Widget getDatabasePreview() {
    return Column(
      children: [
        // Employees Table
        Container(
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
                      'Table: $_employeesTableName',
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20 * _scaleFactor,
                    dataRowHeight: 32 * _scaleFactor,
                    headingRowHeight: 40 * _scaleFactor,
                    columns: [
                      DataColumn(label: Text('employee_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('name', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('department_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('position', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                    ],
                    rows: _employeesTable.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(row['employee_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['name'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['department_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['position'].toString(), style: TextStyle(color: Colors.white))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16 * _scaleFactor),

        // Departments Table
        Container(
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
                      'Table: $_departmentsTableName',
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20 * _scaleFactor,
                    dataRowHeight: 32 * _scaleFactor,
                    headingRowHeight: 40 * _scaleFactor,
                    columns: [
                      DataColumn(label: Text('department_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('department_name', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                    ],
                    rows: _departmentsTable.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(row['department_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['department_name'].toString(), style: TextStyle(color: Colors.white))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16 * _scaleFactor),

        // Employee Hierarchy Table
        Container(
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
                    Icon(Icons.account_tree, color: Colors.grey[400], size: 16 * _scaleFactor),
                    SizedBox(width: 8 * _scaleFactor),
                    Text(
                      'Table: $_employeeHierarchyTableName',
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20 * _scaleFactor,
                    dataRowHeight: 32 * _scaleFactor,
                    headingRowHeight: 40 * _scaleFactor,
                    columns: [
                      DataColumn(label: Text('hierarchy_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('employee_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('manager_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                    ],
                    rows: _employeeHierarchyTable.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(row['hierarchy_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['employee_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['manager_id']?.toString() ?? 'NULL', style: TextStyle(color: row['manager_id'] == null ? Colors.orange : Colors.white))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16 * _scaleFactor),

        // Project Assignments Table
        Container(
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
                    Icon(Icons.assignment, color: Colors.grey[400], size: 16 * _scaleFactor),
                    SizedBox(width: 8 * _scaleFactor),
                    Text(
                      'Table: $_projectAssignmentsTableName',
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20 * _scaleFactor,
                    dataRowHeight: 32 * _scaleFactor,
                    headingRowHeight: 40 * _scaleFactor,
                    columns: [
                      DataColumn(label: Text('assignment_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('employee_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('project_id', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('role', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                    ],
                    rows: _projectAssignmentsTable.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(row['assignment_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['employee_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['project_id'].toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(row['role'].toString(), style: TextStyle(color: Colors.greenAccent))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Organized SQL code preview
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
                  'grand_master_query.sql',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildOrganizedSQLPreview(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrganizedSQLPreview() {
    List<Widget> codeLines = [];

    for (int i = 0; i < _codeStructure.length; i++) {
      String line = _codeStructure[i];

      if (line.contains('-- Complete the recursive CTE query below')) {
        // Add user's dragged SQL code in the correct position
        codeLines.add(_buildUserSQLSection());
      } else if (line.trim().isEmpty) {
        codeLines.add(SizedBox(height: 16 * _scaleFactor));
      } else {
        codeLines.add(_buildSQLSyntaxHighlightedLine(line, i + 1));
      }
    }

    return codeLines;
  }

  Widget _buildUserSQLSection() {
    if (droppedBlocks.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8 * _scaleFactor),
        child: Text(
          '-- Drag SQL blocks here to build your grand master recursive CTE query...',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12 * _scaleFactor,
            fontFamily: 'monospace',
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * _scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (String block in droppedBlocks)
            Container(
              margin: EdgeInsets.only(bottom: 4 * _scaleFactor),
              child: Text(
                block,
                style: TextStyle(
                  color: Colors.purpleAccent[400],
                  fontSize: 12 * _scaleFactor,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSQLSyntaxHighlightedLine(String code, int lineNumber) {
    Color textColor = Colors.white;
    String displayCode = code;

    // SQL Syntax highlighting rules
    if (code.trim().startsWith('--')) {
      textColor = Color(0xFF6A9955); // Comments - green
    } else if (code.toUpperCase().contains('WITH RECURSIVE') ||
        code.toUpperCase().contains('UNION ALL') ||
        code.toUpperCase().contains('SELECT') ||
        code.toUpperCase().contains('FROM') ||
        code.toUpperCase().contains('JOIN') ||
        code.toUpperCase().contains('ON') ||
        code.toUpperCase().contains('WHERE') ||
        code.toUpperCase().contains('GROUP BY') ||
        code.toUpperCase().contains('ORDER BY') ||
        code.toUpperCase().contains('PARTITION BY') ||
        code.toUpperCase().contains('OVER') ||
        code.toUpperCase().contains('CAST') ||
        code.toUpperCase().contains('AS') ||
        code.toUpperCase().contains('LEFT') ||
        code.toUpperCase().contains('NULL')) {
      textColor = Color(0xFF569CD6); // SQL Keywords - blue
    } else if (code.contains('PERCENT_RANK') ||
        code.contains('RANK') ||
        code.contains('AVG') ||
        code.contains('COUNT') ||
        code.contains('SUM') ||
        code.contains('ROUND')) {
      textColor = Color(0xFFDCDCAA); // Functions - yellow
    } else if (code.contains('"') || code.contains("'") || code.contains('->')) {
      textColor = Color(0xFFCE9178); // Strings and paths - orange
    } else if (code.contains('.')) {
      textColor = Color(0xFF9CDCFE); // Table aliases - light blue
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2 * _scaleFactor),
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
              displayCode,
              style: TextStyle(
                color: textColor,
                fontSize: 12 * _scaleFactor,
                fontFamily: 'monospace',
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("🏆 SQL Grand Master - Level 3", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.purple,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.purple),
                SizedBox(height: 20),
                Text(
                  "Loading SQL Grand Master Level 3 Configuration...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "Ultimate Challenge - Recursive CTEs & Advanced Analytics",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (errorMessage != null && !gameStarted) {
      return Scaffold(
        appBar: AppBar(
          title: Text("🏆 SQL Grand Master - Level 3", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.purple,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.purple, size: 50),
                  SizedBox(height: 20),
                  Text(
                    "SQL Grand Master Level 3 Configuration Warning",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadGameConfig,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: Text("Retry Loading"),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/levels', arguments: {
                        'language': 'SQL',
                        'difficulty': 'Hard'
                      });
                    },
                    child: Text("Back to Levels", style: TextStyle(color: Colors.purple)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newScreenWidth = MediaQuery.of(context).size.width;
      final newScaleFactor = newScreenWidth < _baseScreenWidth
          ? newScreenWidth / _baseScreenWidth
          : 1.0;

      if (newScaleFactor != _scaleFactor) {
        setState(() {
          _scaleFactor = newScaleFactor;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("🏆 SQL Grand Master - Level 3", style: TextStyle(fontSize: 18 * _scaleFactor)),
        backgroundColor: Colors.purple,
        actions: gameStarted
            ? [
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
        ]
            : [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: Stack(
          children: [
            gameStarted ? buildGameUI() : buildStartScreen(),
            if (gameStarted && !isAnsweredCorrectly) ...[
              _buildHintDisplay(),
              _buildHintButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildStartScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16 * _scaleFactor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: gameConfig != null ? () {
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.playSoundEffect('button_click.mp3');
                startGame();
              } : null,
              icon: Icon(Icons.play_arrow, size: 20 * _scaleFactor),
              label: Text(gameConfig != null ? "Start Grand Master Challenge" : "Config Missing", style: TextStyle(fontSize: 16 * _scaleFactor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24 * _scaleFactor, vertical: 12 * _scaleFactor),
                backgroundColor: gameConfig != null ? Colors.purple : Colors.grey,
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
              'Use hint cards for grand master SQL help!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12 * _scaleFactor,
              ),
            ),

            if (levelCompleted)
              Padding(
                padding: EdgeInsets.only(top: 10 * _scaleFactor),
                child: Column(
                  children: [
                    Text(
                      "🏆 SQL Grand Master Level 3 Completed!",
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "You've achieved the highest SQL mastery level!",
                      style: TextStyle(color: Colors.purple, fontSize: 14 * _scaleFactor),
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
                      "📊 Your previous Grand Master score: $previousScore/3",
                      style: TextStyle(color: Colors.purple, fontSize: 16 * _scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5 * _scaleFactor),
                    Text(
                      "Complete with perfect score to become a SQL Grand Master!",
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
                        "🎯 Your previous Grand Master attempt: $previousScore/3",
                        style: TextStyle(color: Colors.purple, fontSize: 16 * _scaleFactor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5 * _scaleFactor),
                      Text(
                        "This is the ultimate SQL challenge! Study recursive CTEs and advanced analytics.",
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
                    gameConfig?['objective'] ?? "🎯 SQL Grand Master Level 3 Objective",
                    style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.purple[800]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    gameConfig?['objective'] ?? "Master the most advanced SQL concepts including RECURSIVE CTEs for hierarchical data, multiple Common Table Expressions, advanced window functions (PERCENT_RANK), complex multi-table JOINs across 6+ tables, and organizational analytics",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.purple[700]),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "👑 Achieve perfect score (3/3) to become a SQL Grand Master!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "🏆 5× POINTS MULTIPLIER",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14 * _scaleFactor,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10 * _scaleFactor),
                  Text(
                    "⏱️ 360 seconds | ⚡ 45s penalties",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12 * _scaleFactor,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold
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
                child: Text('👑 SQL Grand Master Challenge', style: TextStyle(fontSize: 16 * _scaleFactor, fontWeight: FontWeight.bold, color: Colors.white)),
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
                label: Text(isTagalog ? 'English' : 'Tagalog', style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 10 * _scaleFactor),
          Text(
            isTagalog
                ? (gameConfig?['story_tagalog'] ?? 'Ito ang pinakamataas na antas ng SQL challenge! Grand Master level sa recursive CTEs, hierarchical queries, advanced window functions, at complex organizational analytics.')
                : (gameConfig?['story_english'] ?? 'This is the ultimate SQL challenge! Grand Master level with recursive CTEs, hierarchical data analysis, advanced window functions, and complex organizational analytics across multiple tables.'),
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white70),
          ),
          SizedBox(height: 20 * _scaleFactor),

          Text(_instructionText,
              style: TextStyle(fontSize: 16 * _scaleFactor, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 20 * _scaleFactor),

          // Database Tables Preview
          Text("📊 Database Tables Preview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getDatabasePreview(),
          SizedBox(height: 20 * _scaleFactor),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 180 * _scaleFactor,
              maxHeight: 250 * _scaleFactor,
            ),
            padding: EdgeInsets.all(16 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[100]!.withOpacity(0.9),
              border: Border.all(color: Colors.purple, width: 2.5 * _scaleFactor),
              borderRadius: BorderRadius.circular(20 * _scaleFactor),
            ),
            child: DragTarget<String>(
              onWillAccept: (data) {
                return !droppedBlocks.contains(data);
              },
              onAccept: (data) {
                if (!isAnsweredCorrectly) {
                  final musicService = Provider.of<MusicService>(context, listen: false);
                  musicService.playSoundEffect('block_drop.mp3');

                  setState(() {
                    droppedBlocks.add(data);
                    allBlocks.remove(data);
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 8 * _scaleFactor,
                    runSpacing: 8 * _scaleFactor,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: droppedBlocks.map((block) {
                      return Draggable<String>(
                        data: block,
                        feedback: Material(
                          color: Colors.transparent,
                          child: puzzleBlock(block, Colors.purpleAccent),
                        ),
                        childWhenDragging: puzzleBlock(block, Colors.purpleAccent.withOpacity(0.5)),
                        child: puzzleBlock(block, Colors.purpleAccent),
                        onDragStarted: () {
                          final musicService = Provider.of<MusicService>(context, listen: false);
                          musicService.playSoundEffect('block_pickup.mp3');

                          setState(() {
                            currentlyDraggedBlock = block;
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
                                  if (!allBlocks.contains(block)) {
                                    allBlocks.add(block);
                                  }
                                  droppedBlocks.remove(block);
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
          Text(_codePreviewTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _scaleFactor, color: Colors.white)),
          SizedBox(height: 10 * _scaleFactor),
          getCodePreview(),
          SizedBox(height: 20 * _scaleFactor),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 140 * _scaleFactor,
            ),
            padding: EdgeInsets.all(12 * _scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12 * _scaleFactor),
            ),
            child: Wrap(
              spacing: 8 * _scaleFactor,
              runSpacing: 10 * _scaleFactor,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: allBlocks.map((block) {
                return isAnsweredCorrectly
                    ? puzzleBlock(block, Colors.grey)
                    : Draggable<String>(
                  data: block,
                  feedback: Material(
                    color: Colors.transparent,
                    child: puzzleBlock(block, Colors.purple),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: puzzleBlock(block, Colors.purple),
                  ),
                  child: puzzleBlock(block, Colors.purple),
                  onDragStarted: () {
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('block_pickup.mp3');

                    setState(() {
                      currentlyDraggedBlock = block;
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
                            if (!allBlocks.contains(block)) {
                              allBlocks.add(block);
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
              musicService.playSoundEffect('compile.mp3');
              checkAnswer();
            },
            icon: Icon(Icons.play_arrow, size: 18 * _scaleFactor),
            label: Text("Execute Grand Master Query", style: TextStyle(fontSize: 16 * _scaleFactor)),
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
            child: Text("🔁 Retry Grand Master Challenge", style: TextStyle(fontSize: 14 * _scaleFactor, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget puzzleBlock(String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 12 * _scaleFactor,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout();

    final textWidth = textPainter.width;
    final minWidth = 80 * _scaleFactor;
    final maxWidth = 240 * _scaleFactor;

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
      margin: EdgeInsets.symmetric(horizontal: 3 * _scaleFactor),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * _scaleFactor,
        vertical: 10 * _scaleFactor,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * _scaleFactor),
          bottomRight: Radius.circular(20 * _scaleFactor),
        ),
        border: Border.all(color: Colors.black87, width: 2.0 * _scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6 * _scaleFactor,
            offset: Offset(3 * _scaleFactor, 3 * _scaleFactor),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 12 * _scaleFactor,
          color: Colors.black,
          shadows: [
            Shadow(
              offset: Offset(1 * _scaleFactor, 1 * _scaleFactor),
              blurRadius: 2 * _scaleFactor,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        softWrap: true,
      ),
    );
  }
}