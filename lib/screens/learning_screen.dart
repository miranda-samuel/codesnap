import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'cpp_practice_screen.dart';
import 'java_practice_screen.dart';
import 'php_practice_screen.dart';
import 'python_practice_screen.dart';
import 'sql_practice_screen.dart';

class LearningScreen extends StatefulWidget {
  final String moduleTitle;
  final String fileName;
  final Color primaryColor;

  const LearningScreen({
    Key? key,
    required this.moduleTitle,
    required this.fileName,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
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
        _content = '''
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
        _isLoading = false;
      });
    }
  }

  void _startPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (widget.fileName.contains('java')) {
            return JavaPracticeScreen(
              moduleTitle: widget.moduleTitle,
              primaryColor: widget.primaryColor,
              language: 'Java',
            );
          } else if (widget.fileName.contains('php')) {
            return PhpPracticeScreen(
              moduleTitle: widget.moduleTitle,
              primaryColor: widget.primaryColor,
              language: 'PHP',
            );
          } else if (widget.fileName.contains('python')) {
            return PythonPracticeScreen(
              moduleTitle: widget.moduleTitle,
              primaryColor: widget.primaryColor,
              language: 'Python',
            );
          } else if (widget.fileName.contains('sql')) {
            return SqlPracticeScreen(
              moduleTitle: widget.moduleTitle,
              primaryColor: widget.primaryColor,
              language: 'SQL',
            );
          } else {
            return CppPracticeScreen(
              moduleTitle: widget.moduleTitle,
              primaryColor: widget.primaryColor,
              language: 'C++',
            );
          }
        },
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
            onPressed: () {},
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
            _buildContentSection('Introduction', _content),
            _buildCodeExample(
              _getExampleCode(widget.moduleTitle, widget.fileName),
              _getLanguageName(widget.fileName),
            ),

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
                        onPressed: () {
                          _showQuizDialog();
                        },
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

  String _getExampleCode(String moduleTitle, String fileName) {
    if (fileName.contains('php')) {
      return _getPhpExampleCode(moduleTitle);
    }
    if (fileName.contains('java')) {
      return _getJavaExampleCode(moduleTitle);
    }
    if (fileName.contains('cpp')) {
      return _getCppExampleCode(moduleTitle);
    }
    if (moduleTitle.contains('Introduction')) {
      return '''
// Sample Code for ${moduleTitle}
#include <iostream>
using namespace std;

int main() {
    cout << "Hello, World!";
    return 0;
}
      ''';
    }
    return '// Example code for ${moduleTitle}';
  }
  String _getSqlExampleCode(String moduleTitle) {
    if (moduleTitle.contains('Introduction')) {
      return '''
-- SQL Introduction Example
SELECT 'Hello, SQL World!' AS greeting;

-- Basic SELECT statement
SELECT * FROM employees;

-- Selecting specific columns
SELECT first_name, last_name, salary 
FROM employees;

-- Simple WHERE clause
SELECT first_name, last_name
FROM employees
WHERE salary > 50000;
    ''';
    } else if (moduleTitle.contains('SELECT')) {
      return '''
-- SQL SELECT Examples

-- Select all columns
SELECT * FROM customers;

-- Select specific columns
SELECT customer_id, customer_name, city
FROM customers;

-- Using column aliases
SELECT 
    customer_id AS ID,
    customer_name AS Name,
    email AS Email_Address
FROM customers;

-- Calculated columns
SELECT 
    product_name,
    unit_price,
    quantity,
    unit_price * quantity AS total_value
FROM order_details;

-- Using DISTINCT
SELECT DISTINCT city FROM customers;

-- SELECT TOP (or LIMIT in some databases)
SELECT TOP 10 * FROM products;
-- OR
SELECT * FROM products LIMIT 10;
    ''';
    } else if (moduleTitle.contains('WHERE')) {
      return '''
-- SQL WHERE Clause Examples

-- Basic WHERE clause
SELECT * FROM employees
WHERE department = 'Sales';

-- Comparison operators
SELECT * FROM products
WHERE price > 100;

SELECT * FROM orders
WHERE order_date >= '2024-01-01';

-- AND operator
SELECT * FROM customers
WHERE country = 'USA' AND city = 'New York';

-- OR operator
SELECT * FROM products
WHERE category = 'Electronics' OR category = 'Computers';

-- NOT operator
SELECT * FROM employees
WHERE NOT department = 'HR';

-- IN operator
SELECT * FROM customers
WHERE country IN ('USA', 'Canada', 'UK');

-- BETWEEN operator
SELECT * FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';

-- LIKE operator for pattern matching
SELECT * FROM customers
WHERE customer_name LIKE 'A%';  -- Names starting with A

SELECT * FROM products
WHERE product_name LIKE '%phone%';  -- Names containing 'phone'
    ''';
    } else if (moduleTitle.contains('JOIN')) {
      return '''
-- SQL JOIN Examples

-- INNER JOIN
SELECT 
    o.order_id,
    c.customer_name,
    o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- LEFT JOIN
SELECT 
    c.customer_name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- RIGHT JOIN
SELECT 
    o.order_id,
    c.customer_name
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.customer_id;

-- FULL JOIN
SELECT 
    c.customer_name,
    o.order_id
FROM customers c
FULL JOIN orders o ON c.customer_id = o.customer_id;

-- Self Join
SELECT 
    e1.employee_name AS Employee,
    e2.employee_name AS Manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.employee_id;

-- Multiple Joins
SELECT 
    o.order_id,
    c.customer_name,
    p.product_name,
    od.quantity
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id;
    ''';
    }

    return '''
-- SQL Example for ${moduleTitle}
SELECT 'SQL example query' AS result;
  ''';
  }
  // FIXED: Dollar signs properly escaped with backslash
  String _getPhpExampleCode(String moduleTitle) {
    if (moduleTitle.contains('Introduction')) {
      return r'''
<?php
// PHP Introduction Example
echo "Hello, World!";
echo "Welcome to PHP Programming!";

// Variables
$name = "John";
$age = 25;

echo "Name: " . $name;
echo "Age: " . $age;
?>
      ''';
    } else if (moduleTitle.contains('Syntax')) {
      return r'''
<?php
// PHP Syntax Example

// Variables and Data Types
$stringVar = "Hello PHP";
$intVar = 42;
$floatVar = 3.14;
$boolVar = true;
$arrayVar = array("apple", "banana", "cherry");

// Output
echo $stringVar;
print_r($arrayVar);
var_dump($intVar);

// Comments
// This is a single-line comment
# This is also a single-line comment
/*
This is a
multi-line comment
*/
?>
      ''';
    } else if (moduleTitle.contains('Variables')) {
      return r'''
<?php
// PHP Variables Example

// Variable declaration
$name = "Maria";
$age = 30;
$salary = 50000.50;
$isEmployed = true;

// Variable scope
$globalVar = "I'm global";

function testFunction() {
    global $globalVar;
    $localVar = "I'm local";
    echo $globalVar;
    echo $localVar;
}

// Static variable
function counter() {
    static $count = 0;
    $count++;
    echo "Count: $count";
}

counter(); // Count: 1
counter(); // Count: 2
counter(); // Count: 3

// Variable variables
$car = "Toyota";
$$car = "Camry"; // Creates $Toyota variable

echo $Toyota; // Output: Camry
?>
      ''';
    } else if (moduleTitle.contains('Operators')) {
      return r'''
<?php
// PHP Operators Example

// Arithmetic operators
$a = 15;
$b = 4;

echo "a + b = " . ($a + $b) . "\n";
echo "a - b = " . ($a - $b) . "\n";
echo "a * b = " . ($a * $b) . "\n";
echo "a / b = " . ($a / $b) . "\n";
echo "a % b = " . ($a % $b) . "\n";

// Comparison operators
echo "a == b: " . ($a == $b) . "\n";
echo "a != b: " . ($a != $b) . "\n";
echo "a > b: " . ($a > $b) . "\n";
echo "a < b: " . ($a < $b) . "\n";

// Logical operators
$x = true;
$y = false;

echo "x && y: " . ($x && $y) . "\n";
echo "x || y: " . ($x || $y) . "\n";
echo "!x: " . (!$x) . "\n";

// String operators
$str1 = "Hello";
$str2 = "World";
echo $str1 . " " . $str2 . "\n";

// Assignment operators
$c = 10;
$c += 5;  // $c = $c + 5
echo "c after += 5: $c\n";
?>
      ''';
    } else if (moduleTitle.contains('Strings')) {
      return r'''
<?php
// PHP Strings Example

$greeting = "Hello";
$name = "World";

// String concatenation
$message = $greeting . " " . $name . "!";
echo $message . "\n";

// String functions
echo "Length: " . strlen($message) . "\n";
echo "Uppercase: " . strtoupper($message) . "\n";
echo "Lowercase: " . strtolower($message) . "\n";
echo "First character: " . $message[0] . "\n";
echo "Substring: " . substr($message, 0, 5) . "\n";

// String comparison
$str1 = "PHP";
$str2 = "PHP";
echo "Strings equal: " . ($str1 == $str2) . "\n";

// String replacement
$text = "Hello World";
$newText = str_replace("World", "PHP", $text);
echo $newText . "\n";

// String splitting
$fruits = "apple,banana,cherry";
$fruitArray = explode(",", $fruits);
print_r($fruitArray);
?>
      ''';
    } else if (moduleTitle.contains('Arrays')) {
      return r'''
<?php
// PHP Arrays Example

// Indexed array
$colors = array("Red", "Green", "Blue");
$numbers = [1, 2, 3, 4, 5];

// Associative array
$person = array(
    "name" => "John",
    "age" => 30,
    "city" => "Manila"
);

// Multidimensional array
$students = array(
    array("name" => "Alice", "grade" => 95),
    array("name" => "Bob", "grade" => 87),
    array("name" => "Charlie", "grade" => 92)
);

// Array functions
echo "Count: " . count($colors) . "\n";
echo "First color: " . $colors[0] . "\n";

// Adding elements
$colors[] = "Yellow";
array_push($colors, "Purple");

// Removing elements
array_pop($colors); // Remove last
unset($colors[1]); // Remove specific index

// Looping through arrays
foreach($person as $key => $value) {
    echo "$key: $value\n";
}

// Array sorting
sort($numbers); // Sort ascending
rsort($numbers); // Sort descending

print_r($numbers);
?>
      ''';
    } else if (moduleTitle.contains('Conditions')) {
      return r'''
<?php
// PHP Conditions Example

$score = 85;
$age = 20;

// If-else statement
if ($score >= 90) {
    echo "Grade: A\n";
} elseif ($score >= 80) {
    echo "Grade: B\n";
} elseif ($score >= 70) {
    echo "Grade: C\n";
} else {
    echo "Grade: F\n";
}

// Switch statement
$day = 3;
switch ($day) {
    case 1:
        echo "Monday\n";
        break;
    case 2:
        echo "Tuesday\n";
        break;
    case 3:
        echo "Wednesday\n";
        break;
    default:
        echo "Invalid day\n";
}

// Ternary operator
$result = ($score >= 60) ? "Pass" : "Fail";
echo "Result: $result\n";

// Multiple conditions
if ($age >= 18 && $age <= 65) {
    echo "Eligible for work\n";
}

// Nested if
if ($score >= 75) {
    if ($score >= 90) {
        echo "With honors\n";
    } else {
        echo "Passed\n";
    }
}
?>
      ''';
    } else if (moduleTitle.contains('Loops')) {
      return r'''
<?php
// PHP Loops Example

// For loop
echo "For loop:\n";
for ($i = 1; $i <= 5; $i++) {
    echo "Count: $i\n";
}

// While loop
echo "\nWhile loop:\n";
$j = 1;
while ($j <= 3) {
    echo "While count: $j\n";
    $j++;
}

// Do-while loop
echo "\nDo-while loop:\n";
$k = 1;
do {
    echo "Do-while count: $k\n";
    $k++;
} while ($k <= 3);

// Foreach loop (for arrays)
echo "\nForeach loop:\n";
$fruits = ["Apple", "Banana", "Cherry"];
foreach ($fruits as $fruit) {
    echo "Fruit: $fruit\n";
}

// Break and continue
echo "\nBreak example:\n";
for ($i = 1; $i <= 10; $i++) {
    if ($i == 5) break;
    echo "$i ";
}

echo "\nContinue example:\n";
for ($i = 1; $i <= 5; $i++) {
    if ($i == 3) continue;
    echo "$i ";
}
echo "\n";
?>
      ''';
    } else if (moduleTitle.contains('Functions')) {
      return r'''
<?php
// PHP Functions Example

// Function declaration
function greet() {
    echo "Hello from function!\n";
}

function add($a, $b) {
    return $a + $b;
}

function multiply($a, $b = 2) { // Default parameter
    return $a * $b;
}

// Function calls
greet();

$sum = add(5, 3);
echo "Sum: $sum\n";

$product = multiply(2.5, 4.0);
echo "Product: $product\n";

// Recursive function
function factorial($n) {
    if ($n == 0 || $n == 1) {
        return 1;
    }
    return $n * factorial($n - 1);
}

$fact = factorial(5);
echo "Factorial of 5: $fact\n";

// Variable functions
$functionName = "add";
echo "Variable function: " . $functionName(10, 20) . "\n";

// Anonymous functions
$square = function($x) {
    return $x * $x;
};
echo "Square of 4: " . $square(4) . "\n";
?>
      ''';
    } else if (moduleTitle.contains('Forms')) {
      return r'''
<?php
// PHP Forms Example

// Simple form handler
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get form data
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $message = $_POST['message'] ?? '';
    
    // Basic validation
    if (empty($name)) {
        echo "Name is required\n";
    } else {
        echo "Thank you, $name!\n";
        echo "Email: $email\n";
        echo "Message: $message\n";
    }
}

// Display the form
echo '
<form method="post" action="">
    <label for="name">Name:</label>
    <input type="text" id="name" name="name"><br><br>
    
    <label for="email">Email:</label>
    <input type="email" id="email" name="email"><br><br>
    
    <label for="message">Message:</label>
    <textarea id="message" name="message"></textarea><br><br>
    
    <input type="submit" value="Submit">
</form>
';

// GET method example
if (isset($_GET['search'])) {
    $searchTerm = $_GET['search'];
    echo "Search results for: $searchTerm\n";
}

// File upload example
if (isset($_FILES['file'])) {
    $fileName = $_FILES['file']['name'];
    $fileSize = $_FILES['file']['size'];
    $fileTmp = $_FILES['file']['tmp_name'];
    
    echo "File uploaded: $fileName ($fileSize bytes)\n";
}
?>
      ''';
    } else if (moduleTitle.contains('OOP')) {
      return r'''
<?php
// PHP OOP Example

// Class definition
class Car {
    // Properties
    public $brand;
    public $model;
    public $year;
    
    // Constructor
    public function __construct($brand, $model, $year) {
        $this->brand = $brand;
        $this->model = $model;
        $this->year = $year;
    }
    
    // Method
    public function displayInfo() {
        echo "{$this->brand} {$this->model} {$this->year}\n";
    }
    
    // Setter method
    public function setYear($newYear) {
        $this->year = $newYear;
    }
}

// Inheritance
class SportsCar extends Car {
    public $topSpeed;
    
    public function __construct($brand, $model, $year, $topSpeed) {
        parent::__construct($brand, $model, $year);
        $this->topSpeed = $topSpeed;
    }
    
    public function displayInfo() {
        parent::displayInfo();
        echo "Top Speed: {$this->topSpeed} km/h\n";
    }
}

// Creating objects
$car1 = new Car("Toyota", "Corolla", 2020);
$car2 = new SportsCar("Ferrari", "F8", 2023, 340);

// Using objects
$car1->displayInfo();
$car2->displayInfo();

// Modifying object
$car1->setYear(2021);
echo "After update: ";
$car1->displayInfo();

// Access modifiers example
class BankAccount {
    private $balance = 0;
    
    public function deposit($amount) {
        $this->balance += $amount;
    }
    
    public function getBalance() {
        return $this->balance;
    }
}

$account = new BankAccount();
$account->deposit(1000);
echo "Balance: " . $account->getBalance() . "\n";
?>
      ''';
    } else if (moduleTitle.contains('MySQL')) {
      return r'''
<?php
// PHP MySQL Example

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "testdb";

try {
    // Create connection
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Connected successfully\n";
    
    // Create table
    $sql = "CREATE TABLE IF NOT EXISTS users (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        firstname VARCHAR(30) NOT NULL,
        lastname VARCHAR(30) NOT NULL,
        email VARCHAR(50),
        reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )";
    
    $conn->exec($sql);
    echo "Table created successfully\n";
    
    // Insert data
    $sql = "INSERT INTO users (firstname, lastname, email) 
            VALUES ('John', 'Doe', 'john@example.com')";
    $conn->exec($sql);
    echo "New record created successfully\n";
    
    // Select data
    $stmt = $conn->prepare("SELECT id, firstname, lastname FROM users");
    $stmt->execute();
    
    $result = $stmt->fetchAll();
    foreach($result as $row) {
        echo "ID: " . $row['id'] . " - Name: " . $row['firstname'] . " " . $row['lastname'] . "\n";
    }
    
} catch(PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}

$conn = null; // Close connection

// MySQLi example (alternative)
$mysqli = new mysqli($servername, $username, $password, $dbname);

if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

echo "MySQLi connected successfully\n";
$mysqli->close();
?>
      ''';
    } else if (moduleTitle.contains('Sessions')) {
      return r'''
<?php
// PHP Sessions Example

// Start session
session_start();

// Set session variables
$_SESSION["username"] = "john_doe";
$_SESSION["email"] = "john@example.com";
$_SESSION["login_time"] = date('Y-m-d H:i:s');

echo "Session started\n";
echo "Welcome " . $_SESSION["username"] . "!\n";

// Display all session variables
echo "\nSession data:\n";
foreach($_SESSION as $key => $value) {
    echo "$key: $value\n";
}

// Check if session variable exists
if(isset($_SESSION["username"])) {
    echo "\nUser is logged in as: " . $_SESSION["username"] . "\n";
}

// Modify session variable
$_SESSION["username"] = "john_updated";
echo "Updated username: " . $_SESSION["username"] . "\n";

// Cookies example
$cookie_name = "user";
$cookie_value = "John Doe";
setcookie($cookie_name, $cookie_value, time() + (86400 * 30), "/"); // 30 days

if(isset($_COOKIE[$cookie_name])) {
    echo "\nCookie '" . $cookie_name . "' is set!\n";
    echo "Value is: " . $_COOKIE[$cookie_name] . "\n";
}

// Destroy session (logout)
if(isset($_GET['logout'])) {
    session_unset(); // Remove all session variables
    session_destroy(); // Destroy the session
    echo "Session destroyed\n";
    
    // Delete cookie
    setcookie($cookie_name, "", time() - 3600, "/");
    echo "Cookie deleted\n";
}
?>
      ''';
    } else if (moduleTitle.contains('File Handling')) {
      return r'''
<?php
// PHP File Handling Example

// Writing to file
$file = "example.txt";
$content = "Hello PHP File Handling!\nThis is a sample file.\n";

if (file_put_contents($file, $content, FILE_APPEND | LOCK_EX) !== false) {
    echo "File written successfully!\n";
} else {
    echo "Cannot write to file\n";
}

// Reading from file
if (file_exists($file)) {
    echo "\nFile content:\n";
    echo file_get_contents($file);
} else {
    echo "File does not exist\n";
}

// File operations with fopen
$handle = fopen("data.txt", "w");
if ($handle) {
    fwrite($handle, "Line 1\n");
    fwrite($handle, "Line 2\n");
    fwrite($handle, "Line 3\n");
    fclose($handle);
    echo "\nData written to data.txt\n";
}

// Reading line by line
echo "\nReading line by line:\n";
$handle = fopen("data.txt", "r");
if ($handle) {
    while (($line = fgets($handle)) !== false) {
        echo "Line: " . trim($line) . "\n";
    }
    fclose($handle);
}

// File information
echo "\nFile information:\n";
echo "File size: " . filesize($file) . " bytes\n";
echo "Last modified: " . date("F d Y H:i:s.", filemtime($file)) . "\n";

// Directory functions
echo "\nDirectory listing:\n";
$files = scandir(".");
foreach($files as $file) {
    if ($file != "." && $file != "..") {
        echo $file . "\n";
    }
}

// File upload handling
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['file'])) {
    $target_dir = "uploads/";
    $target_file = $target_dir . basename($_FILES["file"]["name"]);
    
    if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
        echo "File uploaded successfully\n";
    } else {
        echo "File upload failed\n";
    }
}
?>
      ''';
    } else if (moduleTitle.contains('Error Handling')) {
      return r'''
<?php
// PHP Error Handling Example

// Basic error handling
function divide($a, $b) {
    if ($b == 0) {
        throw new Exception("Division by zero!");
    }
    return $a / $b;
}

// Try-catch block
try {
    // This will work
    $result1 = divide(10, 2);
    echo "10 / 2 = $result1\n";
    
    // This will throw exception
    $result2 = divide(10, 0);
    echo "10 / 0 = $result2\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
} finally {
    echo "This always executes\n";
}

// Multiple exception types
class CustomException extends Exception {}

function checkNumber($number) {
    if ($number < 0) {
        throw new CustomException("Number cannot be negative");
    }
    if ($number > 100) {
        throw new Exception("Number cannot be greater than 100");
    }
    return $number;
}

try {
    echo checkNumber(50) . "\n";  // Works
    echo checkNumber(-5) . "\n";  // Throws CustomException
} catch (CustomException $e) {
    echo "Custom Error: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "General Error: " . $e->getMessage() . "\n";
}

// Error logging
function logError($message) {
    error_log($message, 3, "error_log.txt");
}

// Custom error handler
function customErrorHandler($errno, $errstr, $errfile, $errline) {
    echo "<b>Custom error:</b> [$errno] $errstr\n";
    echo "Error on line $errline in $errfile\n";
}

set_error_handler("customErrorHandler");

// Trigger error
echo $undefinedVariable; // This will trigger custom error handler

// Restore original error handler
restore_error_handler();

echo "Program continues after exception handling.\n";

// Assertions
function calculateDiscount($price, $discount) {
    assert($discount >= 0 && $discount <= 100, "Discount must be between 0 and 100");
    return $price * (1 - $discount / 100);
}

echo "Discounted price: " . calculateDiscount(100, 20) . "\n";
?>
      ''';
    }

    return r'''
<?php
// PHP Example for ${moduleTitle}
echo "PHP programming example for ${moduleTitle}";
?>
    ''';
  }

  String _getJavaExampleCode(String moduleTitle) {
    if (moduleTitle.contains('Introduction')) {
      return '''
// Java Introduction Example
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
      ''';
    }
    return '''
// Java Example for ${moduleTitle}
public class Example {
    public static void main(String[] args) {
        System.out.println("Java programming example");
    }
}
    ''';
  }

  String _getCppExampleCode(String moduleTitle) {
    if (moduleTitle.contains('Introduction')) {
      return '''
// C++ Introduction Example
#include <iostream>
using namespace std;

int main() {
    cout << "Hello, World!" << endl;
    return 0;
}
      ''';
    }
    return '''
// C++ Example for ${moduleTitle}
#include <iostream>
using namespace std;

int main() {
    cout << "C++ programming example" << endl;
    return 0;
}
    ''';
  }

  String _getLanguageName(String fileName) {
    if (fileName.contains('cpp')) return 'C++';
    if (fileName.contains('java')) return 'Java';
    if (fileName.contains('python')) return 'Python';
    if (fileName.contains('php')) return 'PHP';
    if (fileName.contains('sql')) return 'SQL';
    return 'Programming';
  }
}