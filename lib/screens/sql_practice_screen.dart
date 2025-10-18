import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/darcula.dart';

class SqlPracticeScreen extends StatefulWidget {
  final String moduleTitle;
  final Color primaryColor;
  final String language;

  const SqlPracticeScreen({
    Key? key,
    required this.moduleTitle,
    required this.primaryColor,
    required this.language,
  }) : super(key: key);

  @override
  State<SqlPracticeScreen> createState() => _SqlPracticeScreenState();
}

class _SqlPracticeScreenState extends State<SqlPracticeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final ScrollController _codeScrollController = ScrollController();
  final ScrollController _outputScrollController = ScrollController();
  String _output = '';
  bool _isRunning = false;
  int _currentExercise = 0;
  List<String> _codeLines = [];

  late List<Map<String, dynamic>> _exercises;

  @override
  void initState() {
    super.initState();
    _initializeExercises();
    _codeController.text = _exercises[_currentExercise]['starterCode'];
    _updateCodeLines();
    _codeController.addListener(_updateCodeLines);
  }

  void _updateCodeLines() {
    setState(() {
      _codeLines = _codeController.text.split('\n');
    });
  }

  void _initializeExercises() {
    switch (widget.moduleTitle) {
      case 'SQL Introduction':
        _exercises = [
          {
            'title': 'Basic SELECT Query',
            'description': 'Write a query to select all columns from the employees table',
            'starterCode': '-- Write your SQL query here\nSELECT ',
            'hint': 'Use SELECT * FROM table_name to select all columns',
            'solution': 'SELECT * FROM employees;',
            'testCases': ['id', 'name', 'department', 'salary']
          },
          {
            'title': 'Select Specific Columns',
            'description': 'Select only name and department columns from employees',
            'starterCode': '-- Select name and department columns\nSELECT ',
            'hint': 'Specify column names separated by commas after SELECT',
            'solution': 'SELECT name, department FROM employees;',
            'testCases': ['name', 'department']
          },
          {
            'title': 'Display Text with SELECT',
            'description': 'Display a welcome message using SELECT',
            'starterCode': '-- Display a welcome message\nSELECT ',
            'hint': 'Use SELECT with string literal: SELECT "Hello World"',
            'solution': 'SELECT "Welcome to SQL!" AS message;',
            'testCases': ['Welcome to SQL']
          },
        ];
        break;

      case 'SQL Syntax':
        _exercises = [
          {
            'title': 'Complete SELECT Statement',
            'description': 'Write a complete SELECT statement with FROM clause',
            'starterCode': '-- Complete the SELECT statement\n',
            'hint': 'Use SELECT column FROM table_name syntax',
            'solution': 'SELECT name, age FROM customers;',
            'testCases': ['name', 'age', 'customers']
          },
          {
            'title': 'WHERE Clause Practice',
            'description': 'Select customers from a specific city',
            'starterCode': '-- Select customers from London\nSELECT * FROM customers\n',
            'hint': 'Use WHERE clause to filter results: WHERE city = "London"',
            'solution': 'SELECT * FROM customers WHERE city = "London";',
            'testCases': ['WHERE', 'city', 'London']
          },
          {
            'title': 'ORDER BY Clause',
            'description': 'Sort products by price in descending order',
            'starterCode': '-- Sort products by price (highest first)\nSELECT * FROM products\n',
            'hint': 'Use ORDER BY column_name DESC for descending order',
            'solution': 'SELECT * FROM products ORDER BY price DESC;',
            'testCases': ['ORDER BY', 'price', 'DESC']
          },
        ];
        break;

      case 'SQL SELECT':
        _exercises = [
          {
            'title': 'Column Aliases',
            'description': 'Use aliases to rename columns in the output',
            'starterCode': '-- Rename columns using aliases\nSELECT ',
            'hint': 'Use AS keyword: SELECT column_name AS alias_name',
            'solution': 'SELECT name AS customer_name, age AS customer_age FROM customers;',
            'testCases': ['customer_name', 'customer_age']
          },
          {
            'title': 'Calculated Columns',
            'description': 'Calculate total price (quantity * unit_price)',
            'starterCode': '-- Calculate total price\nSELECT ',
            'hint': 'Use arithmetic operations in SELECT: quantity * unit_price',
            'solution': 'SELECT product_name, quantity * unit_price AS total_price FROM order_details;',
            'testCases': ['total_price', 'quantity', 'unit_price']
          },
          {
            'title': 'DISTINCT Values',
            'description': 'Get unique department names from employees',
            'starterCode': '-- Get unique departments\nSELECT ',
            'hint': 'Use DISTINCT keyword to remove duplicates',
            'solution': 'SELECT DISTINCT department FROM employees;',
            'testCases': ['DISTINCT', 'department']
          },
        ];
        break;

      case 'SQL WHERE':
        _exercises = [
          {
            'title': 'Basic WHERE Clause',
            'description': 'Find employees with salary greater than 50000',
            'starterCode': '-- Find high salary employees\nSELECT * FROM employees\n',
            'hint': 'Use WHERE with comparison operator: WHERE salary > 50000',
            'solution': 'SELECT * FROM employees WHERE salary > 50000;',
            'testCases': ['WHERE', 'salary', '>', '50000']
          },
          {
            'title': 'Multiple Conditions',
            'description': 'Find IT department employees with salary > 60000',
            'starterCode': '-- IT employees with high salary\nSELECT * FROM employees\n',
            'hint': 'Use AND operator to combine conditions',
            'solution': 'SELECT * FROM employees WHERE department = "IT" AND salary > 60000;',
            'testCases': ['AND', 'department', 'IT', 'salary', '60000']
          },
          {
            'title': 'IN Operator',
            'description': 'Find customers from specific cities',
            'starterCode': '-- Customers from London or Paris\nSELECT * FROM customers\n',
            'hint': 'Use IN operator: WHERE city IN ("London", "Paris")',
            'solution': 'SELECT * FROM customers WHERE city IN ("London", "Paris");',
            'testCases': ['IN', 'London', 'Paris']
          },
        ];
        break;

      case 'SQL ORDER BY':
        _exercises = [
          {
            'title': 'Single Column Sorting',
            'description': 'Sort products by name in alphabetical order',
            'starterCode': '-- Sort products by name\nSELECT * FROM products\n',
            'hint': 'Use ORDER BY column_name ASC (ASC is optional)',
            'solution': 'SELECT * FROM products ORDER BY product_name;',
            'testCases': ['ORDER BY', 'product_name']
          },
          {
            'title': 'Multiple Column Sorting',
            'description': 'Sort employees by department and then by salary descending',
            'starterCode': '-- Sort by department and salary\nSELECT * FROM employees\n',
            'hint': 'Use multiple columns in ORDER BY separated by commas',
            'solution': 'SELECT * FROM employees ORDER BY department, salary DESC;',
            'testCases': ['ORDER BY', 'department', 'salary', 'DESC']
          },
          {
            'title': 'NULL Values Sorting',
            'description': 'Sort products with NULL prices at the end',
            'starterCode': '-- Handle NULL values in sorting\nSELECT * FROM products\n',
            'hint': 'Use ORDER BY with NULLS LAST (syntax varies by database)',
            'solution': 'SELECT * FROM products ORDER BY price NULLS LAST;',
            'testCases': ['NULLS LAST']
          },
        ];
        break;

      case 'SQL INSERT':
        _exercises = [
          {
            'title': 'Insert Single Row',
            'description': 'Add a new employee to the employees table',
            'starterCode': '-- Insert a new employee\n',
            'hint': 'Use INSERT INTO table_name (columns) VALUES (values)',
            'solution': 'INSERT INTO employees (name, department, salary) VALUES ("John Doe", "IT", 75000);',
            'testCases': ['INSERT INTO', 'VALUES', 'John Doe', 'IT', '75000']
          },
          {
            'title': 'Insert Multiple Rows',
            'description': 'Add multiple customers at once',
            'starterCode': '-- Insert multiple customers\n',
            'hint': 'Use multiple value sets: VALUES (val1), (val2), (val3)',
            'solution': 'INSERT INTO customers (name, city) VALUES ("Alice", "London"), ("Bob", "Paris"), ("Charlie", "Berlin");',
            'testCases': ['Alice', 'Bob', 'Charlie', 'London', 'Paris', 'Berlin']
          },
          {
            'title': 'Insert from SELECT',
            'description': 'Copy data from one table to another',
            'starterCode': '-- Copy data to archive table\n',
            'hint': 'Use INSERT INTO table SELECT ... FROM source_table',
            'solution': 'INSERT INTO employee_archive SELECT * FROM employees WHERE hire_date < "2020-01-01";',
            'testCases': ['INSERT INTO', 'SELECT', 'FROM']
          },
        ];
        break;

      case 'SQL UPDATE':
        _exercises = [
          {
            'title': 'Update Single Column',
            'description': 'Increase all product prices by 10%',
            'starterCode': '-- Increase prices by 10%\n',
            'hint': 'Use UPDATE table_name SET column = new_value',
            'solution': 'UPDATE products SET price = price * 1.10;',
            'testCases': ['UPDATE', 'SET', 'price', '1.10']
          },
          {
            'title': 'Update with WHERE Clause',
            'description': 'Give a raise to IT department employees only',
            'starterCode': '-- Give raise to IT department\n',
            'hint': 'Use WHERE clause to specify which rows to update',
            'solution': 'UPDATE employees SET salary = salary + 5000 WHERE department = "IT";',
            'testCases': ['UPDATE', 'SET', 'WHERE', 'IT', '5000']
          },
          {
            'title': 'Update Multiple Columns',
            'description': 'Update both name and email of a customer',
            'starterCode': '-- Update customer information\n',
            'hint': 'Set multiple columns: SET col1 = val1, col2 = val2',
            'solution': 'UPDATE customers SET name = "John Smith", email = "john.smith@email.com" WHERE customer_id = 101;',
            'testCases': ['UPDATE', 'SET', 'name', 'email', 'WHERE']
          },
        ];
        break;

      case 'SQL DELETE':
        _exercises = [
          {
            'title': 'Delete Specific Rows',
            'description': 'Delete inactive customers',
            'starterCode': '-- Delete inactive customers\n',
            'hint': 'Use DELETE FROM table_name WHERE condition',
            'solution': 'DELETE FROM customers WHERE status = "inactive";',
            'testCases': ['DELETE FROM', 'WHERE', 'inactive']
          },
          {
            'title': 'Delete with Multiple Conditions',
            'description': 'Delete old orders with low amount',
            'starterCode': '-- Delete old small orders\n',
            'hint': 'Combine conditions with AND operator',
            'solution': 'DELETE FROM orders WHERE order_date < "2023-01-01" AND amount < 50;',
            'testCases': ['DELETE FROM', 'WHERE', 'AND', '2023-01-01', '50']
          },
          {
            'title': 'TRUNCATE Table',
            'description': 'Remove all data from a temporary table',
            'starterCode': '-- Clear temporary table\n',
            'hint': 'Use TRUNCATE TABLE for faster deletion of all rows',
            'solution': 'TRUNCATE TABLE temp_data;',
            'testCases': ['TRUNCATE TABLE']
          },
        ];
        break;

      case 'SQL Joins':
        _exercises = [
          {
            'title': 'INNER JOIN',
            'description': 'Combine orders with customer information',
            'starterCode': '-- Join orders with customers\nSELECT ',
            'hint': 'Use INNER JOIN with ON clause to specify join condition',
            'solution': 'SELECT orders.order_id, customers.customer_name, orders.order_date FROM orders INNER JOIN customers ON orders.customer_id = customers.customer_id;',
            'testCases': ['INNER JOIN', 'ON', 'customer_id']
          },
          {
            'title': 'LEFT JOIN',
            'description': 'Get all customers and their orders (if any)',
            'starterCode': '-- All customers with their orders\nSELECT ',
            'hint': 'Use LEFT JOIN to include all rows from left table',
            'solution': 'SELECT customers.customer_name, orders.order_id FROM customers LEFT JOIN orders ON customers.customer_id = orders.customer_id;',
            'testCases': ['LEFT JOIN', 'customers', 'orders']
          },
          {
            'title': 'Self Join',
            'description': 'Find employees and their managers',
            'starterCode': '-- Employees and their managers\nSELECT ',
            'hint': 'Join a table with itself using different aliases',
            'solution': 'SELECT e1.name AS employee, e2.name AS manager FROM employees e1 LEFT JOIN employees e2 ON e1.manager_id = e2.employee_id;',
            'testCases': ['employee', 'manager', 'manager_id']
          },
        ];
        break;

      case 'SQL Functions':
        _exercises = [
          {
            'title': 'Aggregate Functions',
            'description': 'Calculate average salary by department',
            'starterCode': '-- Average salary per department\nSELECT ',
            'hint': 'Use AVG() function with GROUP BY',
            'solution': 'SELECT department, AVG(salary) AS avg_salary FROM employees GROUP BY department;',
            'testCases': ['AVG', 'GROUP BY', 'department']
          },
          {
            'title': 'String Functions',
            'description': 'Display customer names in uppercase',
            'starterCode': '-- Uppercase customer names\nSELECT ',
            'hint': 'Use UPPER() function for string manipulation',
            'solution': 'SELECT UPPER(customer_name) AS name_upper FROM customers;',
            'testCases': ['UPPER', 'customer_name']
          },
          {
            'title': 'Date Functions',
            'description': 'Calculate age from birth date',
            'starterCode': '-- Calculate customer ages\nSELECT ',
            'hint': 'Use date functions like DATEDIFF or AGE (varies by database)',
            'solution': 'SELECT name, DATEDIFF(YEAR, birth_date, GETDATE()) AS age FROM customers;',
            'testCases': ['DATEDIFF', 'birth_date', 'age']
          },
        ];
        break;

      case 'SQL Constraints':
        _exercises = [
          {
            'title': 'NOT NULL Constraint',
            'description': 'Create a table with required fields',
            'starterCode': '-- Create table with NOT NULL constraints\nCREATE TABLE ',
            'hint': 'Add NOT NULL after column definition',
            'solution': 'CREATE TABLE users (user_id INT PRIMARY KEY, username VARCHAR(50) NOT NULL, email VARCHAR(100) NOT NULL);',
            'testCases': ['NOT NULL', 'PRIMARY KEY']
          },
          {
            'title': 'UNIQUE Constraint',
            'description': 'Ensure email addresses are unique',
            'starterCode': '-- Add unique constraint to email\nCREATE TABLE ',
            'hint': 'Use UNIQUE keyword for unique constraint',
            'solution': 'CREATE TABLE users (user_id INT PRIMARY KEY, email VARCHAR(100) UNIQUE);',
            'testCases': ['UNIQUE', 'email']
          },
          {
            'title': 'CHECK Constraint',
            'description': 'Ensure salary is positive',
            'starterCode': '-- Add check constraint for salary\nCREATE TABLE ',
            'hint': 'Use CHECK (condition) to validate data',
            'solution': 'CREATE TABLE employees (employee_id INT PRIMARY KEY, salary DECIMAL(10,2) CHECK (salary > 0));',
            'testCases': ['CHECK', 'salary', '>', '0']
          },
        ];
        break;

      case 'SQL Indexes':
        _exercises = [
          {
            'title': 'Create Index',
            'description': 'Create an index on email column for faster searches',
            'starterCode': '-- Create index on email column\n',
            'hint': 'Use CREATE INDEX index_name ON table_name (column)',
            'solution': 'CREATE INDEX idx_customer_email ON customers (email);',
            'testCases': ['CREATE INDEX', 'idx_customer_email', 'email']
          },
          {
            'title': 'Composite Index',
            'description': 'Create index on multiple columns',
            'starterCode': '-- Create composite index\n',
            'hint': 'Specify multiple columns in parentheses',
            'solution': 'CREATE INDEX idx_employee_dept_salary ON employees (department, salary);',
            'testCases': ['CREATE INDEX', 'department', 'salary']
          },
          {
            'title': 'Drop Index',
            'description': 'Remove an existing index',
            'starterCode': '-- Drop the email index\n',
            'hint': 'Use DROP INDEX index_name',
            'solution': 'DROP INDEX idx_customer_email;',
            'testCases': ['DROP INDEX']
          },
        ];
        break;

      case 'SQL Views':
        _exercises = [
          {
            'title': 'Create View',
            'description': 'Create a view for active customers only',
            'starterCode': '-- Create view for active customers\n',
            'hint': 'Use CREATE VIEW view_name AS SELECT ...',
            'solution': 'CREATE VIEW active_customers AS SELECT * FROM customers WHERE status = "active";',
            'testCases': ['CREATE VIEW', 'active_customers', 'WHERE']
          },
          {
            'title': 'Query View',
            'description': 'Use the view like a regular table',
            'starterCode': '-- Query the active customers view\nSELECT ',
            'hint': 'Select from view name instead of table name',
            'solution': 'SELECT * FROM active_customers;',
            'testCases': ['active_customers']
          },
          {
            'title': 'Drop View',
            'description': 'Remove the view',
            'starterCode': '-- Drop the view\n',
            'hint': 'Use DROP VIEW view_name',
            'solution': 'DROP VIEW active_customers;',
            'testCases': ['DROP VIEW']
          },
        ];
        break;

      case 'SQL Subqueries':
        _exercises = [
          {
            'title': 'Subquery in WHERE',
            'description': 'Find employees with above average salary',
            'starterCode': '-- Employees with above average salary\nSELECT * FROM employees\n',
            'hint': 'Use subquery in WHERE clause: WHERE salary > (SELECT AVG(salary)...)',
            'solution': 'SELECT * FROM employees WHERE salary > (SELECT AVG(salary) FROM employees);',
            'testCases': ['WHERE', '>', 'SELECT', 'AVG']
          },
          {
            'title': 'Subquery in SELECT',
            'description': 'Show employee count per department',
            'starterCode': '-- Employee count per department\nSELECT ',
            'hint': 'Use subquery in SELECT clause',
            'solution': 'SELECT department, (SELECT COUNT(*) FROM employees e2 WHERE e2.department = e1.department) AS emp_count FROM employees e1 GROUP BY department;',
            'testCases': ['SELECT', 'COUNT', 'GROUP BY']
          },
          {
            'title': 'EXISTS Operator',
            'description': 'Find customers who have placed orders',
            'starterCode': '-- Customers with orders\nSELECT * FROM customers\n',
            'hint': 'Use EXISTS with correlated subquery',
            'solution': 'SELECT * FROM customers c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);',
            'testCases': ['EXISTS', 'SELECT 1', 'customer_id']
          },
        ];
        break;

      case 'SQL Transactions':
        _exercises = [
          {
            'title': 'Basic Transaction',
            'description': 'Wrap multiple operations in a transaction',
            'starterCode': '-- Start a transaction\n',
            'hint': 'Use BEGIN TRANSACTION, COMMIT, ROLLBACK',
            'solution': 'BEGIN TRANSACTION;\nUPDATE accounts SET balance = balance - 100 WHERE account_id = 1;\nUPDATE accounts SET balance = balance + 100 WHERE account_id = 2;\nCOMMIT;',
            'testCases': ['BEGIN TRANSACTION', 'UPDATE', 'COMMIT']
          },
          {
            'title': 'Transaction Rollback',
            'description': 'Rollback changes on error',
            'starterCode': '-- Transaction with error handling\n',
            'hint': 'Use ROLLBACK to undo changes',
            'solution': 'BEGIN TRANSACTION;\nUPDATE products SET stock = stock - 5 WHERE product_id = 101;\n-- If error occurs:\nROLLBACK;',
            'testCases': ['BEGIN TRANSACTION', 'ROLLBACK']
          },
          {
            'title': 'Savepoints',
            'description': 'Use savepoints for partial rollback',
            'starterCode': '-- Transaction with savepoints\n',
            'hint': 'Use SAVEPOINT and ROLLBACK TO SAVEPOINT',
            'solution': 'BEGIN TRANSACTION;\nUPDATE table1 SET col1 = "value1";\nSAVEPOINT sp1;\nUPDATE table2 SET col2 = "value2";\nROLLBACK TO SAVEPOINT sp1;\nCOMMIT;',
            'testCases': ['SAVEPOINT', 'ROLLBACK TO']
          },
        ];
        break;

      default:
        _exercises = [
          {
            'title': 'Basic SQL Query',
            'description': 'Write a simple SELECT query',
            'starterCode': '-- Write your SQL query here\n',
            'hint': 'Start with SELECT * FROM table_name',
            'solution': 'SELECT * FROM employees;',
            'testCases': ['SELECT', 'FROM', 'employees']
          },
        ];
    }
  }

  void _runCode() {
    setState(() {
      _isRunning = true;
      _output = '🚀 Executing your SQL query...\n\n';
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isRunning = false;

        List<String> errors = _checkForErrors(_codeController.text);

        if (errors.isEmpty) {
          _output += '✅ Query executed successfully!\n';
          _output += '✅ No syntax errors found\n\n';

          String userOutput = _simulateQueryExecution(_codeController.text);
          _output += userOutput;

          _checkSolution(userOutput);
        } else {
          _output += '❌ Query execution failed!\n';
          _output += '❌ ${errors.length} error(s) found:\n\n';

          for (String error in errors) {
            _output += '• $error\n';
          }

          _output += '\n💡 Hint: ${_exercises[_currentExercise]['hint']}';
        }
      });
    });
  }

  List<String> _checkForErrors(String code) {
    List<String> errors = [];
    String upperCode = code.toUpperCase();

    // Check for basic SQL syntax
    if (!upperCode.contains('SELECT') &&
        !upperCode.contains('INSERT') &&
        !upperCode.contains('UPDATE') &&
        !upperCode.contains('DELETE') &&
        !upperCode.contains('CREATE') &&
        !upperCode.contains('DROP') &&
        !upperCode.contains('ALTER')) {
      errors.add('Missing SQL command (SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER)');
    }

    // Check for semicolon
    if (!code.trim().endsWith(';')) {
      errors.add('Missing semicolon (;) at the end of statement');
    }

    // Check for common syntax errors
    if (upperCode.contains('SELECT') && !upperCode.contains('FROM') && !upperCode.contains('VALUES')) {
      errors.add('SELECT statement requires FROM clause');
    }

    if (upperCode.contains('INSERT') && !upperCode.contains('INTO')) {
      errors.add('INSERT statement requires INTO keyword');
    }

    if (upperCode.contains('UPDATE') && !upperCode.contains('SET')) {
      errors.add('UPDATE statement requires SET clause');
    }

    // Check for unbalanced quotes
    int singleQuotes = _countOccurrences(code, "'");
    int doubleQuotes = _countOccurrences(code, '"');

    if (singleQuotes % 2 != 0) {
      errors.add('Unbalanced single quotes');
    }
    if (doubleQuotes % 2 != 0) {
      errors.add('Unbalanced double quotes');
    }

    // Check for parentheses balance
    int openParen = _countOccurrences(code, '(');
    int closeParen = _countOccurrences(code, ')');
    if (openParen != closeParen) {
      errors.add('Unbalanced parentheses');
    }

    return errors;
  }

  String _simulateQueryExecution(String code) {
    String upperCode = code.toUpperCase();
    String output = '';

    // Simulate different types of queries
    if (upperCode.contains('SELECT')) {
      output += 'Query Result:\n';
      output += '+----+------------+------------+----------+\n';
      output += '| ID | Name       | Department | Salary   |\n';
      output += '+----+------------+------------+----------+\n';
      output += '| 1  | John Doe   | IT         | 75000.00 |\n';
      output += '| 2  | Jane Smith | HR         | 65000.00 |\n';
      output += '| 3  | Bob Wilson | IT         | 80000.00 |\n';
      output += '+----+------------+------------+----------+\n';
      output += '3 rows returned\n\n';
    } else if (upperCode.contains('INSERT')) {
      output += 'Query OK, 1 row affected\n';
      output += 'Record inserted successfully\n\n';
    } else if (upperCode.contains('UPDATE')) {
      output += 'Query OK, 2 rows affected\n';
      output += 'Rows matched: 2  Changed: 2  Warnings: 0\n\n';
    } else if (upperCode.contains('DELETE')) {
      output += 'Query OK, 1 row affected\n';
      output += 'Record deleted successfully\n\n';
    } else if (upperCode.contains('CREATE')) {
      output += 'Query OK, 0 rows affected\n';
      output += 'Table/View/Index created successfully\n\n';
    } else if (upperCode.contains('DROP')) {
      output += 'Query OK, 0 rows affected\n';
      output += 'Table/View/Index dropped successfully\n\n';
    }

    // Add execution details
    output += 'Execution time: 0.045 seconds\n';
    output += 'Rows affected: 1\n';

    return output;
  }

  int _countOccurrences(String text, String pattern) {
    int count = 0;
    int index = 0;
    while ((index = text.indexOf(pattern, index)) != -1) {
      count++;
      index += pattern.length;
    }
    return count;
  }

  void _checkSolution(String userOutput) {
    List<String> testCases = List<String>.from(_exercises[_currentExercise]['testCases'] ?? []);
    String userCode = _codeController.text.toUpperCase();
    bool allTestsPassed = true;
    List<String> failedTests = [];

    for (String testCase in testCases) {
      if (!userCode.contains(testCase.toUpperCase())) {
        allTestsPassed = false;
        failedTests.add(testCase);
      }
    }

    if (allTestsPassed) {
      _output += '\n🎉 All requirements met! Excellent work!\n';
      _output += '✅ Your query follows best practices\n';
    } else {
      _output += '\n⚠️  Some requirements missing:\n';
      for (String failedTest in failedTests) {
        _output += '   • Should include: $failedTest\n';
      }
    }
  }

  void _showHint() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1B263B),
          title: Text(
            '💡 Hint - ${_exercises[_currentExercise]['title']}',
            style: TextStyle(color: widget.primaryColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _exercises[_currentExercise]['hint'],
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 16),
                if (_exercises[_currentExercise]['testCases'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Elements:',
                        style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      for (String testCase in _exercises[_currentExercise]['testCases'])
                        Text('• $testCase', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showSolution() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1B263B),
          title: Text(
            '💡 Solution - ${_exercises[_currentExercise]['title']}',
            style: TextStyle(color: widget.primaryColor),
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: HighlightView(
                _exercises[_currentExercise]['solution'],
                language: 'sql',
                theme: darculaTheme,
                textStyle: TextStyle(
                  fontFamily: 'Monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.tealAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _codeController.text = _exercises[_currentExercise]['solution'];
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Apply Solution', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _nextExercise() {
    if (_currentExercise < _exercises.length - 1) {
      setState(() {
        _currentExercise++;
        _codeController.text = _exercises[_currentExercise]['starterCode'];
        _output = '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Congratulations! You completed all SQL exercises!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _previousExercise() {
    if (_currentExercise > 0) {
      setState(() {
        _currentExercise--;
        _codeController.text = _exercises[_currentExercise]['starterCode'];
        _output = '';
      });
    }
  }

  void _resetCode() {
    setState(() {
      _codeController.text = _exercises[_currentExercise]['starterCode'];
      _output = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          'SQL IDE - ${widget.moduleTitle}',
          style: TextStyle(color: Colors.white, fontSize: screenWidth < 360 ? 16 : 18),
        ),
        backgroundColor: Color(0xFF1B263B),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info, color: Colors.tealAccent),
            onPressed: _showHint,
            tooltip: 'Hint',
          ),
        ],
      ),
      body: Column(
        children: [
          // Exercise Info
          Container(
            padding: EdgeInsets.all(screenWidth < 360 ? 12 : 16),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              border: Border.all(color: widget.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.storage,
                        color: widget.primaryColor,
                        size: screenWidth < 360 ? 18 : 24),
                    SizedBox(width: 8),
                    Text(
                      'Exercise ${_currentExercise + 1} of ${_exercises.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 360 ? 14 : 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  _exercises[_currentExercise]['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth < 360 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  _exercises[_currentExercise]['description'],
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth < 360 ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),

          // Code Editor and Output - Responsive Layout
          Expanded(
            child: isPortrait
                ? _buildPortraitLayout(screenWidth)
                : _buildLandscapeLayout(screenWidth),
          ),

          // Control Buttons - Responsive
          Container(
            padding: EdgeInsets.all(screenWidth < 360 ? 12 : 16),
            decoration: BoxDecoration(
              color: Color(0xFF1B263B),
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3))),
            ),
            child: _buildControlButtons(screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(double screenWidth) {
    return Column(
      children: [
        // Code Editor with Syntax Highlighting
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(screenWidth < 360 ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '📝 SQL Query Editor',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth < 360 ? 14 : 16,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.refresh,
                            color: Colors.grey,
                            size: screenWidth < 360 ? 18 : 24),
                        onPressed: _resetCode,
                        tooltip: 'Reset Query',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: _calculateEditorHeight(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: Row(
                        children: [
                          // Line Numbers
                          Container(
                            width: 40,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: ListView.builder(
                              controller: _codeScrollController,
                              itemCount: _codeLines.length,
                              itemBuilder: (context, index) {
                                return Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: screenWidth < 360 ? 10 : 12,
                                    fontFamily: 'Monospace',
                                  ),
                                  textAlign: TextAlign.right,
                                );
                              },
                            ),
                          ),
                          // Code Editor
                          Expanded(
                            child: Stack(
                              children: [
                                // Syntax Highlighting Background
                                Container(
                                  color: Colors.black,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: HighlightView(
                                      _codeController.text,
                                      language: 'sql',
                                      theme: darculaTheme,
                                      textStyle: TextStyle(
                                        fontFamily: 'Monospace',
                                        fontSize: screenWidth < 360 ? 12 : 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                // TextField for Editing
                                TextField(
                                  controller: _codeController,
                                  maxLines: null,
                                  expands: true,
                                  style: TextStyle(
                                    color: Colors.transparent,
                                    fontFamily: 'Monospace',
                                    fontSize: screenWidth < 360 ? 12 : 14,
                                    height: 1.3,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(12),
                                    filled: false,
                                  ),
                                  cursorColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Output Panel
        Expanded(
          child: Container(
            padding: EdgeInsets.all(screenWidth < 360 ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '📊 Query Result',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 360 ? 14 : 16,
                      ),
                    ),
                    Spacer(),
                    if (_output.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear,
                            color: Colors.grey,
                            size: screenWidth < 360 ? 16 : 20),
                        onPressed: () => setState(() { _output = ''; }),
                        tooltip: 'Clear Output',
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    padding: EdgeInsets.all(screenWidth < 360 ? 8 : 12),
                    child: SingleChildScrollView(
                      controller: _outputScrollController,
                      child: Text(
                        _output.isEmpty ? '🚀 Click "Run Query" to execute your SQL...' : _output,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Monospace',
                          fontSize: screenWidth < 360 ? 10 : 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(double screenWidth) {
    return Row(
      children: [
        // Code Editor
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '📝 SQL Query Editor',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth < 600 ? 14 : 16,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.refresh,
                            color: Colors.grey,
                            size: screenWidth < 600 ? 18 : 24),
                        onPressed: _resetCode,
                        tooltip: 'Reset Query',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: _calculateEditorHeight(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: Row(
                        children: [
                          // Line Numbers
                          Container(
                            width: 40,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: ListView.builder(
                              controller: _codeScrollController,
                              itemCount: _codeLines.length,
                              itemBuilder: (context, index) {
                                return Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: screenWidth < 600 ? 10 : 12,
                                    fontFamily: 'Monospace',
                                  ),
                                  textAlign: TextAlign.right,
                                );
                              },
                            ),
                          ),
                          // Code Editor
                          Expanded(
                            child: Stack(
                              children: [
                                // Syntax Highlighting Background
                                Container(
                                  color: Colors.black,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: HighlightView(
                                      _codeController.text,
                                      language: 'sql',
                                      theme: darculaTheme,
                                      textStyle: TextStyle(
                                        fontFamily: 'Monospace',
                                        fontSize: screenWidth < 600 ? 12 : 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                // TextField for Editing
                                TextField(
                                  controller: _codeController,
                                  maxLines: null,
                                  expands: true,
                                  style: TextStyle(
                                    color: Colors.transparent,
                                    fontFamily: 'Monospace',
                                    fontSize: screenWidth < 600 ? 12 : 14,
                                    height: 1.3,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(12),
                                    filled: false,
                                  ),
                                  cursorColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Output Panel
        Expanded(
          child: Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '📊 Query Result',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 600 ? 14 : 16,
                      ),
                    ),
                    Spacer(),
                    if (_output.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear,
                            color: Colors.grey,
                            size: screenWidth < 600 ? 16 : 20),
                        onPressed: () => setState(() { _output = ''; }),
                        tooltip: 'Clear Output',
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    padding: EdgeInsets.all(screenWidth < 600 ? 8 : 12),
                    child: SingleChildScrollView(
                      child: Text(
                        _output.isEmpty ? '🚀 Click "Run Query" to execute your SQL...' : _output,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Monospace',
                          fontSize: screenWidth < 600 ? 10 : 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _calculateEditorHeight() {
    int lineCount = _codeLines.length;
    double baseHeight = 40.0;
    double lineHeight = 20.0;

    double calculatedHeight = baseHeight + (lineCount * lineHeight);
    double maxHeight = MediaQuery.of(context).size.height * 0.7;

    return calculatedHeight.clamp(200.0, maxHeight);
  }

  Widget _buildControlButtons(double screenWidth) {
    bool isSmallScreen = screenWidth < 360;
    double buttonFontSize = isSmallScreen ? 12 : 14;
    double iconSize = isSmallScreen ? 14 : 16;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: _previousExercise,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.3),
            padding: isSmallScreen ? EdgeInsets.symmetric(horizontal: 8, vertical: 6) : null,
          ),
          icon: Icon(Icons.arrow_back, size: iconSize),
          label: Text('Previous', style: TextStyle(fontSize: buttonFontSize)),
        ),

        ElevatedButton.icon(
          onPressed: _nextExercise,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.3),
            padding: isSmallScreen ? EdgeInsets.symmetric(horizontal: 8, vertical: 6) : null,
          ),
          icon: Icon(Icons.arrow_forward, size: iconSize),
          label: Text('Next', style: TextStyle(fontSize: buttonFontSize)),
        ),

        OutlinedButton.icon(
          onPressed: _showHint,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: BorderSide(color: Colors.orange),
            padding: isSmallScreen ? EdgeInsets.symmetric(horizontal: 8, vertical: 6) : null,
          ),
          icon: Icon(Icons.lightbulb, size: iconSize),
          label: Text('Hint', style: TextStyle(fontSize: buttonFontSize)),
        ),

        OutlinedButton.icon(
          onPressed: _showSolution,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: BorderSide(color: Colors.red),
            padding: isSmallScreen ? EdgeInsets.symmetric(horizontal: 8, vertical: 6) : null,
          ),
          icon: Icon(Icons.visibility, size: iconSize),
          label: Text('Solution', style: TextStyle(fontSize: buttonFontSize)),
        ),

        ElevatedButton.icon(
          onPressed: _isRunning ? null : _runCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            padding: isSmallScreen ? EdgeInsets.symmetric(horizontal: 12, vertical: 6) : null,
          ),
          icon: _isRunning
              ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Icon(Icons.play_arrow, size: iconSize),
          label: Text(
              _isRunning ? 'Running...' : 'Run Query',
              style: TextStyle(fontSize: buttonFontSize)
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeScrollController.dispose();
    _outputScrollController.dispose();
    super.dispose();
  }
}