import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'php_practice_screen.dart';

class PhpLearningScreen extends StatefulWidget {
  final String moduleTitle;
  final String fileName;
  final Color primaryColor;

  const PhpLearningScreen({
    Key? key,
    required this.moduleTitle,
    required this.fileName,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<PhpLearningScreen> createState() => _PhpLearningScreenState();
}

class _PhpLearningScreenState extends State<PhpLearningScreen> {
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
      case 'PHP Introduction':
        return '''
PHP (Hypertext Preprocessor) is a popular server-side scripting language designed for web development. It was created by Rasmus Lerdorf in 1994.

Key Features:
• Server-Side Execution: Code is executed on the server before being sent to the client
• Open Source: Free to use and modify
• Cross-Platform: Runs on Windows, Linux, macOS
• Database Integration: Excellent support for databases like MySQL, PostgreSQL
• Easy to Learn: Simple syntax similar to C and Java
• Large Community: Extensive documentation and support

PHP Usage:
• Web Development: Dynamic websites and web applications
• Content Management Systems: WordPress, Drupal, Joomla
• E-commerce Platforms: Magento, WooCommerce
• API Development: RESTful APIs and web services
• Server-Side Scripting: Form processing, file handling

PHP Versions:
• PHP 5.x (Legacy versions)
• PHP 7.x (Major performance improvements)
• PHP 8.x (Latest features and JIT compiler)
''';

      case 'PHP Syntax':
        return '''
PHP Basic Syntax:
PHP scripts start with <?php and end with ?>
You can use short tags <? and ?> but <?php is recommended
Each statement ends with a semicolon (;)
PHP is case-sensitive for variable names but not for keywords
Comments can be single-line (// or #) or multi-line (/* */)

Basic Structure:
<?php
  // PHP code goes here
  echo "Hello, World!";
?>

Embedding in HTML:
<!DOCTYPE html>
<html>
<body>
  <h1>My PHP Page</h1>
  <?php echo "Today is " . date("Y-m-d"); ?>
</body>
</html>
''';

      case 'PHP Variables':
        return '''
Variable Declaration in PHP:
• Variables start with \$ sign followed by the name
• Variable names must start with a letter or underscore
• Variable names can only contain letters, numbers, and underscores
• Variable names are case-sensitive

Data Types:
• String: Text values
• Integer: Whole numbers
• Float: Decimal numbers
• Boolean: true or false
• Array: Collection of values
• Object: Instances of classes
• NULL: Variable with no value

Variable Scope:
• Local: Accessible only within the function
• Global: Accessible anywhere in the script
• Static: Preserves value between function calls
''';

      case 'PHP Operators':
        return '''
Arithmetic Operators:
• + Addition
• - Subtraction
• * Multiplication
• / Division
• % Modulus
• ** Exponentiation

Assignment Operators:
• = Assign value
• += Add and assign
• -= Subtract and assign
• *= Multiply and assign
• /= Divide and assign

Comparison Operators:
• == Equal
• === Identical
• != Not equal
• !== Not identical
• > Greater than
• < Less than
• >= Greater than or equal
• <= Less than or equal

Logical Operators:
• and / && Logical AND
• or / || Logical OR
• ! Logical NOT
• xor Logical XOR
''';

      case 'PHP Strings':
        return '''
String Creation:
• Single quotes: 'text'
• Double quotes: "text"
• Heredoc: <<<EOD text EOD
• Nowdoc: <<<'EOD' text EOD

String Functions:
• strlen() - Get string length
• str_word_count() - Count words in string
• strrev() - Reverse string
• strpos() - Search for text
• str_replace() - Replace text
• substr() - Return part of string
• trim() - Remove whitespace
• strtoupper() - Convert to uppercase
• strtolower() - Convert to lowercase

String Concatenation:
Use . operator to concatenate strings
Example: \$str1 . \$str2
''';

      case 'PHP Arrays':
        return '''
Array Types:
1. Indexed Arrays - Arrays with numeric index
2. Associative Arrays - Arrays with named keys
3. Multidimensional Arrays - Arrays containing arrays

Array Creation:
// Indexed array
\$colors = array("Red", "Green", "Blue");
\$colors = ["Red", "Green", "Blue"];

// Associative array
\$age = array("Peter"=>"35", "Ben"=>"37", "Joe"=>"43");
\$age = ["Peter"=>"35", "Ben"=>"37", "Joe"=>"43"];

Array Functions:
• count() - Count array elements
• sort() - Sort arrays
• rsort() - Sort arrays in descending order
• asort() - Sort associative arrays by value
• ksort() - Sort associative arrays by key
• array_push() - Add element to end
• array_pop() - Remove element from end
• in_array() - Check if value exists
''';

      case 'PHP Conditions':
        return '''
Conditional Statements:
1. if statement - executes code if condition is true
2. if...else statement - executes different codes for true/false
3. if...elseif...else statement - executes different codes for more than two conditions
4. switch statement - selects one of many blocks of code to execute

If Statements:
if (condition) {
    // code to execute if condition is true
} elseif (condition) {
    // code to execute if first condition is false and this condition is true
} else {
    // code to execute if all conditions are false
}

Switch Statement:
switch (variable) {
    case value1:
        // code block
        break;
    case value2:
        // code block
        break;
    default:
        // default code block
}
''';

      case 'PHP Loops':
        return '''
Loop Types:
1. while - loops through a block of code as long as condition is true
2. do...while - loops through a block once, then repeats as long as condition is true
3. for - loops through a block of code a specified number of times
4. foreach - loops through a block of code for each element in an array

While Loop:
while (condition is true) {
    // code to be executed
}

Do-While Loop:
do {
    // code to be executed
} while (condition is true);

For Loop:
for (init counter; test counter; increment counter) {
    // code to be executed
}

Foreach Loop:
foreach (\$array as \$value) {
    // code to be executed
}
''';

      case 'PHP Functions':
        return '''
Function Definition:
function functionName(\$parameter1, \$parameter2, ...) {
    // code to be executed
    return \$value; // optional
}

Function Types:
• Built-in functions - Predefined in PHP
• User-defined functions - Created by programmer

Function Parameters:
• Required parameters - Must be passed
• Optional parameters - Have default values
• Return values - Values returned using return statement

Variable Scope in Functions:
• Local variables - Only accessible within function
• Global variables - Accessible with global keyword
• Static variables - Preserve value between calls

Example:
function greet(\$name) {
    return "Hello, " . \$name;
}

function add(\$a, \$b = 10) {
    return \$a + \$b;
}
''';

      case 'PHP OOP':
        return '''
Object-Oriented Programming in PHP:
• Class - Blueprint for objects
• Object - Instance of a class
• Properties - Variables inside class
• Methods - Functions inside class
• Constructor - Special method called when object is created
• Destructor - Special method called when object is destroyed

Class Definition:
class ClassName {
    // Properties
    public \$property;
    
    // Constructor
    public function __construct(\$param) {
        \$this->property = \$param;
    }
    
    // Methods
    public function methodName() {
        // method code
    }
}

Access Modifiers:
• public - Accessible from anywhere
• private - Accessible only within class
• protected - Accessible within class and child classes
''';

      case 'PHP Forms':
        return '''
Form Handling in PHP:
PHP can collect form data using \$_GET and \$_POST superglobals

GET Method:
• Data visible in URL
• Limited amount of data
• Bookmarkable
• Not secure for sensitive data

POST Method:
• Data not visible in URL
• No size limitations
• Not bookmarkable
• More secure

Form Validation:
• Required fields validation
• Data format validation
• Sanitization of input data
• CSRF protection

Example:
<form method="POST" action="process.php">
    <input type="text" name="username">
    <input type="submit" name="submit" value="Submit">
</form>

<?php
if (\$_SERVER["REQUEST_METHOD"] == "POST") {
    \$username = \$_POST['username'];
    // Process form data
}
?>
''';

      case 'PHP File Handling':
        return '''
File Operations in PHP:
• Opening files - fopen()
• Reading files - fread(), file_get_contents()
• Writing files - fwrite(), file_put_contents()
• Closing files - fclose()
• Checking file existence - file_exists()

Reading Files:
// Read entire file
\$content = file_get_contents("file.txt");

// Read file line by line
\$lines = file("file.txt");

// Using file handle
\$file = fopen("file.txt", "r");
while (!feof(\$file)) {
    echo fgets(\$file);
}
fclose(\$file);

Writing Files:
// Write entire file
file_put_contents("file.txt", \$content);

// Using file handle
\$file = fopen("file.txt", "w");
fwrite(\$file, \$content);
fclose(\$file);

File Upload:
PHP handles file uploads through \$_FILES superglobal
Need to configure php.ini for upload settings
''';

      case 'PHP Error Handling':
        return '''
Error Handling in PHP:
• Simple "die()" statements
• Custom error handlers
• Exception handling with try-catch

Error Types:
• Notice - Minor issues, script continues
• Warning - More serious issues, script continues
• Fatal Error - Critical issues, script stops

Basic Error Handling:
if (!file_exists("file.txt")) {
    die("File not found");
} else {
    \$file = fopen("file.txt", "r");
}

Custom Error Handler:
function customError(\$errno, \$errstr) {
    echo "<b>Error:</b> [\$errno] \$errstr";
}
set_error_handler("customError");

Exception Handling:
try {
    // Code that may throw exception
    if (!file_exists("file.txt")) {
        throw new Exception("File not found");
    }
} catch (Exception \$e) {
    echo "Error: " . \$e->getMessage();
}
''';

      case 'PHP Sessions':
        return '''
Session Management in PHP:
Sessions allow storing user information across multiple pages

Starting Session:
session_start();

Setting Session Variables:
\$_SESSION["username"] = "john_doe";
\$_SESSION["email"] = "john@example.com";

Accessing Session Variables:
echo "Username: " . \$_SESSION["username"];

Destroying Session:
session_destroy();

Session Configuration:
• session.gc_maxlifetime - Session lifetime
• session.cookie_lifetime - Cookie lifetime
• session.save_path - Session save path

Security Considerations:
• Regenerate session ID
• Validate session data
• Use HTTPS for secure transmission
• Set proper cookie parameters
''';

      case 'PHP SQL':
        return '''
Database Connectivity in PHP:
PHP supports various databases including MySQL, PostgreSQL, SQLite

MySQLi (MySQL Improved):
• Object-oriented interface
• Procedural interface
• Support for prepared statements
• Enhanced security features

PDO (PHP Data Objects):
• Database agnostic interface
• Support for multiple databases
• Prepared statements
• Exception handling

MySQLi Connection:
<?php
\$servername = "localhost";
\$username = "username";
\$password = "password";
\$dbname = "database";

// Create connection
\$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

// Check connection
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}
echo "Connected successfully";
?>

PDO Connection:
<?php
try {
    \$conn = new PDO("mysql:host=\$servername;dbname=\$dbname", \$username, \$password);
    \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Connected successfully";
} catch(PDOException \$e) {
    echo "Connection failed: " . \$e->getMessage();
}
?>
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
        builder: (context) => PhpPracticeScreen(
          moduleTitle: widget.moduleTitle,
          primaryColor: widget.primaryColor,
          language: 'PHP',
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
      case 'PHP Introduction':
        return '''<?php
echo "Hello, World!";
echo "Welcome to PHP Programming";
?>''';

      case 'PHP Syntax':
        return '''<?php
// This is a single-line comment
# This is also a single-line comment

/*
This is a multi-line comment
*/

echo "Hello World!";
\$txt = "PHP";
echo "I love \$txt!";
?>''';

      case 'PHP Variables':
        return '''<?php
\$name = "John";
\$age = 25;
\$height = 5.8;
\$isStudent = true;

echo "Name: " . \$name;
echo "Age: " . \$age;
echo "Height: " . \$height;
echo "Is Student: " . (\$isStudent ? "Yes" : "No");
?>''';

      case 'PHP Operators':
        return '''<?php
\$a = 10;
\$b = 3;

echo "Addition: " . (\$a + \$b);
echo "Subtraction: " . (\$a - \$b);
echo "Multiplication: " . (\$a * \$b);
echo "Division: " . (\$a / \$b);
echo "Modulus: " . (\$a % \$b);

\$result = (\$a > \$b) ? "A is greater" : "B is greater";
echo \$result;
?>''';

      case 'PHP Strings':
        return '''<?php
\$greeting = "Hello";
\$name = "John";

// String concatenation
\$message = \$greeting . ", " . \$name . "!";

echo \$message;
echo "Length: " . strlen(\$message);
echo "Uppercase: " . strtoupper(\$message);
echo "Position of John: " . strpos(\$message, "John");
?>''';

      case 'PHP Arrays':
        return '''<?php
// Indexed array
\$colors = array("Red", "Green", "Blue");

// Associative array
\$age = array("Peter"=>"35", "Ben"=>"37", "Joe"=>"43");

// Multidimensional array
\$cars = array(
  array("Toyota", 22, 18),
  array("BMW", 15, 13),
  array("Saab", 5, 2)
);

echo "First color: " . \$colors[0];
echo "Peter is " . \$age['Peter'] . " years old";
echo \$cars[0][0] . ": In stock: " . \$cars[0][1];
?>''';

      case 'PHP Conditions':
        return '''<?php
\$age = 18;

if (\$age >= 18) {
    echo "Adult";
} elseif (\$age >= 13) {
    echo "Teenager";
} else {
    echo "Child";
}

\$day = "Monday";
switch (\$day) {
    case "Monday":
        echo "Start of work week";
        break;
    case "Friday":
        echo "Weekend is near";
        break;
    default:
        echo "Regular day";
}
?>''';

      case 'PHP Loops':
        return '''<?php
// For loop
for (\$i = 0; \$i < 5; \$i++) {
    echo "Number: \$i";
}

// While loop
\$count = 1;
while (\$count <= 3) {
    echo "Count: \$count";
    \$count++;
}

// Foreach loop
\$colors = array("Red", "Green", "Blue");
foreach (\$colors as \$value) {
    echo "Color: \$value";
}
?>''';

      case 'PHP Functions':
        return '''<?php
function greet(\$name) {
    return "Hello, " . \$name;
}

function add(\$a, \$b = 10) {
    return \$a + \$b;
}

echo greet("John");
echo "Sum: " . add(5, 3);
echo "Sum with default: " . add(5);
?>''';

      case 'PHP OOP':
        return '''<?php
class Car {
    public \$brand;
    public \$model;
    
    public function __construct(\$brand, \$model) {
        \$this->brand = \$brand;
        \$this->model = \$model;
    }
    
    public function getInfo() {
        return \$this->brand . " " . \$this->model;
    }
}

\$car1 = new Car("Toyota", "Camry");
echo \$car1->getInfo();
?>''';

      case 'PHP Forms':
        return '''<?php
if (\$_SERVER["REQUEST_METHOD"] == "POST") {
    \$username = \$_POST['username'];
    \$email = \$_POST['email'];
    
    echo "Username: " . htmlspecialchars(\$username);
    echo "Email: " . htmlspecialchars(\$email);
}
?>

<form method="POST" action="">
    <input type="text" name="username" placeholder="Username">
    <input type="email" name="email" placeholder="Email">
    <input type="submit" value="Submit">
</form>''';

      case 'PHP File Handling':
        return '''<?php
// Writing to a file
\$file = fopen("test.txt", "w");
fwrite(\$file, "Hello File Handling!");
fclose(\$file);

// Reading from a file
\$content = file_get_contents("test.txt");
echo \$content;

// Reading line by line
\$file = fopen("test.txt", "r");
while (!feof(\$file)) {
    echo fgets(\$file);
}
fclose(\$file);
?>''';

      case 'PHP Error Handling':
        return '''<?php
// Basic error handling
if (!file_exists("file.txt")) {
    die("File not found");
}

// Exception handling
try {
    if (!file_exists("file.txt")) {
        throw new Exception("File not found");
    }
} catch (Exception \$e) {
    echo "Error: " . \$e->getMessage();
}

// Custom error handler
function customError(\$errno, \$errstr) {
    echo "<b>Error:</b> [\$errno] \$errstr";
}
set_error_handler("customError");
?>''';

      case 'PHP Sessions':
        return '''<?php
session_start();

// Set session variables
\$_SESSION["username"] = "john_doe";
\$_SESSION["email"] = "john@example.com";

// Access session variables
echo "Username: " . \$_SESSION["username"];

// Destroy session
// session_destroy();
?>''';

      case 'PHP SQL':
        return '''<?php
// MySQLi connection
\$servername = "localhost";
\$username = "username";
\$password = "password";
\$dbname = "myDB";

\$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}
echo "Connected successfully";

// PDO connection
try {
    \$conn = new PDO("mysql:host=\$servername;dbname=\$dbname", \$username, \$password);
    \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Connected successfully";
} catch(PDOException \$e) {
    echo "Connection failed: " . \$e->getMessage();
}
?>''';

      default:
        return '''<?php
echo "Welcome to PHP Programming!";
?>''';
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
              'PHP',
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