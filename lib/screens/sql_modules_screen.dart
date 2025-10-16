import 'package:flutter/material.dart';

class SqlModulesScreen extends StatefulWidget {
  const SqlModulesScreen({super.key});

  @override
  State<SqlModulesScreen> createState() => _SqlModulesScreenState();
}

class _SqlModulesScreenState extends State<SqlModulesScreen> {
  final List<Map<String, dynamic>> _sqlModules = [
    {
      'title': 'SQL Introduction',
      'icon': Icons.play_arrow,
      'color': Colors.green,
      'topics': [
        'What is SQL?',
        'SQL vs NoSQL',
        'Database Concepts',
        'SQL Syntax',
        'Basic Queries'
      ],
      'description': 'Get started with SQL database language',
    },
    {
      'title': 'SQL Syntax',
      'icon': Icons.code,
      'color': Colors.green,
      'topics': [
        'SELECT Statement',
        'FROM Clause',
        'WHERE Clause',
        'ORDER BY',
        'DISTINCT'
      ],
      'description': 'Learn SQL basic syntax and structure',
    },
    {
      'title': 'SQL SELECT',
      'icon': Icons.search,
      'color': Colors.green,
      'topics': [
        'SELECT All Columns',
        'SELECT Specific Columns',
        'Column Aliases',
        'Calculated Columns',
        'SELECT TOP'
      ],
      'description': 'Master SELECT statement in SQL',
    },
    {
      'title': 'SQL WHERE',
      'icon': Icons.filter_list,
      'color': Colors.green,
      'topics': [
        'WHERE Clause Basics',
        'Comparison Operators',
        'AND, OR, NOT',
        'IN Operator',
        'BETWEEN Operator'
      ],
      'description': 'Filter data with WHERE clause',
    },
    {
      'title': 'SQL ORDER BY',
      'icon': Icons.sort,
      'color': Colors.green,
      'topics': [
        'Sort by Single Column',
        'Sort by Multiple Columns',
        'ASC and DESC',
        'NULL Sorting',
        'Custom Sorting'
      ],
      'description': 'Sort query results in SQL',
    },
    {
      'title': 'SQL INSERT',
      'icon': Icons.add,
      'color': Colors.green,
      'topics': [
        'INSERT INTO',
        'Insert Single Row',
        'Insert Multiple Rows',
        'Insert from Another Table',
        'INSERT with SELECT'
      ],
      'description': 'Add new data to database',
    },
    {
      'title': 'SQL UPDATE',
      'icon': Icons.edit,
      'color': Colors.green,
      'topics': [
        'UPDATE Statement',
        'Update Single Column',
        'Update Multiple Columns',
        'Update with WHERE',
        'Safe Updates'
      ],
      'description': 'Modify existing data in database',
    },
    {
      'title': 'SQL DELETE',
      'icon': Icons.delete,
      'color': Colors.green,
      'topics': [
        'DELETE Statement',
        'Delete Specific Rows',
        'Delete All Rows',
        'TRUNCATE TABLE',
        'Safe Deletes'
      ],
      'description': 'Remove data from database',
    },
    {
      'title': 'SQL Joins',
      'icon': Icons.link,
      'color': Colors.green,
      'topics': [
        'INNER JOIN',
        'LEFT JOIN',
        'RIGHT JOIN',
        'FULL JOIN',
        'Self Join'
      ],
      'description': 'Combine data from multiple tables',
    },
    {
      'title': 'SQL Functions',
      'icon': Icons.functions,
      'color': Colors.green,
      'topics': [
        'Aggregate Functions',
        'String Functions',
        'Date Functions',
        'Math Functions',
        'Group By'
      ],
      'description': 'Use built-in functions in SQL',
    },
    {
      'title': 'SQL Constraints',
      'icon': Icons.lock,
      'color': Colors.green,
      'topics': [
        'NOT NULL',
        'UNIQUE',
        'PRIMARY KEY',
        'FOREIGN KEY',
        'CHECK Constraint'
      ],
      'description': 'Enforce data integrity in SQL',
    },
    {
      'title': 'SQL Indexes',
      'icon': Icons.speed,
      'color': Colors.green,
      'topics': [
        'Create Index',
        'Drop Index',
        'Unique Index',
        'Composite Index',
        'When to Use Indexes'
      ],
      'description': 'Improve query performance with indexes',
    },
    {
      'title': 'SQL Views',
      'icon': Icons.remove_red_eye,
      'color': Colors.green,
      'topics': [
        'Create View',
        'Update View',
        'Drop View',
        'Materialized Views',
        'View Benefits'
      ],
      'description': 'Create and manage database views',
    },
    {
      'title': 'SQL Subqueries',
      'icon': Icons.find_in_page,
      'color': Colors.green,
      'topics': [
        'Subquery Basics',
        'WHERE Subqueries',
        'FROM Subqueries',
        'Correlated Subqueries',
        'EXISTS Operator'
      ],
      'description': 'Use subqueries in SQL statements',
    },
    {
      'title': 'SQL Transactions',
      'icon': Icons.sync,
      'color': Colors.green,
      'topics': [
        'BEGIN TRANSACTION',
        'COMMIT',
        'ROLLBACK',
        'Savepoints',
        'ACID Properties'
      ],
      'description': 'Manage database transactions',
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
                        Icon(Icons.arrow_right, color: Colors.green, size: 16),
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
                backgroundColor: Colors.green,
              ),
              child: Text('Start Learning'),
            ),
          ],
        );
      },
    );
  }

  void _startLearning(Map<String, dynamic> module) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Starting ${module['title']}...'),
        duration: Duration(seconds: 2),
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
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      topic,
                      style: TextStyle(
                        color: Colors.green,
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
          'SQL Database Tutorials',
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
                      Icon(Icons.storage, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'SQL Tutorials',
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
                    'Learn SQL database programming step by step. Master data manipulation and query optimization.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.green, size: 20),
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
                itemCount: _sqlModules.length,
                itemBuilder: (context, index) {
                  return _buildModuleItem(_sqlModules[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}