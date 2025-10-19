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
            'title': 'Basic SELECT Statement',
            'description': 'Retrieve all columns from the employees table',
            'starterCode': '-- Write your SQL query here\n',
            'solution': 'SELECT * FROM employees;',
            'hint': 'Use SELECT * to get all columns and FROM to specify the table',
            'testCases': ['SELECT', 'FROM', 'employees']
          },
          {
            'title': 'Specific Column Selection',
            'description': 'Select only the name and email columns from users table',
            'starterCode': '-- Select name and email columns\n',
            'solution': 'SELECT name, email FROM users;',
            'hint': 'List column names separated by commas after SELECT',
            'testCases': ['SELECT', 'name', 'email', 'FROM', 'users']
          },
          {
            'title': 'Multiple Table Query',
            'description': 'Select employee names and their department names',
            'starterCode': '-- Join employees and departments tables\n',
            'solution': 'SELECT e.name, d.department_name FROM employees e JOIN departments d ON e.dept_id = d.id;',
            'hint': 'Use JOIN to combine tables and ON to specify the join condition',
            'testCases': ['SELECT', 'JOIN', 'ON']
          }
        ];
        break;

      case 'SQL SELECT':
        _exercises = [
          {
            'title': 'Basic Data Retrieval',
            'description': 'Get all customer information from the customers table',
            'starterCode': '-- Retrieve all customer data\n',
            'solution': 'SELECT * FROM customers;',
            'hint': 'Use SELECT * to get all columns',
            'testCases': ['SELECT', 'FROM', 'customers']
          },
          {
            'title': 'Column Aliases',
            'description': 'Select product names with "Product Name" as column alias',
            'starterCode': '-- Use column aliases\n',
            'solution': 'SELECT name AS "Product Name", price AS "Cost" FROM products;',
            'hint': 'Use AS keyword to create column aliases',
            'testCases': ['SELECT', 'AS', 'FROM']
          },
          {
            'title': 'Calculated Columns',
            'description': 'Calculate total price (quantity * unit_price) from order_items',
            'starterCode': '-- Calculate total price\n',
            'solution': 'SELECT product_id, quantity, unit_price, quantity * unit_price AS total_price FROM order_items;',
            'hint': 'You can perform arithmetic operations in SELECT clause',
            'testCases': ['SELECT', '*', 'AS', 'FROM']
          }
        ];
        break;

      case 'SQL WHERE':
        _exercises = [
          {
            'title': 'Basic Filtering',
            'description': 'Find all employees with salary greater than 50000',
            'starterCode': '-- Filter employees by salary\n',
            'solution': 'SELECT * FROM employees WHERE salary > 50000;',
            'hint': 'Use WHERE clause with comparison operators',
            'testCases': ['SELECT', 'FROM', 'WHERE', '>']
          },
          {
            'title': 'Multiple Conditions',
            'description': 'Find products in Electronics category priced under 1000',
            'starterCode': '-- Use AND for multiple conditions\n',
            'solution': 'SELECT * FROM products WHERE category = \'Electronics\' AND price < 1000;',
            'hint': 'Use AND to combine multiple conditions',
            'testCases': ['WHERE', 'AND', '=']
          },
          {
            'title': 'Pattern Matching',
            'description': 'Find customers whose names start with "J"',
            'starterCode': '-- Use LIKE for pattern matching\n',
            'solution': 'SELECT * FROM customers WHERE name LIKE \'J%\';',
            'hint': 'LIKE operator with % wildcard matches any sequence of characters',
            'testCases': ['WHERE', 'LIKE']
          }
        ];
        break;

      case 'SQL ORDER BY':
        _exercises = [
          {
            'title': 'Basic Sorting',
            'description': 'Sort products by price in descending order',
            'starterCode': '-- Sort by price descending\n',
            'solution': 'SELECT * FROM products ORDER BY price DESC;',
            'hint': 'Use ORDER BY with DESC for descending order',
            'testCases': ['SELECT', 'ORDER BY', 'DESC']
          },
          {
            'title': 'Multiple Column Sorting',
            'description': 'Sort employees by department ascending, then salary descending',
            'starterCode': '-- Sort by multiple columns\n',
            'solution': 'SELECT * FROM employees ORDER BY department ASC, salary DESC;',
            'hint': 'List multiple columns separated by commas in ORDER BY',
            'testCases': ['ORDER BY', 'ASC', 'DESC']
          },
          {
            'title': 'Sort with Expressions',
            'description': 'Sort products by discounted price (price * 0.9)',
            'starterCode': '-- Sort by calculated expression\n',
            'solution': 'SELECT name, price, price * 0.9 AS discounted_price FROM products ORDER BY discounted_price DESC;',
            'hint': 'You can use column aliases in ORDER BY clause',
            'testCases': ['SELECT', 'AS', 'ORDER BY']
          }
        ];
        break;

      case 'SQL INSERT':
        _exercises = [
          {
            'title': 'Basic Insert',
            'description': 'Add a new customer to the customers table',
            'starterCode': '-- Insert new customer\n',
            'solution': 'INSERT INTO customers (name, email, phone) VALUES (\'John Doe\', \'john@example.com\', \'123-456-7890\');',
            'hint': 'Specify column names and corresponding values',
            'testCases': ['INSERT INTO', 'VALUES']
          },
          {
            'title': 'Insert Multiple Rows',
            'description': 'Add three new products in a single query',
            'starterCode': '-- Insert multiple products\n',
            'solution': 'INSERT INTO products (name, price, category) VALUES \n(\'Laptop\', 999.99, \'Electronics\'),\n(\'Mouse\', 29.99, \'Electronics\'),\n(\'Keyboard\', 79.99, \'Electronics\');',
            'hint': 'Separate multiple value sets with commas',
            'testCases': ['INSERT INTO', 'VALUES', '(', ')']
          },
          {
            'title': 'Insert from Select',
            'description': 'Copy active users to a premium_users table',
            'starterCode': '-- Insert from select statement\n',
            'solution': 'INSERT INTO premium_users (user_id, name, email) SELECT id, name, email FROM users WHERE active = 1;',
            'hint': 'Use SELECT statement instead of VALUES to insert from another table',
            'testCases': ['INSERT INTO', 'SELECT', 'FROM', 'WHERE']
          }
        ];
        break;

      case 'SQL UPDATE':
        _exercises = [
          {
            'title': 'Basic Update',
            'description': 'Increase all product prices by 10%',
            'starterCode': '-- Update product prices\n',
            'solution': 'UPDATE products SET price = price * 1.10;',
            'hint': 'Use SET to specify column updates',
            'testCases': ['UPDATE', 'SET', '=']
          },
          {
            'title': 'Conditional Update',
            'description': 'Give a 15% raise to employees in IT department',
            'starterCode': '-- Update with condition\n',
            'solution': 'UPDATE employees SET salary = salary * 1.15 WHERE department = \'IT\';',
            'hint': 'Use WHERE clause to specify which rows to update',
            'testCases': ['UPDATE', 'SET', 'WHERE']
          },
          {
            'title': 'Multiple Column Update',
            'description': 'Update both price and stock for a specific product',
            'starterCode': '-- Update multiple columns\n',
            'solution': 'UPDATE products SET price = 49.99, stock_quantity = 100 WHERE id = 5;',
            'hint': 'Separate multiple column updates with commas',
            'testCases': ['UPDATE', 'SET', 'WHERE']
          }
        ];
        break;

      case 'SQL DELETE':
        _exercises = [
          {
            'title': 'Basic Delete',
            'description': 'Remove a specific user by ID',
            'starterCode': '-- Delete specific user\n',
            'solution': 'DELETE FROM users WHERE id = 123;',
            'hint': 'Always use WHERE clause to avoid deleting all rows',
            'testCases': ['DELETE FROM', 'WHERE']
          },
          {
            'title': 'Conditional Delete',
            'description': 'Delete all inactive users older than 1 year',
            'starterCode': '-- Delete with multiple conditions\n',
            'solution': 'DELETE FROM users WHERE active = 0 AND created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);',
            'hint': 'Use AND to combine multiple conditions for deletion',
            'testCases': ['DELETE FROM', 'WHERE', 'AND']
          },
          {
            'title': 'Delete with Join',
            'description': 'Delete orders that have been cancelled for over 30 days',
            'starterCode': '-- Delete using join\n',
            'solution': 'DELETE o FROM orders o WHERE o.status = \'cancelled\' AND o.updated_at < DATE_SUB(NOW(), INTERVAL 30 DAY);',
            'hint': 'You can use table aliases in DELETE statements',
            'testCases': ['DELETE', 'FROM', 'WHERE']
          }
        ];
        break;

      case 'SQL Joins':
        _exercises = [
          {
            'title': 'INNER JOIN',
            'description': 'Get employee names with their department names',
            'starterCode': '-- Inner join employees and departments\n',
            'solution': 'SELECT e.name, d.department_name FROM employees e INNER JOIN departments d ON e.dept_id = d.id;',
            'hint': 'INNER JOIN returns only matching rows from both tables',
            'testCases': ['SELECT', 'INNER JOIN', 'ON']
          },
          {
            'title': 'LEFT JOIN',
            'description': 'Get all employees and their departments (include employees without departments)',
            'starterCode': '-- Left join to include all employees\n',
            'solution': 'SELECT e.name, d.department_name FROM employees e LEFT JOIN departments d ON e.dept_id = d.id;',
            'hint': 'LEFT JOIN returns all rows from left table and matching rows from right table',
            'testCases': ['SELECT', 'LEFT JOIN', 'ON']
          },
          {
            'title': 'Multiple Table Join',
            'description': 'Get order details with customer and product information',
            'starterCode': '-- Join three tables\n',
            'solution': 'SELECT o.order_date, c.name AS customer_name, p.name AS product_name, oi.quantity FROM orders o JOIN customers c ON o.customer_id = c.id JOIN order_items oi ON o.id = oi.order_id JOIN products p ON oi.product_id = p.id;',
            'hint': 'Chain multiple JOIN clauses to connect several tables',
            'testCases': ['JOIN', 'ON', 'AS']
          }
        ];
        break;

      case 'SQL Functions':
        _exercises = [
          {
            'title': 'Aggregate Functions',
            'description': 'Calculate total, average, max and min salary by department',
            'starterCode': '-- Use aggregate functions\n',
            'solution': 'SELECT department, COUNT(*) as employee_count, AVG(salary) as avg_salary, MAX(salary) as max_salary, MIN(salary) as min_salary FROM employees GROUP BY department;',
            'hint': 'Use GROUP BY with aggregate functions to get results per group',
            'testCases': ['SELECT', 'COUNT', 'AVG', 'MAX', 'MIN', 'GROUP BY']
          },
          {
            'title': 'String Functions',
            'description': 'Format customer names as "Last, First" and get email domains',
            'starterCode': '-- Use string functions\n',
            'solution': 'SELECT CONCAT(last_name, \', \', first_name) AS full_name, SUBSTRING_INDEX(email, \'@\', -1) AS domain FROM customers;',
            'hint': 'CONCAT combines strings, SUBSTRING_INDEX extracts parts of strings',
            'testCases': ['SELECT', 'CONCAT', 'AS', 'SUBSTRING_INDEX']
          },
          {
            'title': 'Date Functions',
            'description': 'Find employees hired in the last 30 days and calculate tenure',
            'starterCode': '-- Use date functions\n',
            'solution': 'SELECT name, hire_date, DATEDIFF(CURDATE(), hire_date) AS days_employed FROM employees WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);',
            'hint': 'CURDATE() gets current date, DATEDIFF calculates difference between dates',
            'testCases': ['SELECT', 'DATEDIFF', 'CURDATE', 'WHERE']
          }
        ];
        break;

      case 'SQL Constraints':
        _exercises = [
          {
            'title': 'Create Table with Constraints',
            'description': 'Create a users table with primary key, unique email, and check constraints',
            'starterCode': '-- Create table with constraints\n',
            'solution': 'CREATE TABLE users (\n    id INT PRIMARY KEY AUTO_INCREMENT,\n    username VARCHAR(50) NOT NULL UNIQUE,\n    email VARCHAR(255) NOT NULL UNIQUE,\n    age INT CHECK (age >= 18),\n    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n);',
            'hint': 'PRIMARY KEY, UNIQUE, NOT NULL, CHECK, and DEFAULT are common constraints',
            'testCases': ['CREATE TABLE', 'PRIMARY KEY', 'UNIQUE', 'NOT NULL', 'CHECK']
          },
          {
            'title': 'Add Foreign Key Constraint',
            'description': 'Add foreign key constraint to orders table referencing customers',
            'starterCode': '-- Add foreign key constraint\n',
            'solution': 'ALTER TABLE orders ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE;',
            'hint': 'Use ALTER TABLE with ADD CONSTRAINT to add foreign keys to existing tables',
            'testCases': ['ALTER TABLE', 'ADD CONSTRAINT', 'FOREIGN KEY', 'REFERENCES']
          },
          {
            'title': 'Add Check Constraint',
            'description': 'Add constraint to ensure product price is positive',
            'starterCode': '-- Add check constraint\n',
            'solution': 'ALTER TABLE products ADD CONSTRAINT chk_positive_price CHECK (price > 0);',
            'hint': 'CHECK constraints enforce domain integrity rules',
            'testCases': ['ALTER TABLE', 'ADD CONSTRAINT', 'CHECK']
          }
        ];
        break;

      case 'SQL Subqueries':
        _exercises = [
          {
            'title': 'Subquery in WHERE',
            'description': 'Find employees earning more than average salary',
            'starterCode': '-- Use subquery in WHERE clause\n',
            'solution': 'SELECT name, salary FROM employees WHERE salary > (SELECT AVG(salary) FROM employees);',
            'hint': 'Subqueries in WHERE must return a single value for comparison',
            'testCases': ['SELECT', 'WHERE', '>', 'SELECT', 'AVG', 'FROM']
          },
          {
            'title': 'Subquery in SELECT',
            'description': 'Show employee salary and department average salary',
            'starterCode': '-- Use subquery in SELECT\n',
            'solution': 'SELECT name, salary, (SELECT AVG(salary) FROM employees e2 WHERE e2.department = e1.department) AS dept_avg_salary FROM employees e1;',
            'hint': 'Scalar subqueries in SELECT must return exactly one row and one column',
            'testCases': ['SELECT', 'SELECT', 'AVG', 'FROM', 'WHERE', 'AS']
          },
          {
            'title': 'Correlated Subquery',
            'description': 'Find employees who earn more than their department average',
            'starterCode': '-- Use correlated subquery\n',
            'solution': 'SELECT name, salary, department FROM employees e1 WHERE salary > (SELECT AVG(salary) FROM employees e2 WHERE e2.department = e1.department);',
            'hint': 'Correlated subqueries reference columns from the outer query',
            'testCases': ['SELECT', 'WHERE', '>', 'SELECT', 'AVG', 'FROM', 'WHERE']
          }
        ];
        break;

      case 'SQL Views':
        _exercises = [
          {
            'title': 'Create Simple View',
            'description': 'Create a view showing active customers with their order counts',
            'starterCode': '-- Create a view\n',
            'solution': 'CREATE VIEW active_customer_orders AS\nSELECT c.id, c.name, c.email, COUNT(o.id) AS order_count\nFROM customers c\nLEFT JOIN orders o ON c.id = o.customer_id\nWHERE c.active = 1\nGROUP BY c.id, c.name, c.email;',
            'hint': 'Views are virtual tables based on SQL query results',
            'testCases': ['CREATE VIEW', 'SELECT', 'FROM', 'JOIN', 'WHERE', 'GROUP BY']
          },
          {
            'title': 'Create Complex View',
            'description': 'Create a sales summary view with totals by month and product',
            'starterCode': '-- Create sales summary view\n',
            'solution': 'CREATE VIEW monthly_sales_summary AS\nSELECT \n    YEAR(order_date) AS year,\n    MONTH(order_date) AS month,\n    p.name AS product_name,\n    SUM(oi.quantity) AS total_quantity,\n    SUM(oi.quantity * oi.unit_price) AS total_revenue\nFROM orders o\nJOIN order_items oi ON o.id = oi.order_id\nJOIN products p ON oi.product_id = p.id\nGROUP BY YEAR(order_date), MONTH(order_date), p.name;',
            'hint': 'Views can include calculations, aggregations, and multiple joins',
            'testCases': ['CREATE VIEW', 'SELECT', 'SUM', 'GROUP BY', 'JOIN']
          },
          {
            'title': 'Updateable View',
            'description': 'Create a view for updating product prices',
            'starterCode': '-- Create updateable view\n',
            'solution': 'CREATE VIEW product_prices AS\nSELECT id, name, price, category\nFROM products\nWHERE discontinued = 0\nWITH CHECK OPTION;',
            'hint': 'WITH CHECK OPTION ensures updates through view satisfy view definition',
            'testCases': ['CREATE VIEW', 'SELECT', 'FROM', 'WHERE', 'WITH CHECK OPTION']
          }
        ];
        break;

      case 'SQL Indexes':
        _exercises = [
          {
            'title': 'Create Single Column Index',
            'description': 'Create index on customer email for faster searches',
            'starterCode': '-- Create index on email\n',
            'solution': 'CREATE INDEX idx_customers_email ON customers(email);',
            'hint': 'Indexes improve query performance on frequently searched columns',
            'testCases': ['CREATE INDEX', 'ON']
          },
          {
            'title': 'Create Composite Index',
            'description': 'Create index on product category and price for better filtering',
            'starterCode': '-- Create composite index\n',
            'solution': 'CREATE INDEX idx_products_category_price ON products(category, price);',
            'hint': 'Composite indexes are useful for queries that filter on multiple columns',
            'testCases': ['CREATE INDEX', 'ON', '(']
          },
          {
            'title': 'Create Unique Index',
            'description': 'Create unique index on username to enforce uniqueness',
            'starterCode': '-- Create unique index\n',
            'solution': 'CREATE UNIQUE INDEX idx_users_username ON users(username);',
            'hint': 'Unique indexes enforce uniqueness and improve lookup performance',
            'testCases': ['CREATE UNIQUE INDEX', 'ON']
          }
        ];
        break;

      case 'SQL Transactions':
        _exercises = [
          {
            'title': 'Basic Transaction',
            'description': 'Transfer money between two accounts atomically',
            'starterCode': '-- Create money transfer transaction\n',
            'solution': 'START TRANSACTION;\nUPDATE accounts SET balance = balance - 100 WHERE id = 1;\nUPDATE accounts SET balance = balance + 100 WHERE id = 2;\nCOMMIT;',
            'hint': 'Use START TRANSACTION to begin and COMMIT to save changes',
            'testCases': ['START TRANSACTION', 'UPDATE', 'COMMIT']
          },
          {
            'title': 'Transaction with Rollback',
            'description': 'Process order with rollback on error condition',
            'starterCode': '-- Transaction with conditional rollback\n',
            'solution': 'START TRANSACTION;\nINSERT INTO orders (customer_id, total_amount) VALUES (123, 199.99);\nSET @order_id = LAST_INSERT_ID();\nINSERT INTO order_items (order_id, product_id, quantity) VALUES (@order_id, 456, 2);\nUPDATE products SET stock_quantity = stock_quantity - 2 WHERE id = 456;\n-- Check if stock is sufficient\nIF (SELECT stock_quantity FROM products WHERE id = 456) < 0 THEN\n    ROLLBACK;\nELSE\n    COMMIT;\nEND IF;',
            'hint': 'Use ROLLBACK to undo changes if conditions are not met',
            'testCases': ['START TRANSACTION', 'INSERT', 'UPDATE', 'ROLLBACK', 'COMMIT']
          },
          {
            'title': 'Savepoints',
            'description': 'Use savepoints for partial rollbacks in complex transactions',
            'starterCode': '-- Transaction with savepoints\n',
            'solution': 'START TRANSACTION;\nINSERT INTO orders (customer_id, total_amount) VALUES (123, 299.99);\nSAVEPOINT order_created;\nINSERT INTO order_items (order_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 456, 1);\nSAVEPOINT item_added;\n-- If something fails, rollback to specific savepoint\nROLLBACK TO SAVEPOINT order_created;\nCOMMIT;',
            'hint': 'SAVEPOINT allows partial rollbacks within a transaction',
            'testCases': ['START TRANSACTION', 'SAVEPOINT', 'ROLLBACK TO', 'COMMIT']
          }
        ];
        break;

      default:
        _exercises = [
          {
            'title': 'Basic SQL Query',
            'description': 'Write a simple SELECT query to get started',
            'starterCode': 'SELECT * FROM employees;',
            'solution': 'SELECT * FROM employees;',
            'hint': 'Start with SELECT * FROM table_name',
            'testCases': ['SELECT', 'FROM']
          }
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