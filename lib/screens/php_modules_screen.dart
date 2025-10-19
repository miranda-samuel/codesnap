import 'package:flutter/material.dart';
import 'php_learning_screen.dart';

class PhpModulesScreen extends StatefulWidget {
  const PhpModulesScreen({super.key});

  @override
  State<PhpModulesScreen> createState() => _PhpModulesScreenState();
}

class _PhpModulesScreenState extends State<PhpModulesScreen> {
  final List<Map<String, dynamic>> _phpModules = [
    {
      'title': 'PHP Introduction',
      'icon': Icons.play_arrow,
      'color': Colors.purple,
      'topics': [
        'What is PHP?',
        'PHP vs Other Languages',
        'Setting up PHP Environment',
        'First PHP Program',
        'PHP Syntax Basics'
      ],
      'description': 'Get started with PHP server-side scripting',
    },
    {
      'title': 'PHP Syntax',
      'icon': Icons.code,
      'color': Colors.purple,
      'topics': [
        'Variables and Data Types',
        'Constants',
        'Echo and Print',
        'Comments',
        'PHP Tags'
      ],
      'description': 'Learn PHP basic syntax and structure',
    },
    {
      'title': 'PHP Variables',
      'icon': Icons.storage,
      'color': Colors.purple,
      'topics': [
        'Variable Declaration',
        'Variable Types',
        'Variable Scope',
        'Global Variables',
        'Static Variables'
      ],
      'description': 'Understand variables in PHP',
    },
    {
      'title': 'PHP Operators',
      'icon': Icons.calculate,
      'color': Colors.purple,
      'topics': [
        'Arithmetic Operators',
        'Assignment Operators',
        'Comparison Operators',
        'Logical Operators',
        'String Operators'
      ],
      'description': 'Master operators in PHP programming',
    },
    {
      'title': 'PHP Strings',
      'icon': Icons.text_fields,
      'color': Colors.purple,
      'topics': [
        'String Basics',
        'String Concatenation',
        'String Functions',
        'String Length',
        'String Manipulation'
      ],
      'description': 'Work with strings in PHP',
    },
    {
      'title': 'PHP Arrays',
      'icon': Icons.view_array,
      'color': Colors.purple,
      'topics': [
        'Array Basics',
        'Indexed Arrays',
        'Associative Arrays',
        'Multidimensional Arrays',
        'Array Functions'
      ],
      'description': 'Learn array manipulation in PHP',
    },
    {
      'title': 'PHP Conditions',
      'icon': Icons.settings,
      'color': Colors.purple,
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
      'title': 'PHP Loops',
      'icon': Icons.loop,
      'color': Colors.purple,
      'topics': [
        'While Loop',
        'Do-While Loop',
        'For Loop',
        'Foreach Loop',
        'Break and Continue'
      ],
      'description': 'Learn looping structures in PHP',
    },
    {
      'title': 'PHP Functions',
      'icon': Icons.functions,
      'color': Colors.purple,
      'topics': [
        'Function Declaration',
        'Function Parameters',
        'Function Return',
        'Built-in Functions',
        'Recursive Functions'
      ],
      'description': 'Create and use functions in PHP',
    },
    {
      'title': 'PHP Forms',
      'icon': Icons.input,
      'color': Colors.purple,
      'topics': [
        'Form Handling',
        'GET Method',
        'POST Method',
        'Form Validation',
        'File Upload'
      ],
      'description': 'Handle form data in PHP',
    },
    {
      'title': 'PHP OOP',
      'icon': Icons.account_tree,
      'color': Colors.purple,
      'topics': [
        'Classes and Objects',
        'Constructors',
        'Destructors',
        'Access Modifiers',
        'Inheritance'
      ],
      'description': 'Object-oriented programming in PHP',
    },
    {
      'title': 'PHP MySQL',
      'icon': Icons.storage,
      'color': Colors.purple,
      'topics': [
        'Database Connection',
        'Create Database',
        'Create Table',
        'Insert Data',
        'Select Data'
      ],
      'description': 'Connect PHP with MySQL database',
    },
    {
      'title': 'PHP Sessions',
      'icon': Icons.security,
      'color': Colors.purple,
      'topics': [
        'Session Basics',
        'Start Session',
        'Session Variables',
        'Destroy Session',
        'Cookies'
      ],
      'description': 'Manage user sessions in PHP',
    },
    {
      'title': 'PHP File Handling',
      'icon': Icons.insert_drive_file,
      'color': Colors.purple,
      'topics': [
        'File Open/Read',
        'File Create/Write',
        'File Upload',
        'File Permissions',
        'Directory Functions'
      ],
      'description': 'Work with files in PHP',
    },
    {
      'title': 'PHP Error Handling',
      'icon': Icons.warning,
      'color': Colors.purple,
      'topics': [
        'Error Types',
        'Try-Catch Block',
        'Custom Error Handler',
        'Error Logging',
        'Exception Handling'
      ],
      'description': 'Handle errors and exceptions in PHP',
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
                        Icon(Icons.arrow_right, color: Colors.purple, size: 16),
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
                backgroundColor: Colors.purple,
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
      'PHP Introduction': 'php_introduction.md',
      'PHP Syntax': 'php_syntax.md',
      'PHP Variables': 'php_variables.md',
      'PHP Operators': 'php_operators.md',
      'PHP Strings': 'php_strings.md',
      'PHP Arrays': 'php_arrays.md',
      'PHP Conditions': 'php_conditions.md',
      'PHP Loops': 'php_loops.md',
      'PHP Functions': 'php_functions.md',
      'PHP Forms': 'php_forms.md',
      'PHP OOP': 'php_oop.md',
      'PHP MySQL': 'php_mysql.md',
      'PHP Sessions': 'php_sessions.md',
      'PHP File Handling': 'php_files_handling.md',
      'PHP Error Handling': 'php_error_handling.md',
    };

    final fileName = fileMap[module['title']] ?? 'php_introduction.md';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhpLearningScreen(
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
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Text(
                      topic,
                      style: TextStyle(
                        color: Colors.purple,
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
          'PHP Programming Tutorials',
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
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.developer_mode, color: Colors.purple, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'PHP Tutorials',
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
                    'Learn PHP server-side scripting step by step. Build dynamic websites with comprehensive tutorials.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.purple, size: 20),
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

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 20),
                itemCount: _phpModules.length,
                itemBuilder: (context, index) {
                  return _buildModuleItem(_phpModules[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
