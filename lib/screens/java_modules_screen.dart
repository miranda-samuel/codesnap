import 'package:flutter/material.dart';

import 'learning_screen.dart';

class JavaModulesScreen extends StatefulWidget {
  const JavaModulesScreen({super.key});

  @override
  State<JavaModulesScreen> createState() => _JavaModulesScreenState();
}

class _JavaModulesScreenState extends State<JavaModulesScreen> {
  final List<Map<String, dynamic>> _javaModules = [
    {
      'title': 'Java Introduction',
      'icon': Icons.play_arrow,
      'color': Colors.orange,
      'topics': [
        'What is Java?',
        'Java Features',
        'Setting up Java',
        'First Java Program',
        'Java Syntax Basics'
      ],
      'description': 'Get started with Java programming',
    },
    {
      'title': 'Java Syntax',
      'icon': Icons.code,
      'color': Colors.orange,
      'topics': [
        'Variables and Data Types',
        'Identifiers',
        'Comments',
        'Input/Output',
        'Operators'
      ],
      'description': 'Learn Java basic syntax and structure',
    },
    {
      'title': 'Java Variables',
      'icon': Icons.storage,
      'color': Colors.orange,
      'topics': [
        'Variable Declaration',
        'Data Types',
        'Type Casting',
        'Final Variables',
        'Variable Scope'
      ],
      'description': 'Understand variables in Java',
    },
    {
      'title': 'Java Data Types',
      'icon': Icons.data_array,
      'color': Colors.orange,
      'topics': [
        'Primitive Types',
        'Non-Primitive Types',
        'Numbers',
        'Characters',
        'Booleans'
      ],
      'description': 'Master Java data types',
    },
    {
      'title': 'Java Strings',
      'icon': Icons.text_fields,
      'color': Colors.orange,
      'topics': [
        'String Basics',
        'String Methods',
        'String Concatenation',
        'String Formatting',
        'String Comparison'
      ],
      'description': 'Work with strings in Java',
    },
    {
      'title': 'Java Operators',
      'icon': Icons.calculate,
      'color': Colors.orange,
      'topics': [
        'Arithmetic Operators',
        'Assignment Operators',
        'Comparison Operators',
        'Logical Operators',
        'Bitwise Operators'
      ],
      'description': 'Master operators in Java',
    },
    {
      'title': 'Java Conditions',
      'icon': Icons.settings,
      'color': Colors.orange,
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
      'title': 'Java Loops',
      'icon': Icons.loop,
      'color': Colors.orange,
      'topics': [
        'While Loop',
        'Do-While Loop',
        'For Loop',
        'For-Each Loop',
        'Break and Continue'
      ],
      'description': 'Learn looping structures in Java',
    },
    {
      'title': 'Java Arrays',
      'icon': Icons.view_array,
      'color': Colors.orange,
      'topics': [
        'Array Declaration',
        'Access Array Elements',
        'Change Array Elements',
        'Array Length',
        'Multidimensional Arrays'
      ],
      'description': 'Work with arrays in Java',
    },
    {
      'title': 'Java Methods',
      'icon': Icons.functions,
      'color': Colors.orange,
      'topics': [
        'Method Definition',
        'Method Parameters',
        'Return Values',
        'Method Overloading',
        'Recursion'
      ],
      'description': 'Create and use methods in Java',
    },
    {
      'title': 'Java OOP',
      'icon': Icons.account_tree,
      'color': Colors.orange,
      'topics': [
        'Classes and Objects',
        'Constructors',
        'Access Modifiers',
        'Inheritance',
        'Polymorphism'
      ],
      'description': 'Object-oriented programming in Java',
    },
    {
      'title': 'Java Exception Handling',
      'icon': Icons.warning,
      'color': Colors.orange,
      'topics': [
        'Try-Catch Block',
        'Finally Block',
        'Throw Keyword',
        'Throws Keyword',
        'Custom Exceptions'
      ],
      'description': 'Handle errors and exceptions in Java',
    },
    {
      'title': 'Java Collections',
      'icon': Icons.collections,
      'color': Colors.orange,
      'topics': [
        'ArrayList',
        'LinkedList',
        'HashMap',
        'HashSet',
        'Iterator'
      ],
      'description': 'Work with collections in Java',
    },
    {
      'title': 'Java File Handling',
      'icon': Icons.insert_drive_file,
      'color': Colors.orange,
      'topics': [
        'File Class',
        'Read Files',
        'Write Files',
        'Create Files',
        'Delete Files'
      ],
      'description': 'Handle files in Java',
    },
    {
      'title': 'Java Multithreading',
      'icon': Icons.settings,
      'color': Colors.orange,
      'topics': [
        'Thread Basics',
        'Create Threads',
        'Thread Methods',
        'Synchronization',
        'Thread Pool'
      ],
      'description': 'Learn multithreading in Java',
    },
  ];

  void _openModule(Map<String, dynamic> module) {
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
                        Icon(Icons.arrow_right, color: Colors.orange, size: 16),
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
                _startLearning(module);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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
      'Java Introduction': 'java_introduction.md',
      'Java Syntax': 'java_syntax.md',
      'Java Variables': 'java_variables.md',
      'Java Data Types': 'java_datatypes.md',
      'Java Strings': 'java_strings.md',
      'Java Operators': 'java_operators.md',
      'Java Conditions': 'java_conditions.md',
      'Java Loops': 'java_loops.md',
      'Java Arrays': 'java_arrays.md',
      'Java Methods': 'java_methods.md',
      'Java OOP': 'java_oop.md',
      'Java Exception Handling': 'java_exception_handling.md',
      'Java Collections': 'java_collections.md',
      'Java File Handling': 'java_file_handling.md',
      'Java Multithreading': 'java_multithreading.md',
    };

    final fileName = fileMap[module['title']] ?? 'java_introduction.md';

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
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      topic,
                      style: TextStyle(
                        color: Colors.orange,
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
          'Java Programming Tutorials',
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
                      Icon(Icons.coffee, color: Colors.orange, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Java Tutorials',
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
                    'Learn Java programming step by step. Build robust applications with comprehensive tutorials.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 20),
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
                itemCount: _javaModules.length,
                itemBuilder: (context, index) {
                  return _buildModuleItem(_javaModules[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}