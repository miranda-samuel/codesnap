import 'package:flutter/material.dart';
import 'python_learning_screen.dart';

class PythonModulesScreen extends StatefulWidget {
  const PythonModulesScreen({super.key});

  @override
  State<PythonModulesScreen> createState() => _PythonModulesScreenState();
}

class _PythonModulesScreenState extends State<PythonModulesScreen> {
  final List<Map<String, dynamic>> _pythonModules = [
    {
      'title': 'Python Introduction',
      'icon': Icons.play_arrow,
      'color': Colors.yellow,
      'fileName': 'python_introduction.md',
      'topics': [
        'What is Python?',
        'Python Features',
        'Setting up Python',
        'First Python Program',
        'Python Syntax Basics'
      ],
      'description': 'Get started with Python programming',
    },
    {
      'title': 'Python Syntax',
      'icon': Icons.code,
      'color': Colors.yellow,
      'fileName': 'python_syntax.md',
      'topics': [
        'Variables and Data Types',
        'Indentation',
        'Comments',
        'Input/Output',
        'Operators'
      ],
      'description': 'Learn Python basic syntax and structure',
    },
    {
      'title': 'Python Variables',
      'icon': Icons.storage,
      'color': Colors.yellow,
      'fileName': 'python_variables.md',
      'topics': [
        'Variable Declaration',
        'Data Types',
        'Type Casting',
        'Variable Names',
        'Multiple Values'
      ],
      'description': 'Understand variables in Python',
    },
    {
      'title': 'Python Data Types',
      'icon': Icons.data_array,
      'color': Colors.yellow,
      'fileName': 'python_data_types.md',
      'topics': [
        'String Data Type',
        'Numeric Types',
        'Boolean Type',
        'Sequence Types',
        'Mapping Types'
      ],
      'description': 'Master Python data types',
    },
    {
      'title': 'Python Strings',
      'icon': Icons.text_fields,
      'color': Colors.yellow,
      'fileName': 'python_strings.md',
      'topics': [
        'String Basics',
        'String Slicing',
        'String Methods',
        'String Formatting',
        'Escape Characters'
      ],
      'description': 'Work with strings in Python',
    },
    {
      'title': 'Python Operators',
      'icon': Icons.calculate,
      'color': Colors.yellow,
      'fileName': 'python_operators.md',
      'topics': [
        'Arithmetic Operators',
        'Assignment Operators',
        'Comparison Operators',
        'Logical Operators',
        'Identity Operators'
      ],
      'description': 'Master operators in Python',
    },
    {
      'title': 'Python Lists',
      'icon': Icons.list,
      'color': Colors.yellow,
      'fileName': 'python_lists.md',
      'topics': [
        'List Basics',
        'Access List Items',
        'Change List Items',
        'List Methods',
        'List Comprehension'
      ],
      'description': 'Learn list manipulation in Python',
    },
    {
      'title': 'Python Tuples',
      'icon': Icons.view_array,
      'color': Colors.yellow,
      'fileName': 'python_tuples.md',
      'topics': [
        'Tuple Basics',
        'Access Tuple Items',
        'Update Tuples',
        'Unpack Tuples',
        'Tuple Methods'
      ],
      'description': 'Work with tuples in Python',
    },
    {
      'title': 'Python Sets',
      'icon': Icons.settings,
      'color': Colors.yellow,
      'fileName': 'python_sets.md',
      'topics': [
        'Set Basics',
        'Access Set Items',
        'Add Set Items',
        'Remove Set Items',
        'Set Methods'
      ],
      'description': 'Understand sets in Python',
    },
    {
      'title': 'Python Dictionaries',
      'icon': Icons.book,
      'color': Colors.yellow,
      'fileName': 'python_dictionaries.md',
      'topics': [
        'Dictionary Basics',
        'Access Items',
        'Change Items',
        'Add Items',
        'Dictionary Methods'
      ],
      'description': 'Master dictionaries in Python',
    },
    {
      'title': 'Python Conditions',
      'icon': Icons.settings,
      'color': Colors.yellow,
      'fileName': 'python_conditions.md',
      'topics': [
        'If Statement',
        'Else Statement',
        'Elif Statement',
        'Nested If',
        'Ternary Operator'
      ],
      'description': 'Control program flow with conditions',
    },
    {
      'title': 'Python Loops',
      'icon': Icons.loop,
      'color': Colors.yellow,
      'fileName': 'python_loops.md',
      'topics': [
        'While Loop',
        'For Loop',
        'Nested Loops',
        'Break Statement',
        'Continue Statement'
      ],
      'description': 'Learn looping structures in Python',
    },
    {
      'title': 'Python Functions',
      'icon': Icons.functions,
      'color': Colors.yellow,
      'fileName': 'python_functions.md',
      'topics': [
        'Function Definition',
        'Function Parameters',
        'Return Values',
        'Lambda Functions',
        'Recursion'
      ],
      'description': 'Create and use functions in Python',
    },
    {
      'title': 'Python Classes',
      'icon': Icons.account_tree,
      'color': Colors.yellow,
      'fileName': 'python_classes.md',
      'topics': [
        'Class Definition',
        'Create Object',
        'Init Function',
        'Class Methods',
        'Inheritance'
      ],
      'description': 'Object-oriented programming in Python',
    },
    {
      'title': 'Python Modules',
      'icon': Icons.extension,
      'color': Colors.yellow,
      'fileName': 'python_modules.md',
      'topics': [
        'Import Module',
        'Built-in Modules',
        'Create Module',
        'Dir Function',
        'Packages'
      ],
      'description': 'Work with modules in Python',
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
                        Icon(Icons.arrow_right, color: Colors.yellow, size: 16),
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
                backgroundColor: Colors.yellow,
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
      'Python Introduction': 'python_introduction.md',
      'Python Syntax': 'python_syntax.md',
      'Python Variables': 'python_variables.md',
      'Python Data Types': 'python data_types.md',
      'Python Strings': 'python_strings.md',
      'Python Operators': 'python_operators.md',
      'Python Lists': 'python_lists.md',
      'Python Tuples': 'python_tuples.md',
      'Python Sets': 'python_sets.md',
      'Python Dictionaries': 'python_dictionaries.md',
      'Python Conditions': 'python_conditions.md',
      'Python Loops': 'python_loops.md',
      'Python Functions': 'python_functions.md',
      'Python Classes': 'python_classes.md',
      'Python Modules': 'python_modules.md',
    };

    final fileName = fileMap[module['title']] ?? 'python_introduction.md';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PythonLearningScreen(
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
                      color: Colors.yellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                    ),
                    child: Text(
                      topic,
                      style: TextStyle(
                        color: Colors.yellow,
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
          'Python Programming Tutorials',
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
                      Icon(Icons.terminal, color: Colors.yellow, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Python Tutorials',
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
                    'Learn Python programming step by step. Versatile language for web development, data science, and automation.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.yellow, size: 20),
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
                itemCount: _pythonModules.length,
                itemBuilder: (context, index) {
                  return _buildModuleItem(_pythonModules[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}