import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'sql_practice_screen.dart';

class SqlLearningScreen extends StatefulWidget {
  final String moduleTitle;
  final String fileName;
  final Color primaryColor;

  const SqlLearningScreen({
    Key? key,
    required this.moduleTitle,
    required this.fileName,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<SqlLearningScreen> createState() => _SqlLearningScreenState();
}

class _SqlLearningScreenState extends State<SqlLearningScreen> {
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final content = await rootBundle.loadString('assets/tutorials/${widget.fileName}');
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = _getDefaultContent(widget.moduleTitle);
        _isLoading = false;
      });
    }
  }

  String _getDefaultContent(String moduleTitle) {
    switch (moduleTitle) {
      case 'SQL Introduction':
        return '''
SQL (Structured Query Language) is a standard language for managing and manipulating relational databases.

Key Features:
• Data Definition: Create and modify database structure
• Data Manipulation: Insert, update, delete data
• Data Querying: Retrieve data from databases
• Data Control: Manage permissions and security

SQL Sub-languages:
• DDL (Data Definition Language) - CREATE, ALTER, DROP
• DML (Data Manipulation Language) - SELECT, INSERT, UPDATE, DELETE
• DQL (Data Query Language) - SELECT
• DCL (Data Control Language) - GRANT, REVOKE
• TCL (Transaction Control Language) - COMMIT, ROLLBACK
''';

      case 'SQL Syntax':
        return '''
Basic SQL Structure:
SELECT column1, column2
FROM table_name
WHERE condition
ORDER BY column1;

Key Components:
• SELECT: Specifies columns to retrieve
• FROM: Specifies table(s) to query
• WHERE: Filters rows based on conditions
• ORDER BY: Sorts the result set
• GROUP BY: Groups rows with same values
• HAVING: Filters groups

Best Practices:
• Use uppercase for SQL keywords
• End statements with semicolons
• Use meaningful table and column names
• Always backup before major changes
''';

      case 'SQL SELECT':
        return '''
SELECT Statement:
The SELECT statement is used to select data from a database.

Basic Syntax:
SELECT column1, column2, ...
FROM table_name;

Examples:
• SELECT * FROM customers;
• SELECT name, email FROM users;
• SELECT id, product_name, price FROM products;

Key Features:
• Use * to select all columns
• Specify column names for specific data
• Can be combined with WHERE, ORDER BY, etc.
• Supports calculated columns and aliases

Best Practices:
• Avoid SELECT * in production
• Specify only needed columns
• Use meaningful column aliases
''';

      case 'SQL WHERE':
        return '''
WHERE Clause:
The WHERE clause is used to filter records.

Basic Syntax:
SELECT column1, column2
FROM table_name
WHERE condition;

Operators:
• = Equal
• <> or != Not equal
• > Greater than
• < Less than
• >= Greater than or equal
• <= Less than or equal
• BETWEEN Between a range
• LIKE Search for a pattern
• IN Multiple possible values

Examples:
• SELECT * FROM users WHERE age >= 18;
• SELECT * FROM products WHERE price < 100;
• SELECT * FROM employees WHERE department = 'Sales';
''';

      case 'SQL ORDER BY':
        return '''
ORDER BY Clause:
The ORDER BY keyword is used to sort the result set.

Basic Syntax:
SELECT column1, column2
FROM table_name
ORDER BY column1 [ASC|DESC];

Sorting Options:
• ASC - Ascending order (default)
• DESC - Descending order

Examples:
• SELECT * FROM users ORDER BY name ASC;
• SELECT * FROM products ORDER BY price DESC;
• SELECT * FROM employees ORDER BY hire_date ASC, last_name ASC;

Multiple Columns:
You can sort by multiple columns by separating them with commas.

Best Practices:
• Always specify ASC or DESC for clarity
• Use ORDER BY with LIMIT for pagination
''';

      case 'SQL INSERT':
        return '''
INSERT Statement:
The INSERT INTO statement is used to insert new records in a table.

Basic Syntax:
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...);

Examples:
• INSERT INTO users (name, email, age) VALUES ('John Doe', 'john@example.com', 30);
• INSERT INTO products (name, price) VALUES ('Laptop', 999.99);
• INSERT INTO employees (first_name, last_name) VALUES ('Jane', 'Smith');

Multiple Rows:
INSERT INTO table_name (column1, column2)
VALUES 
(value1, value2),
(value3, value4),
(value5, value6);

Best Practices:
• Always specify column names
• Ensure data types match
• Use transactions for multiple inserts
''';

      case 'SQL UPDATE':
        return '''
UPDATE Statement:
The UPDATE statement is used to modify existing records.

Basic Syntax:
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;

Examples:
• UPDATE users SET email = 'newemail@example.com' WHERE id = 1;
• UPDATE products SET price = 29.99 WHERE category = 'Electronics';
• UPDATE employees SET salary = salary * 1.1 WHERE department = 'Engineering';

Important Notes:
• Always use WHERE clause to avoid updating all rows
• Multiple columns can be updated in one statement
• Use transactions for critical updates

Best Practices:
• Backup before mass updates
• Test WHERE clause with SELECT first
• Use LIMIT if supported
''';

      case 'SQL DELETE':
        return '''
DELETE Statement:
The DELETE statement is used to delete existing records.

Basic Syntax:
DELETE FROM table_name WHERE condition;

Examples:
• DELETE FROM users WHERE id = 1;
• DELETE FROM products WHERE discontinued = true;
• DELETE FROM orders WHERE status = 'cancelled';

Important Warnings:
• Without WHERE clause, ALL records will be deleted
• Deleted data cannot be easily recovered
• Always use transactions for critical deletes

Best Practices:
• Backup before deletion
• Test WHERE clause with SELECT first
• Consider soft deletion (is_deleted flag)
• Use LIMIT if supported
''';

      case 'SQL Joins':
        return '''
SQL Joins:
JOIN clauses are used to combine rows from two or more tables.

Join Types:
• INNER JOIN: Returns records with matching values
• LEFT JOIN: Returns all left table records + matched right table
• RIGHT JOIN: Returns all right table records + matched left table
• FULL OUTER JOIN: Returns all records when there's a match

Examples:
• INNER JOIN: Get employees with departments
• LEFT JOIN: Get all customers and their orders (if any)
• RIGHT JOIN: Get all products and their categories

Best Practices:
• Use table aliases for readability
• Specify join conditions explicitly
• Use INNER JOIN for required relationships
''';

      case 'SQL Functions':
        return '''
SQL Functions:
Functions perform operations on data and return results.

Aggregate Functions:
• COUNT() - Count number of rows
• SUM() - Sum of values
• AVG() - Average of values
• MAX() - Maximum value
• MIN() - Minimum value

String Functions:
• CONCAT() - Join strings
• LENGTH() - String length
• UPPER()/LOWER() - Case conversion
• SUBSTRING() - Extract substring

Date Functions:
• NOW() - Current date/time
• DATE() - Extract date part
• YEAR() - Extract year

Examples:
• SELECT COUNT(*) FROM users;
• SELECT AVG(salary) FROM employees;
• SELECT UPPER(name) FROM customers;
''';

      case 'SQL Constraints':
        return '''
SQL Constraints:
Constraints enforce rules on data in tables.

Common Constraints:
• NOT NULL - Ensures column cannot have NULL
• UNIQUE - Ensures all values are different
• PRIMARY KEY - Unique identifier (NOT NULL + UNIQUE)
• FOREIGN KEY - Links to PRIMARY KEY in another table
• CHECK - Ensures values meet specific condition
• DEFAULT - Sets default value

Examples:
• CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100) NOT NULL);
• CREATE TABLE orders (id INT, user_id INT, FOREIGN KEY (user_id) REFERENCES users(id));
• CREATE TABLE products (price DECIMAL CHECK (price > 0));

Best Practices:
• Use meaningful primary keys
• Add foreign key constraints for relationships
• Use CHECK constraints for data validation
''';

      case 'SQL Indexes':
        return '''
SQL Indexes:
Indexes improve query performance by creating optimized data structures.

Creating Indexes:
CREATE INDEX index_name ON table_name (column1, column2);

Examples:
• CREATE INDEX idx_email ON users(email);
• CREATE INDEX idx_name ON employees(last_name, first_name);
• CREATE INDEX idx_category_price ON products(category, price);

When to Use Indexes:
• Frequently searched columns
• Columns used in WHERE clauses
• Columns used in JOIN conditions
• Columns used in ORDER BY

Best Practices:
• Don't over-index (slows down inserts/updates)
• Index columns used in WHERE, JOIN, ORDER BY
• Monitor index usage and performance
''';

      case 'SQL Subqueries':
        return '''
SQL Subqueries:
A subquery is a query nested inside another query.

Types of Subqueries:
• In WHERE clause: Compare against subquery result
• In FROM clause: Use subquery as temporary table
• In SELECT clause: Return single value per row
• Correlated subqueries: Reference outer query

Examples:
• SELECT name FROM products WHERE price > (SELECT AVG(price) FROM products);
• SELECT * FROM (SELECT name, salary FROM employees ORDER BY salary DESC LIMIT 5) AS top_earners;

Best Practices:
• Use EXISTS for existence checks
• Avoid nested subqueries when JOIN works better
• Test subqueries independently first
''';

      case 'SQL Transactions':
        return '''
SQL Transactions:
Transactions ensure database operations are completed as a single unit.

ACID Properties:
• Atomicity - All or nothing
• Consistency - Valid state transition
• Isolation - Concurrent transactions don't interfere
• Durability - Committed changes persist

Transaction Control:
• START TRANSACTION - Begin transaction
• COMMIT - Save changes permanently
• ROLLBACK - Undo changes

Examples:
• START TRANSACTION;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
  COMMIT;

Best Practices:
• Keep transactions short
• Handle errors with ROLLBACK
• Use appropriate isolation levels
''';

      case 'SQL Views':
        return '''
SQL Views:
Views are virtual tables based on SQL query results.

Creating Views:
CREATE VIEW view_name AS
SELECT column1, column2
FROM table_name
WHERE condition;

Examples:
• CREATE VIEW active_users AS SELECT * FROM users WHERE active = 1;
• CREATE VIEW customer_orders AS SELECT c.name, o.order_date, o.total FROM customers c JOIN orders o ON c.id = o.customer_id;

Benefits:
• Simplify complex queries
• Enhance security (hide sensitive data)
• Provide logical data abstraction

Best Practices:
• Use meaningful view names
• Document view purposes
• Avoid nesting views too deeply
''';

      default:
        return '''
# ${widget.moduleTitle}

## Content Coming Soon!

We're working hard to bring you comprehensive tutorials for this module.

### What you'll learn:
- Detailed explanations with examples
- Code snippets you can try
- Best practices and tips
- Real-world applications

Check back soon for the complete content!
''';
    }
  }

  void _startPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SqlPracticeScreen(
          moduleTitle: widget.moduleTitle,
          primaryColor: widget.primaryColor,
          language: 'SQL',
        ),
      ),
    );
  }

  Widget _buildContentSection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: widget.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeExample(String code, String language) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: widget.primaryColor, size: 16),
              SizedBox(width: 8),
              Text(
                'Example: $language',
                style: TextStyle(
                  color: widget.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          SelectableText(
            code,
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontFamily: 'Monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _getExampleCode(String moduleTitle) {
    switch (moduleTitle) {
      case 'SQL Introduction':
        return '''-- Create a simple table
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2)
);

-- Insert sample data
INSERT INTO employees (id, name, department, salary) 
VALUES 
(1, 'John Doe', 'Engineering', 75000),
(2, 'Jane Smith', 'Marketing', 65000),
(3, 'Mike Johnson', 'Engineering', 80000);

-- Basic SELECT query
SELECT * FROM employees;''';

      case 'SQL Syntax':
        return '''-- Basic SELECT with WHERE and ORDER BY
SELECT name, department, salary
FROM employees
WHERE salary > 70000
ORDER BY salary DESC;

-- Using aggregate functions
SELECT 
    department,
    COUNT(*) as employee_count,
    AVG(salary) as avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 70000;''';

      case 'SQL SELECT':
        return '''-- Select all columns
SELECT * FROM customers;

-- Select specific columns
SELECT first_name, last_name, email 
FROM users;

-- Select with calculated column
SELECT 
    product_name,
    price,
    price * 0.9 as discounted_price
FROM products;

-- Select with alias
SELECT 
    name AS customer_name,
    email AS customer_email
FROM customers;''';

      case 'SQL WHERE':
        return '''-- Equal to
SELECT * FROM users WHERE age = 25;

-- Greater than
SELECT * FROM products WHERE price > 100;

-- Multiple conditions
SELECT * FROM employees 
WHERE department = 'Sales' AND salary > 50000;

-- Using IN
SELECT * FROM customers 
WHERE country IN ('USA', 'Canada', 'UK');

-- Using LIKE for pattern matching
SELECT * FROM users 
WHERE email LIKE '%@gmail.com';''';

      case 'SQL ORDER BY':
        return '''-- Ascending order (default)
SELECT * FROM products ORDER BY price;

-- Descending order
SELECT * FROM employees ORDER BY hire_date DESC;

-- Multiple column sorting
SELECT * FROM students 
ORDER BY grade DESC, last_name ASC;

-- Using column position
SELECT name, department, salary 
FROM employees 
ORDER BY 3 DESC, 1 ASC;''';

      case 'SQL INSERT':
        return '''-- Insert single row
INSERT INTO users (name, email, age) 
VALUES ('John Doe', 'john@example.com', 30);

-- Insert multiple rows
INSERT INTO products (name, price, category) 
VALUES 
('Laptop', 999.99, 'Electronics'),
('Mouse', 25.50, 'Electronics'),
('Notebook', 5.99, 'Stationery');

-- Insert with SELECT
INSERT INTO archive_users (name, email)
SELECT name, email FROM users 
WHERE active = 0;''';

      case 'SQL UPDATE':
        return '''-- Update single column
UPDATE users SET email = 'newemail@example.com' 
WHERE id = 1;

-- Update multiple columns
UPDATE employees 
SET salary = salary * 1.1, 
    last_raise = CURRENT_DATE
WHERE department = 'Engineering';

-- Update with calculation
UPDATE products 
SET price = price * 0.9 
WHERE category = 'Clearance';

-- Update with subquery
UPDATE orders 
SET status = 'completed'
WHERE order_date < DATE_SUB(NOW(), INTERVAL 30 DAY);''';

      case 'SQL DELETE':
        return '''-- Delete specific row
DELETE FROM users WHERE id = 1;

-- Delete with condition
DELETE FROM products 
WHERE discontinued = true;

-- Delete using subquery
DELETE FROM orders 
WHERE customer_id IN (
    SELECT id FROM customers 
    WHERE inactive = true
);

-- Delete all rows (be careful!)
-- DELETE FROM table_name;''';

      case 'SQL Joins':
        return '''-- INNER JOIN
SELECT e.name, d.department_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;

-- LEFT JOIN
SELECT c.name, o.order_date, o.total
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;

-- Multiple JOINs
SELECT 
    e.name as employee_name,
    d.name as department_name,
    p.name as project_name
FROM employees e
JOIN departments d ON e.dept_id = d.id
JOIN projects p ON e.project_id = p.id;''';

      case 'SQL Functions':
        return '''-- Aggregate functions
SELECT 
    COUNT(*) as total_employees,
    AVG(salary) as average_salary,
    MAX(salary) as highest_salary,
    MIN(salary) as lowest_salary
FROM employees;

-- String functions
SELECT 
    UPPER(name) as uppercase_name,
    LENGTH(name) as name_length,
    CONCAT(first_name, ' ', last_name) as full_name
FROM users;

-- Date functions
SELECT 
    name,
    YEAR(birth_date) as birth_year,
    DATEDIFF(CURRENT_DATE, hire_date) as days_employed
FROM employees;''';

      case 'SQL Constraints':
        return '''-- Table with various constraints
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    salary DECIMAL(10,2) CHECK (salary > 0),
    dept_id INT,
    hire_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (dept_id) REFERENCES departments(id)
);

-- Adding constraints later
ALTER TABLE employees 
ADD CONSTRAINT chk_salary CHECK (salary > 0);

-- Creating index
CREATE INDEX idx_email ON users(email);''';

      case 'SQL Indexes':
        return '''-- Single column index
CREATE INDEX idx_last_name ON employees(last_name);

-- Composite index
CREATE INDEX idx_dept_salary 
ON employees(department, salary);

-- Unique index
CREATE UNIQUE INDEX idx_unique_email 
ON users(email);

-- Partial index (some databases)
CREATE INDEX idx_active_users 
ON users(email) 
WHERE active = true;

-- Dropping index
DROP INDEX idx_last_name ON employees;''';

      case 'SQL Subqueries':
        return '''-- Subquery in WHERE
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Subquery in SELECT
SELECT 
    name,
    salary,
    (SELECT AVG(salary) FROM employees) as avg_salary
FROM employees;

-- Correlated subquery
SELECT 
    e1.name,
    e1.salary,
    e1.department
FROM employees e1
WHERE salary > (
    SELECT AVG(salary) 
    FROM employees e2 
    WHERE e2.department = e1.department
);

-- EXISTS subquery
SELECT name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.customer_id = c.id
);''';

      case 'SQL Transactions':
        return '''-- Simple transaction
START TRANSACTION;

INSERT INTO accounts (id, balance) 
VALUES (1, 1000.00);

UPDATE accounts 
SET balance = balance - 100 
WHERE id = 1;

UPDATE accounts 
SET balance = balance + 100 
WHERE id = 2;

COMMIT;

-- Transaction with error handling
START TRANSACTION;

BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    -- Your SQL statements here
    UPDATE inventory SET quantity = quantity - 5 WHERE product_id = 101;
    INSERT INTO orders (product_id, quantity) VALUES (101, 5);
    
    COMMIT;
END;''';

      case 'SQL Views':
        return '''-- Simple view
CREATE VIEW active_customers AS
SELECT id, name, email, phone
FROM customers
WHERE active = 1;

-- View with join
CREATE VIEW order_summary AS
SELECT 
    o.id as order_id,
    c.name as customer_name,
    o.order_date,
    o.total_amount,
    o.status
FROM orders o
JOIN customers c ON o.customer_id = c.id;

-- View with aggregation
CREATE VIEW department_stats AS
SELECT 
    d.name as department_name,
    COUNT(e.id) as employee_count,
    AVG(e.salary) as avg_salary,
    MAX(e.salary) as max_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.dept_id
GROUP BY d.id, d.name;

-- Using the view
SELECT * FROM department_stats 
WHERE avg_salary > 50000;''';

      default:
        return '-- SQL Example Code\nSELECT * FROM example_table;';
    }
  }

  void _showQuizDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1B263B),
          title: Row(
            children: [
              Icon(Icons.quiz, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Quiz Feature',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Text(
            'Quiz feature coming soon! Practice your coding skills with the interactive practice exercises first.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          widget.moduleTitle,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1B263B),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.auto_awesome, color: widget.primaryColor),
            onPressed: () {
              // Additional features can be added here
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: widget.primaryColor),
            SizedBox(height: 16),
            Text(
              'Loading Tutorial...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: widget.primaryColor),
                      SizedBox(width: 12),
                      Text(
                        widget.moduleTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Learn step by step with examples and explanations',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Content Display
            _buildContentSection('Tutorial Content', _content),

            // Example Section
            _buildCodeExample(
              _getExampleCode(widget.moduleTitle),
              'SQL',
            ),

            // Practice Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fitness_center, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Practice Exercises',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Test your knowledge with interactive coding exercises:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _startPractice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        icon: Icon(Icons.play_arrow),
                        label: Text('Start Practice'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _showQuizDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue),
                        ),
                        icon: Icon(Icons.quiz),
                        label: Text('Take Quiz'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}