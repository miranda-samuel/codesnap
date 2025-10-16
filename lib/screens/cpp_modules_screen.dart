import 'package:flutter/material.dart';

import 'learning_screen.dart';

class CppModulesScreen extends StatefulWidget {
  const CppModulesScreen({super.key});

  @override
  State<CppModulesScreen> createState() => _CppModulesScreenState();
}

class _CppModulesScreenState extends State<CppModulesScreen> {
  final List<Map<String, dynamic>> _cppModules = [
    {
      'title': 'C++ Introduction',
      'icon': Icons.play_arrow,
      'color': Colors.blue,
      'topics': [
        'What is C++?',
        'C++ vs C',
        'Setting up C++ Environment',
        'First C++ Program',
        'C++ Syntax Basics'
      ],
      'description': 'Get started with C++ programming language',
    },
    {
      'title': 'C++ Syntax',
      'icon': Icons.code,
      'color': Colors.blue,
      'topics': [
        'Variables and Data Types',
        'Constants',
        'Input/Output',
        'Comments',
        'Operators'
      ],
      'description': 'Learn C++ basic syntax and structure',
    },
    {
      'title': 'C++ Data Types',
      'icon': Icons.storage,
      'color': Colors.blue,
      'topics': [
        'Basic Data Types',
        'Numeric Types',
        'Boolean Type',
        'Character Types',
        'Type Modifiers'
      ],
      'description': 'Understand different data types in C++',
    },
    {
      'title': 'C++ Operators',
      'icon': Icons.calculate,
      'color': Colors.blue,
      'topics': [
        'Arithmetic Operators',
        'Assignment Operators',
        'Comparison Operators',
        'Logical Operators',
        'Bitwise Operators'
      ],
      'description': 'Master operators in C++ programming',
    },
    {
      'title': 'C++ Strings',
      'icon': Icons.text_fields,
      'color': Colors.blue,
      'topics': [
        'String Basics',
        'String Concatenation',
        'String Methods',
        'String Length',
        'Accessing Strings'
      ],
      'description': 'Work with strings in C++',
    },
    {
      'title': 'C++ Math',
      'icon': Icons.functions,
      'color': Colors.blue,
      'topics': [
        'Math Operations',
        'Math Functions',
        'Max and Min',
        'Power and Square Root',
        'Random Numbers'
      ],
      'description': 'Perform mathematical operations in C++',
    },
    {
      'title': 'C++ Conditions',
      'icon': Icons.settings,
      'color': Colors.blue,
      'topics': [
        'If Statement',
        'Else Statement',
        'Else If Statement',
        'Switch Statement',
        'Ternary Operator'
      ],
      'description': 'Control program flow with conditions',
    },
    {
      'title': 'C++ Loops',
      'icon': Icons.loop,
      'color': Colors.blue,
      'topics': [
        'While Loop',
        'Do-While Loop',
        'For Loop',
        'Break Statement',
        'Continue Statement'
      ],
      'description': 'Learn looping structures in C++',
    },
    {
      'title': 'C++ Arrays',
      'icon': Icons.view_array,
      'color': Colors.blue,
      'topics': [
        'Array Basics',
        'Access Array Elements',
        'Change Array Elements',
        'Array Length',
        'Multi-dimensional Arrays'
      ],
      'description': 'Work with arrays in C++',
    },
    {
      'title': 'C++ Functions',
      'icon': Icons.functions,
      'color': Colors.blue,
      'topics': [
        'Function Declaration',
        'Function Parameters',
        'Function Return',
        'Function Overloading',
        'Recursion'
      ],
      'description': 'Create and use functions in C++',
    },
    {
      'title': 'C++ Classes/Objects',
      'icon': Icons.account_tree,
      'color': Colors.blue,
      'topics': [
        'OOP Concepts',
        'Classes and Objects',
        'Class Methods',
        'Constructors',
        'Access Specifiers'
      ],
      'description': 'Object-oriented programming in C++',
    },
    {
      'title': 'C++ Inheritance',
      'icon': Icons.family_restroom,
      'color': Colors.blue,
      'topics': [
        'Inheritance Basics',
        'Single Inheritance',
        'Multiple Inheritance',
        'Multilevel Inheritance',
        'Method Overriding'
      ],
      'description': 'Learn inheritance in C++ OOP',
    },
    {
      'title': 'C++ Pointers',
      'icon': Icons.memory,
      'color': Colors.blue,
      'topics': [
        'Pointer Basics',
        'Pointer Arithmetic',
        'Pointers and Arrays',
        'Pointers and Functions',
        'Memory Management'
      ],
      'description': 'Understand pointers in C++',
    },
    {
      'title': 'C++ Files',
      'icon': Icons.insert_drive_file,
      'color': Colors.blue,
      'topics': [
        'File Handling',
        'Read Files',
        'Write Files',
        'File Operations',
        'File Exceptions'
      ],
      'description': 'Work with files in C++',
    },
    {
      'title': 'C++ Exceptions',
      'icon': Icons.warning,
      'color': Colors.blue,
      'topics': [
        'Exception Handling',
        'Try-Catch Block',
        'Throw Exception',
        'Custom Exceptions',
        'Exception Best Practices'
      ],
      'description': 'Handle errors and exceptions in C++',
    },
  ];

  void _openModule(Map<String, dynamic> module) {
    // Dito pwedeng mag-navigate sa specific module content
    // For now, show a dialog with the topics
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1B263B),
          title: Row(
            children: [
              Icon(module['icon'], color: module['color']),
              SizedBox(width: 12),
              Text(
                module['title'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module['description'],
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                Text(
                  'Topics in this module:',
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...module['topics'].map<Widget>((topic) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            topic,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.tealAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Dito pwedeng mag-navigate sa actual learning content
                _startLearning(module);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Start Learning'),
            ),
          ],
        );
      },
    );
  }

  void _startLearning(Map<String, dynamic> module) {
    // Map module titles to file names
    final fileMap = {
      'C++ Introduction': 'cpp_introduction.md',
      'C++ Syntax': 'cpp_syntax.md',
      'C++ Data Types': 'cpp_datatypes.md',
      'C++ Operators': 'cpp_operators.md',
      'C++ Strings': 'cpp_strings.md',
      'C++ Math': 'cpp_math.md',
      'C++ Conditions': 'cpp_conditions.md',
      'C++ Loops': 'cpp_loops.md',
      'C++ Arrays': 'cpp_arrays.md',
      'C++ Functions': 'cpp_functions.md',
      'C++ Classes/Objects': 'cpp_classes.md',
      'C++ Inheritance': 'cpp_inheritance.md',
      'C++ Pointers': 'cpp_pointers.md',
      'C++ Files': 'cpp_files.md',
      'C++ Exceptions': 'cpp_exceptions.md',
    };

    final fileName = fileMap[module['title']] ?? 'cpp_introduction.md';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearningScreen(
          moduleTitle: module['title'],
          fileName: fileName,
          primaryColor: module['color'],
        ),
      ),
    );
  }

  Widget _buildModuleItem(Map<String, dynamic> module) {
    return Card(
      elevation: 2,
      color: Color(0xFF1B263B),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: module['color'].withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            module['icon'],
            color: module['color'],
            size: 24,
          ),
        ),
        title: Text(
          module['title'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              module['description'],
              style: TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...module['topics'].take(3).map<Widget>((topic) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      topic,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
                if (module['topics'].length > 3)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${module['topics'].length - 3} more',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.tealAccent,
          size: 16,
        ),
        onTap: () => _openModule(module),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          'C++ Programming Tutorials',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.memory, color: Colors.blue, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'C++ Tutorials',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Learn C++ programming step by step. Master high-performance programming with comprehensive tutorials.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Select any module to start learning. Each module contains multiple topics with detailed explanations.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Modules List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 20),
                itemCount: _cppModules.length,
                itemBuilder: (context, index) {
                  return _buildModuleItem(_cppModules[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}