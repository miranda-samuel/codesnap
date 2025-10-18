import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/darcula.dart';

class PhpPracticeScreen extends StatefulWidget {
  final String moduleTitle;
  final Color primaryColor;
  final String language;

  const PhpPracticeScreen({
    Key? key,
    required this.moduleTitle,
    required this.primaryColor,
    required this.language,
  }) : super(key: key);

  @override
  State<PhpPracticeScreen> createState() => _PhpPracticeScreenState();
}

class _PhpPracticeScreenState extends State<PhpPracticeScreen> {
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
      case 'PHP Introduction':
        _exercises = [
          {
            'title': 'Hello World Program',
            'description': 'Write your first PHP program that displays "Hello, World!"',
            'starterCode': '<?php\n    // Write your code here\n    \n?>',
            'hint': 'Use echo "Hello, World!"; to display text. Make sure to include the semicolon at the end.',
            'solution': '<?php\n    echo "Hello, World!";\n?>',
            'testCases': ['Hello, World!']
          },
          {
            'title': 'Basic Output',
            'description': 'Display your name and age using echo statements',
            'starterCode': '<?php\n    // Display your name\n    \n    // Display your age\n    \n?>',
            'hint': 'Use multiple echo statements. Example: echo "Name: John";',
            'solution': '<?php\n    echo "Name: John";\n    echo "Age: 25";\n?>',
            'testCases': ['Name: John', 'Age: 25']
          },
          {
            'title': 'Multiple Lines Output',
            'description': 'Display text on different lines using echo',
            'starterCode': '<?php\n    // Display text on multiple lines\n    \n?>',
            'hint': 'Use echo with \\n for new lines or multiple echo statements.',
            'solution': '<?php\n    echo "Line 1\\n";\n    echo "Line 2\\n";\n    echo "Line 3\\n";\n?>',
            'testCases': ['Line 1', 'Line 2', 'Line 3']
          },
        ];
        break;

      case 'PHP Syntax':
        _exercises = [
          {
            'title': 'Variable Declaration',
            'description': 'Declare different types of variables and display them',
            'starterCode': '<?php\n    // Declare variables here\n    \n    // Display variables\n    \n?>',
            'hint': 'Declare variables with \$ symbol. Example: \$name = "John";',
            'solution': '<?php\n    \$name = "John";\n    \$age = 25;\n    \$price = 19.99;\n    \$isStudent = true;\n    \n    echo "Name: " . \$name . "\\n";\n    echo "Age: " . \$age . "\\n";\n    echo "Price: " . \$price . "\\n";\n    echo "Is Student: " . \$isStudent . "\\n";\n?>',
            'testCases': ['Name: John', 'Age: 25', 'Price: 19.99', 'Is Student: 1']
          },
          {
            'title': 'Comments Practice',
            'description': 'Use single-line and multi-line comments in your code',
            'starterCode': '<?php\n    // Add your code with comments\n    \n?>',
            'hint': 'Use // for single-line comments and /* */ for multi-line comments',
            'solution': '<?php\n    // This is a single-line comment\n    \n    /*\n    This is a multi-line comment\n    It can span multiple lines\n    */\n    \n    echo "Learning PHP comments!"; // Comment after code\n?>',
            'testCases': ['Learning PHP comments!']
          },
          {
            'title': 'Basic Data Types',
            'description': 'Work with different PHP data types',
            'starterCode': '<?php\n    // Work with different data types\n    \n?>',
            'hint': 'Use var_dump() to display variable types and values',
            'solution': '<?php\n    \$string = "Hello PHP";\n    \$integer = 42;\n    \$float = 3.14;\n    \$boolean = true;\n    \$array = array(1, 2, 3);\n    \n    var_dump(\$string);\n    var_dump(\$integer);\n    var_dump(\$float);\n    var_dump(\$boolean);\n    var_dump(\$array);\n?>',
            'testCases': ['string(9) "Hello PHP"', 'int(42)', 'float(3.14)', 'bool(true)']
          },
        ];
        break;

      case 'PHP Variables':
        _exercises = [
          {
            'title': 'Variable Declaration and Initialization',
            'description': 'Declare and initialize different types of variables',
            'starterCode': '<?php\n    // Declare and initialize variables\n    \n?>',
            'hint': 'Declare variables with different data types and assign values',
            'solution': '<?php\n    \$studentCount = 30;\n    \$averageScore = 85.5;\n    \$courseName = "PHP Programming";\n    \$isPassed = true;\n    \n    echo "Student Count: " . \$studentCount . "\\n";\n    echo "Average Score: " . \$averageScore . "\\n";\n    echo "Course: " . \$courseName . "\\n";\n    echo "Passed: " . \$isPassed . "\\n";\n?>',
            'testCases': ['Student Count: 30', 'Average Score: 85.5', 'Course: PHP Programming', 'Passed: 1']
          },
          {
            'title': 'Variable Reassignment',
            'description': 'Change variable values and observe the changes',
            'starterCode': '<?php\n    \$score = 85;\n    // Change the score value\n    \n?>',
            'hint': 'Assign new values to variables and print before and after',
            'solution': '<?php\n    \$score = 85;\n    echo "Original score: " . \$score . "\\n";\n    \n    \$score = 90; // Reassigning the variable\n    echo "Updated score: " . \$score . "\\n";\n    \n    \$score = \$score + 5; // Using the variable in calculation\n    echo "Final score: " . \$score . "\\n";\n?>',
            'testCases': ['Original score: 85', 'Updated score: 90', 'Final score: 95']
          },
          {
            'title': 'Variable Scope',
            'description': 'Understand local and global variable scope',
            'starterCode': '<?php\n    \$globalVar = "I am global";\n    \n    function testFunction() {\n        // Access global variable and create local variable\n    }\n    \n    testFunction();\n?>',
            'hint': 'Use global keyword to access global variables inside functions',
            'solution': '<?php\n    \$globalVar = "I am global";\n    \n    function testFunction() {\n        global \$globalVar;\n        \$localVar = "I am local";\n        echo \$globalVar . "\\n";\n        echo \$localVar . "\\n";\n    }\n    \n    testFunction();\n?>',
            'testCases': ['I am global', 'I am local']
          },
        ];
        break;

      case 'PHP Operators':
        _exercises = [
          {
            'title': 'Arithmetic Operators',
            'description': 'Perform basic arithmetic operations',
            'starterCode': '<?php\n    \$a = 15;\n    \$b = 4;\n    \n    // Perform arithmetic operations\n    \n?>',
            'hint': 'Use +, -, *, /, % operators with variables a and b',
            'solution': '<?php\n    \$a = 15;\n    \$b = 4;\n    \n    echo "a + b = " . (\$a + \$b) . "\\n";\n    echo "a - b = " . (\$a - \$b) . "\\n";\n    echo "a * b = " . (\$a * \$b) . "\\n";\n    echo "a / b = " . (\$a / \$b) . "\\n";\n    echo "a % b = " . (\$a % \$b) . "\\n";\n?>',
            'testCases': ['a + b = 19', 'a - b = 11', 'a * b = 60', 'a / b = 3.75', 'a % b = 3']
          },
          {
            'title': 'Comparison Operators',
            'description': 'Use comparison operators to compare values',
            'starterCode': '<?php\n    \$x = 10;\n    \$y = 20;\n    \n    // Use comparison operators\n    \n?>',
            'hint': 'Use ==, !=, >, <, >=, <= to compare x and y',
            'solution': '<?php\n    \$x = 10;\n    \$y = 20;\n    \n    echo "x == y: " . (\$x == \$y) . "\\n";\n    echo "x != y: " . (\$x != \$y) . "\\n";\n    echo "x > y: " . (\$x > \$y) . "\\n";\n    echo "x < y: " . (\$x < \$y) . "\\n";\n    echo "x >= y: " . (\$x >= \$y) . "\\n";\n    echo "x <= y: " . (\$x <= \$y) . "\\n";\n?>',
            'testCases': ['x == y:', 'x != y: 1', 'x > y:', 'x < y: 1', 'x >= y:', 'x <= y: 1']
          },
          {
            'title': 'Logical Operators',
            'description': 'Use logical operators with boolean values',
            'starterCode': '<?php\n    \$p = true;\n    \$q = false;\n    \n    // Use logical operators\n    \n?>',
            'hint': 'Use && (AND), || (OR), ! (NOT) with p and q',
            'solution': '<?php\n    \$p = true;\n    \$q = false;\n    \n    echo "p && q: " . (\$p && \$q) . "\\n";\n    echo "p || q: " . (\$p || \$q) . "\\n";\n    echo "!p: " . (!\$p) . "\\n";\n    echo "!q: " . (!\$q) . "\\n";\n?>',
            'testCases': ['p && q:', 'p || q: 1', '!p:', '!q: 1']
          },
        ];
        break;

      case 'PHP Strings':
        _exercises = [
          {
            'title': 'String Basics',
            'description': 'Create and manipulate strings',
            'starterCode': '<?php\n    // Work with strings\n    \n?>',
            'hint': 'Create strings, concatenate them, and find length',
            'solution': '<?php\n    \$firstName = "John";\n    \$lastName = "Doe";\n    \$fullName = \$firstName . " " . \$lastName;\n    \n    echo "First Name: " . \$firstName . "\\n";\n    echo "Last Name: " . \$lastName . "\\n";\n    echo "Full Name: " . \$fullName . "\\n";\n    echo "Length: " . strlen(\$fullName) . "\\n";\n?>',
            'testCases': ['First Name: John', 'Last Name: Doe', 'Full Name: John Doe', 'Length: 8']
          },
          {
            'title': 'String Methods',
            'description': 'Use various string functions',
            'starterCode': '<?php\n    \$text = "Hello PHP Programming";\n    \n    // Use string functions\n    \n?>',
            'hint': 'Try strlen(), strtoupper(), strtolower(), substr(), str_replace() functions',
            'solution': '<?php\n    \$text = "Hello PHP Programming";\n    \n    echo "Original: " . \$text . "\\n";\n    echo "Uppercase: " . strtoupper(\$text) . "\\n";\n    echo "Lowercase: " . strtolower(\$text) . "\\n";\n    echo "Substring: " . substr(\$text, 0, 5) . "\\n";\n    echo "Replace: " . str_replace("PHP", "Python", \$text) . "\\n";\n    echo "Position of PHP: " . strpos(\$text, "PHP") . "\\n";\n?>',
            'testCases': ['Original: Hello PHP Programming', 'Uppercase: HELLO PHP PROGRAMMING', 'Lowercase: hello php programming', 'Substring: Hello', 'Replace: Hello Python Programming']
          },
          {
            'title': 'String Comparison',
            'description': 'Compare strings using different methods',
            'starterCode': '<?php\n    \$str1 = "Hello";\n    \$str2 = "Hello";\n    \$str3 = "HELLO";\n    \n    // Compare strings\n    \n?>',
            'hint': 'Use ==, strcmp(), strcasecmp() for comparison',
            'solution': '<?php\n    \$str1 = "Hello";\n    \$str2 = "Hello";\n    \$str3 = "HELLO";\n    \n    echo "str1 == str2: " . (\$str1 == \$str2) . "\\n";\n    echo "str1 == str3: " . (\$str1 == \$str3) . "\\n";\n    echo "strcmp(str1, str2): " . strcmp(\$str1, \$str2) . "\\n";\n    echo "strcasecmp(str1, str3): " . strcasecmp(\$str1, \$str3) . "\\n";\n?>',
            'testCases': ['str1 == str2: 1', 'str1 == str3:', 'strcmp(str1, str2): 0', 'strcasecmp(str1, str3): 0']
          },
        ];
        break;

      case 'PHP Arrays':
        _exercises = [
          {
            'title': 'Indexed Arrays',
            'description': 'Create and use indexed arrays',
            'starterCode': '<?php\n    // Create and display indexed array\n    \n?>',
            'hint': 'Use array() or [] to create arrays and foreach to display',
            'solution': '<?php\n    \$colors = array("Red", "Green", "Blue");\n    \$numbers = [1, 2, 3, 4, 5];\n    \n    echo "Colors: \\n";\n    foreach (\$colors as \$color) {\n        echo \$color . "\\n";\n    }\n    \n    echo "\\nNumbers: \\n";\n    for (\$i = 0; \$i < count(\$numbers); \$i++) {\n        echo "Index " . \$i . ": " . \$numbers[\$i] . "\\n";\n    }\n?>',
            'testCases': ['Colors:', 'Red', 'Green', 'Blue', 'Numbers:', 'Index 0: 1', 'Index 1: 2', 'Index 2: 3']
          },
          {
            'title': 'Associative Arrays',
            'description': 'Work with key-value pairs in arrays',
            'starterCode': '<?php\n    // Create and display associative array\n    \n?>',
            'hint': 'Use key => value syntax for associative arrays',
            'solution': '<?php\n    \$person = array(\n        "name" => "John",\n        "age" => 30,\n        "city" => "Manila"\n    );\n    \n    echo "Person Information:\\n";\n    foreach (\$person as \$key => \$value) {\n        echo \$key . ": " . \$value . "\\n";\n    }\n    \n    echo "\\nName: " . \$person["name"] . "\\n";\n    echo "Age: " . \$person["age"] . "\\n";\n?>',
            'testCases': ['Person Information:', 'name: John', 'age: 30', 'city: Manila', 'Name: John', 'Age: 30']
          },
          {
            'title': 'Array Functions',
            'description': 'Use built-in array functions',
            'starterCode': '<?php\n    \$numbers = [5, 2, 8, 1, 9];\n    \n    // Use array functions\n    \n?>',
            'hint': 'Try count(), sort(), rsort(), array_push(), array_pop()',
            'solution': '<?php\n    \$numbers = [5, 2, 8, 1, 9];\n    \n    echo "Original: " . implode(", ", \$numbers) . "\\n";\n    echo "Count: " . count(\$numbers) . "\\n";\n    \n    sort(\$numbers);\n    echo "Sorted: " . implode(", ", \$numbers) . "\\n";\n    \n    array_push(\$numbers, 10);\n    echo "After push: " . implode(", ", \$numbers) . "\\n";\n    \n    \$last = array_pop(\$numbers);\n    echo "Popped: " . \$last . "\\n";\n    echo "Final: " . implode(", ", \$numbers) . "\\n";\n?>',
            'testCases': ['Original: 5, 2, 8, 1, 9', 'Count: 5', 'Sorted: 1, 2, 5, 8, 9', 'After push: 1, 2, 5, 8, 9, 10', 'Popped: 10', 'Final: 1, 2, 5, 8, 9']
          },
        ];
        break;

      case 'PHP Conditions':
        _exercises = [
          {
            'title': 'If-Else Statement',
            'description': 'Use if-else to make decisions based on conditions',
            'starterCode': '<?php\n    \$score = 85;\n    \n    // Use if-else statement\n    \n?>',
            'hint': 'Use if-else to assign grades based on score',
            'solution': '<?php\n    \$score = 85;\n    \n    if (\$score >= 90) {\n        echo "Grade: A\\n";\n    } elseif (\$score >= 80) {\n        echo "Grade: B\\n";\n    } elseif (\$score >= 70) {\n        echo "Grade: C\\n";\n    } else {\n        echo "Grade: F\\n";\n    }\n?>',
            'testCases': ['Grade: B']
          },
          {
            'title': 'Switch Statement',
            'description': 'Use switch statement for multiple choices',
            'starterCode': '<?php\n    \$day = 3;\n    \n    // Use switch statement\n    \n?>',
            'hint': 'Use switch with cases for different day values',
            'solution': '<?php\n    \$day = 3;\n    \n    switch (\$day) {\n        case 1:\n            echo "Monday\\n";\n            break;\n        case 2:\n            echo "Tuesday\\n";\n            break;\n        case 3:\n            echo "Wednesday\\n";\n            break;\n        default:\n            echo "Invalid day\\n";\n    }\n?>',
            'testCases': ['Wednesday']
          },
          {
            'title': 'Ternary Operator',
            'description': 'Use ternary operator for simple conditions',
            'starterCode': '<?php\n    \$score = 85;\n    \n    // Use ternary operator\n    \n?>',
            'hint': 'Use condition ? value1 : value2 syntax',
            'solution': '<?php\n    \$score = 85;\n    \n    \$result = (\$score >= 60) ? "Pass" : "Fail";\n    echo "Result: " . \$result . "\\n";\n    \n    \$max = (\$score > 80) ? \$score : 80;\n    echo "Max score: " . \$max . "\\n";\n?>',
            'testCases': ['Result: Pass', 'Max score: 85']
          },
        ];
        break;

      case 'PHP Loops':
        _exercises = [
          {
            'title': 'For Loop',
            'description': 'Use for loop to repeat actions',
            'starterCode': '<?php\n    // Print numbers from 1 to 5 using for loop\n    \n?>',
            'hint': 'Use for (initialization; condition; increment) { code }',
            'solution': '<?php\n    for (\$i = 1; \$i <= 5; \$i++) {\n        echo \$i . "\\n";\n    }\n?>',
            'testCases': ['1', '2', '3', '4', '5']
          },
          {
            'title': 'While Loop',
            'description': 'Use while loop for conditional repetition',
            'starterCode': '<?php\n    \$count = 1;\n    \n    // Print numbers from 1 to 3 using while loop\n    \n?>',
            'hint': 'Use while (condition) { code } and update the condition variable',
            'solution': '<?php\n    \$count = 1;\n    \n    while (\$count <= 3) {\n        echo \$count . "\\n";\n        \$count++;\n    }\n?>',
            'testCases': ['1', '2', '3']
          },
          {
            'title': 'Foreach Loop',
            'description': 'Use foreach loop to iterate through arrays',
            'starterCode': '<?php\n    \$fruits = ["Apple", "Banana", "Cherry"];\n    \n    // Use foreach loop\n    \n?>',
            'hint': 'Use foreach (\$array as \$value) or foreach (\$array as \$key => \$value)',
            'solution': '<?php\n    \$fruits = ["Apple", "Banana", "Cherry"];\n    \n    echo "Fruits:\\n";\n    foreach (\$fruits as \$fruit) {\n        echo \$fruit . "\\n";\n    }\n    \n    echo "\\nWith index:\\n";\n    foreach (\$fruits as \$index => \$fruit) {\n        echo "Index " . \$index . ": " . \$fruit . "\\n";\n    }\n?>',
            'testCases': ['Fruits:', 'Apple', 'Banana', 'Cherry', 'With index:', 'Index 0: Apple', 'Index 1: Banana', 'Index 2: Cherry']
          },
        ];
        break;

      case 'PHP Functions':
        _exercises = [
          {
            'title': 'Basic Functions',
            'description': 'Create and call basic functions',
            'starterCode': '<?php\n    // Call functions\n    \n    // Create functions here\n?>',
            'hint': 'Create functions for greeting and addition',
            'solution': '<?php\n    function greet() {\n        echo "Hello from function!\\n";\n    }\n    \n    function add(\$a, \$b) {\n        return \$a + \$b;\n    }\n    \n    greet();\n    \$sum = add(5, 3);\n    echo "Sum: " . \$sum . "\\n";\n?>',
            'testCases': ['Hello from function!', 'Sum: 8']
          },
          {
            'title': 'Function Parameters',
            'description': 'Use different types of function parameters',
            'starterCode': '<?php\n    // Use functions with different parameters\n    \n    // Create functions\n?>',
            'hint': 'Create functions with default parameters and variable parameters',
            'solution': '<?php\n    function greetPerson(\$name = "Guest") {\n        echo "Hello, " . \$name . "!\\n";\n    }\n    \n    function multiply(\$a, \$b = 2) {\n        return \$a * \$b;\n    }\n    \n    greetPerson("John");\n    greetPerson();\n    \n    echo "Multiply 5 * 3: " . multiply(5, 3) . "\\n";\n    echo "Multiply 5 (default): " . multiply(5) . "\\n";\n?>',
            'testCases': ['Hello, John!', 'Hello, Guest!', 'Multiply 5 * 3: 15', 'Multiply 5 (default): 10']
          },
          {
            'title': 'Recursive Function',
            'description': 'Create a recursive function',
            'starterCode': '<?php\n    // Call recursive function\n    \n    // Create recursive function\n?>',
            'hint': 'Create factorial function that calls itself',
            'solution': '<?php\n    function factorial(\$n) {\n        if (\$n == 0 || \$n == 1) {\n            return 1;\n        }\n        return \$n * factorial(\$n - 1);\n    }\n    \n    \$fact = factorial(5);\n    echo "Factorial of 5: " . \$fact . "\\n";\n?>',
            'testCases': ['Factorial of 5: 120']
          },
        ];
        break;

      case 'PHP Forms':
        _exercises = [
          {
            'title': 'Basic Form Handling',
            'description': 'Create a simple form and handle form data',
            'starterCode': '<?php\n    // Handle form data\n    \n    // Display form\n?>',
            'hint': 'Use \$_POST superglobal to access form data',
            'solution': '<?php\n    if (\$_SERVER["REQUEST_METHOD"] == "POST") {\n        \$name = \$_POST[\'name\'] ?? \'\';\n        \$email = \$_POST[\'email\'] ?? \'\';\n        \n        if (!empty(\$name) && !empty(\$email)) {\n            echo "Thank you, " . \$name . "!\\n";\n            echo "Your email: " . \$email . "\\n";\n        } else {\n            echo "Please fill all fields.\\n";\n        }\n    }\n    \n    echo \'<form method="post">\n        Name: <input type="text" name="name"><br>\n        Email: <input type="email" name="email"><br>\n        <input type="submit" value="Submit">\n    </form>\';\n?>',
            'testCases': ['Thank you', 'Your email:', 'Please fill all fields']
          },
          {
            'title': 'Form Validation',
            'description': 'Validate form input data',
            'starterCode': '<?php\n    // Validate form data\n    \n    // Display form\n?>',
            'hint': 'Use filter_var() and empty() for validation',
            'solution': '<?php\n    \$errors = [];\n    \n    if (\$_SERVER["REQUEST_METHOD"] == "POST") {\n        \$name = trim(\$_POST[\'name\'] ?? \'\');\n        \$email = trim(\$_POST[\'email\'] ?? \'\');\n        \n        if (empty(\$name)) {\n            \$errors[] = "Name is required";\n        }\n        \n        if (empty(\$email)) {\n            \$errors[] = "Email is required";\n        } elseif (!filter_var(\$email, FILTER_VALIDATE_EMAIL)) {\n            \$errors[] = "Invalid email format";\n        }\n        \n        if (empty(\$errors)) {\n            echo "Form submitted successfully!\\n";\n            echo "Name: " . \$name . "\\n";\n            echo "Email: " . \$email . "\\n";\n        } else {\n            echo "Validation errors:\\n";\n            foreach (\$errors as \$error) {\n                echo "- " . \$error . "\\n";\n            }\n        }\n    }\n    \n    echo \'<form method="post">\n        Name: <input type="text" name="name"><br>\n        Email: <input type="email" name="email"><br>\n        <input type="submit" value="Submit">\n    </form>\';\n?>',
            'testCases': ['Form submitted successfully', 'Validation errors:', 'Name is required', 'Email is required', 'Invalid email format']
          },
          {
            'title': 'File Upload',
            'description': 'Handle file uploads in PHP',
            'starterCode': '<?php\n    // Handle file upload\n    \n    // Display upload form\n?>',
            'hint': 'Use \$_FILES superglobal and move_uploaded_file()',
            'solution': '<?php\n    if (\$_SERVER["REQUEST_METHOD"] == "POST" && isset(\$_FILES[\'file\'])) {\n        \$target_dir = "uploads/";\n        \$target_file = \$target_dir . basename(\$_FILES["file"]["name"]);\n        \n        // Check if file was uploaded without errors\n        if (\$_FILES["file"]["error"] == UPLOAD_ERR_OK) {\n            echo "File uploaded successfully!\\n";\n            echo "File name: " . \$_FILES["file"]["name"] . "\\n";\n            echo "File size: " . \$_FILES["file"]["size"] . " bytes\\n";\n            echo "File type: " . \$_FILES["file"]["type"] . "\\n";\n        } else {\n            echo "Error uploading file.\\n";\n        }\n    }\n    \n    echo \'<form method="post" enctype="multipart/form-data">\n        Select file: <input type="file" name="file"><br>\n        <input type="submit" value="Upload">\n    </form>\';\n?>',
            'testCases': ['File uploaded successfully', 'File name:', 'File size:', 'File type:', 'Error uploading file']
          },
        ];
        break;

      case 'PHP OOP':
        _exercises = [
          {
            'title': 'Basic Class and Object',
            'description': 'Create a simple class and instantiate objects',
            'starterCode': '<?php\n    // Create Car class\n    \n    // Create Car objects\n?>',
            'hint': 'Create Car class with attributes and methods, then create objects',
            'solution': '<?php\n    class Car {\n        public \$brand;\n        public \$model;\n        public \$year;\n        \n        public function displayInfo() {\n            echo \$this->brand . " " . \$this->model . " " . \$this->year . "\\n";\n        }\n    }\n    \n    \$car1 = new Car();\n    \$car1->brand = "Toyota";\n    \$car1->model = "Corolla";\n    \$car1->year = 2020;\n    \$car1->displayInfo();\n    \n    \$car2 = new Car();\n    \$car2->brand = "Honda";\n    \$car2->model = "Civic";\n    \$car2->year = 2022;\n    \$car2->displayInfo();\n?>',
            'testCases': ['Toyota Corolla 2020', 'Honda Civic 2022']
          },
          {
            'title': 'Constructor',
            'description': 'Use constructor to initialize objects',
            'starterCode': '<?php\n    // Create Student class with constructor\n    \n    // Create Student objects using constructor\n?>',
            'hint': 'Add constructor to Student class',
            'solution': '<?php\n    class Student {\n        public \$name;\n        public \$age;\n        \n        // Constructor\n        public function __construct(\$name, \$age) {\n            \$this->name = \$name;\n            \$this->age = \$age;\n        }\n        \n        public function display() {\n            echo "Name: " . \$this->name . ", Age: " . \$this->age . "\\n";\n        }\n    }\n    \n    \$student1 = new Student("Alice", 20);\n    \$student2 = new Student("Bob", 22);\n    \n    \$student1->display();\n    \$student2->display();\n?>',
            'testCases': ['Name: Alice, Age: 20', 'Name: Bob, Age: 22']
          },
          {
            'title': 'Inheritance',
            'description': 'Create classes with inheritance',
            'starterCode': '<?php\n    // Create base and derived classes\n    \n    // Create objects\n?>',
            'hint': 'Use extends keyword for inheritance',
            'solution': '<?php\n    class Vehicle {\n        public \$brand;\n        \n        public function __construct(\$brand) {\n            \$this->brand = \$brand;\n        }\n        \n        public function start() {\n            echo \$this->brand . " vehicle started.\\n";\n        }\n    }\n    \n    class Car extends Vehicle {\n        public \$model;\n        \n        public function __construct(\$brand, \$model) {\n            parent::__construct(\$brand);\n            \$this->model = \$model;\n        }\n        \n        public function displayInfo() {\n            echo "Brand: " . \$this->brand . ", Model: " . \$this->model . "\\n";\n        }\n    }\n    \n    \$car = new Car("Toyota", "Camry");\n    \$car->displayInfo();\n    \$car->start();\n?>',
            'testCases': ['Brand: Toyota, Model: Camry', 'Toyota vehicle started']
          },
        ];
        break;

      case 'PHP MySQL':
        _exercises = [
          {
            'title': 'Database Connection',
            'description': 'Connect to MySQL database using PDO',
            'starterCode': '<?php\n    // Connect to database\n    \n    // Handle connection\n?>',
            'hint': 'Use PDO for database connection with try-catch',
            'solution': '<?php\n    \$servername = "localhost";\n    \$username = "root";\n    \$password = "";\n    \$dbname = "testdb";\n    \n    try {\n        \$conn = new PDO("mysql:host=\$servername;dbname=\$dbname", \$username, \$password);\n        \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);\n        echo "Connected successfully to database!\\n";\n    } catch(PDOException \$e) {\n        echo "Connection failed: " . \$e->getMessage() . "\\n";\n    }\n?>',
            'testCases': ['Connected successfully to database', 'Connection failed']
          },
          {
            'title': 'Create Table',
            'description': 'Create a table in MySQL database',
            'starterCode': '<?php\n    // Create users table\n    \n    // Handle table creation\n?>',
            'hint': 'Use CREATE TABLE SQL statement with PDO',
            'solution': '<?php\n    \$servername = "localhost";\n    \$username = "root";\n    \$password = "";\n    \$dbname = "testdb";\n    \n    try {\n        \$conn = new PDO("mysql:host=\$servername;dbname=\$dbname", \$username, \$password);\n        \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);\n        \n        \$sql = "CREATE TABLE IF NOT EXISTS users (\n            id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,\n            firstname VARCHAR(30) NOT NULL,\n            lastname VARCHAR(30) NOT NULL,\n            email VARCHAR(50),\n            reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP\n        )";\n        \n        \$conn->exec(\$sql);\n        echo "Table created successfully!\\n";\n    } catch(PDOException \$e) {\n        echo "Error: " . \$e->getMessage() . "\\n";\n    }\n?>',
            'testCases': ['Table created successfully', 'Error:']
          },
          {
            'title': 'Insert and Select Data',
            'description': 'Insert data into table and retrieve it',
            'starterCode': '<?php\n    // Insert and select data\n    \n    // Handle database operations\n?>',
            'hint': 'Use INSERT and SELECT SQL statements',
            'solution': '<?php\n    \$servername = "localhost";\n    \$username = "root";\n    \$password = "";\n    \$dbname = "testdb";\n    \n    try {\n        \$conn = new PDO("mysql:host=\$servername;dbname=\$dbname", \$username, \$password);\n        \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);\n        \n        // Insert data\n        \$sql = "INSERT INTO users (firstname, lastname, email) VALUES (\'John\', \'Doe\', \'john@example.com\')";\n        \$conn->exec(\$sql);\n        echo "New record created successfully!\\n";\n        \n        // Select data\n        \$stmt = \$conn->prepare("SELECT id, firstname, lastname FROM users");\n        \$stmt->execute();\n        \n        echo "Users in database:\\n";\n        while (\$row = \$stmt->fetch()) {\n            echo "ID: " . \$row[\'id\'] . " - Name: " . \$row[\'firstname\'] . " " . \$row[\'lastname\'] . "\\n";\n        }\n    } catch(PDOException \$e) {\n        echo "Error: " . \$e->getMessage() . "\\n";\n    }\n?>',
            'testCases': ['New record created successfully', 'Users in database:', 'ID:', 'Name: John Doe']
          },
        ];
        break;

      case 'PHP Sessions':
        _exercises = [
          {
            'title': 'Session Basics',
            'description': 'Start session and set session variables',
            'starterCode': '<?php\n    // Work with sessions\n    \n    // Set session variables\n?>',
            'hint': 'Use session_start() and \$_SESSION superglobal',
            'solution': '<?php\n    session_start();\n    \n    // Set session variables\n    \$_SESSION["username"] = "john_doe";\n    \$_SESSION["email"] = "john@example.com";\n    \$_SESSION["login_time"] = date(\'Y-m-d H:i:s\');\n    \n    echo "Session started!\\n";\n    echo "Welcome " . \$_SESSION["username"] . "!\\n";\n    \n    echo "\\nSession data:\\n";\n    foreach(\$_SESSION as \$key => \$value) {\n        echo \$key . ": " . \$value . "\\n";\n    }\n?>',
            'testCases': ['Session started', 'Welcome john_doe', 'Session data:', 'username: john_doe', 'email: john@example.com']
          },
          {
            'title': 'Session Management',
            'description': 'Modify and destroy session data',
            'starterCode': '<?php\n    // Manage session data\n    \n    // Modify and destroy session\n?>',
            'hint': 'Use session_unset() and session_destroy()',
            'solution': '<?php\n    session_start();\n    \n    // Check if session variable exists\n    if(isset(\$_SESSION["username"])) {\n        echo "User is logged in as: " . \$_SESSION["username"] . "\\n";\n        \n        // Modify session variable\n        \$_SESSION["username"] = "john_updated";\n        echo "Updated username: " . \$_SESSION["username"] . "\\n";\n        \n        // Destroy session (logout)\n        if(isset(\$_GET[\'logout\'])) {\n            session_unset();\n            session_destroy();\n            echo "Session destroyed!\\n";\n        }\n    } else {\n        echo "No active session.\\n";\n    }\n?>',
            'testCases': ['User is logged in as:', 'Updated username: john_updated', 'Session destroyed', 'No active session']
          },
          {
            'title': 'Cookies',
            'description': 'Work with cookies in PHP',
            'starterCode': '<?php\n    // Work with cookies\n    \n    // Set and read cookies\n?>',
            'hint': 'Use setcookie() and \$_COOKIE superglobal',
            'solution': '<?php\n    // Set cookie\n    \$cookie_name = "user";\n    \$cookie_value = "John Doe";\n    setcookie(\$cookie_name, \$cookie_value, time() + (86400 * 30), "/"); // 30 days\n    \n    echo "Cookie set!\\n";\n    \n    // Check if cookie exists\n    if(isset(\$_COOKIE[\$cookie_name])) {\n        echo "Cookie \'" . \$cookie_name . "\' is set!\\n";\n        echo "Value is: " . \$_COOKIE[\$cookie_name] . "\\n";\n    } else {\n        echo "Cookie is not set!\\n";\n    }\n    \n    // Delete cookie\n    if(isset(\$_GET[\'delete_cookie\'])) {\n        setcookie(\$cookie_name, "", time() - 3600, "/");\n        echo "Cookie deleted!\\n";\n    }\n?>',
            'testCases': ['Cookie set', 'Cookie \'user\' is set', 'Value is: John Doe', 'Cookie is not set', 'Cookie deleted']
          },
        ];
        break;

      case 'PHP File Handling':
        _exercises = [
          {
            'title': 'Write to File',
            'description': 'Create and write data to a text file',
            'starterCode': '<?php\n    // Write data to a file\n    \n    // Handle file writing\n?>',
            'hint': 'Use file_put_contents() or fopen() with fwrite()',
            'solution': '<?php\n    \$file = "example.txt";\n    \$content = "Hello PHP File Handling!\\nThis is a sample file.\\n";\n    \n    if (file_put_contents(\$file, \$content) !== false) {\n        echo "File written successfully!\\n";\n    } else {\n        echo "Cannot write to file\\n";\n    }\n    \n    // Alternative method\n    \$handle = fopen("data.txt", "w");\n    if (\$handle) {\n        fwrite(\$handle, "Line 1\\n");\n        fwrite(\$handle, "Line 2\\n");\n        fwrite(\$handle, "Line 3\\n");\n        fclose(\$handle);\n        echo "Data written to data.txt\\n";\n    }\n?>',
            'testCases': ['File written successfully', 'Cannot write to file', 'Data written to data.txt']
          },
          {
            'title': 'Read from File',
            'description': 'Read and display content from a text file',
            'starterCode': '<?php\n    // Read data from file\n    \n    // Handle file reading\n?>',
            'hint': 'Use file_get_contents() or fopen() with fgets()',
            'solution': '<?php\n    \$file = "example.txt";\n    \n    if (file_exists(\$file)) {\n        echo "File content:\\n";\n        echo file_get_contents(\$file);\n    } else {\n        echo "File does not exist\\n";\n    }\n    \n    // Alternative method\n    \$handle = fopen("data.txt", "r");\n    if (\$handle) {\n        echo "\\nReading line by line:\\n";\n        while ((\$line = fgets(\$handle)) !== false) {\n            echo "Line: " . trim(\$line) . "\\n";\n        }\n        fclose(\$handle);\n    }\n?>',
            'testCases': ['File content:', 'Hello PHP File Handling', 'File does not exist', 'Reading line by line:', 'Line: Line 1']
          },
          {
            'title': 'File Information',
            'description': 'Get information about a file',
            'starterCode': '<?php\n    // Get file information\n    \n    // Display file details\n?>',
            'hint': 'Use file_exists(), filesize(), filemtime() functions',
            'solution': '<?php\n    \$file = "example.txt";\n    \n    if (file_exists(\$file)) {\n        echo "File name: " . \$file . "\\n";\n        echo "File size: " . filesize(\$file) . " bytes\\n";\n        echo "Last modified: " . date("F d Y H:i:s.", filemtime(\$file)) . "\\n";\n        echo "Readable: " . (is_readable(\$file) ? "Yes" : "No") . "\\n";\n        echo "Writable: " . (is_writable(\$file) ? "Yes" : "No") . "\\n";\n    } else {\n        echo "File does not exist.\\n";\n    }\n    \n    // Directory listing\n    echo "\\nDirectory listing:\\n";\n    \$files = scandir(".");\n    foreach(\$files as \$file) {\n        if (\$file != "." && \$file != "..") {\n            echo \$file . "\\n";\n        }\n    }\n?>',
            'testCases': ['File name:', 'File size:', 'Last modified:', 'Readable: Yes', 'Writable: Yes', 'Directory listing:']
          },
        ];
        break;

      case 'PHP Error Handling':
        _exercises = [
          {
            'title': 'Basic Exception Handling',
            'description': 'Use try-catch blocks to handle exceptions',
            'starterCode': '<?php\n    // Use try-catch for exception handling\n    \n    // Handle exceptions\n?>',
            'hint': 'Use try, catch, and throw keywords',
            'solution': '<?php\n    function divide(\$a, \$b) {\n        if (\$b == 0) {\n            throw new Exception("Division by zero!");\n        }\n        return \$a / \$b;\n    }\n    \n    try {\n        echo divide(10, 2) . "\\n";\n        echo divide(10, 0) . "\\n";\n    } catch (Exception \$e) {\n        echo "Error: " . \$e->getMessage() . "\\n";\n    } finally {\n        echo "This always executes\\n";\n    }\n?>',
            'testCases': ['5', 'Error: Division by zero', 'This always executes']
          },
          {
            'title': 'Custom Exceptions',
            'description': 'Create and use custom exception classes',
            'starterCode': '<?php\n    // Create custom exception\n    \n    // Use custom exception\n?>',
            'hint': 'Create class that extends Exception',
            'solution': '<?php\n    class CustomException extends Exception {\n        public function errorMessage() {\n            return "Custom Error: " . \$this->getMessage();\n        }\n    }\n    \n    function checkNumber(\$number) {\n        if (\$number < 0) {\n            throw new CustomException("Number cannot be negative");\n        }\n        if (\$number > 100) {\n            throw new Exception("Number cannot be greater than 100");\n        }\n        return \$number;\n    }\n    \n    try {\n        echo checkNumber(50) . "\\n";\n        echo checkNumber(-5) . "\\n";\n    } catch (CustomException \$e) {\n        echo \$e->errorMessage() . "\\n";\n    } catch (Exception \$e) {\n        echo "General Error: " . \$e->getMessage() . "\\n";\n    }\n?>',
            'testCases': ['50', 'Custom Error: Number cannot be negative', 'General Error: Number cannot be greater than 100']
          },
          {
            'title': 'Error Reporting',
            'description': 'Configure error reporting and logging',
            'starterCode': '<?php\n    // Configure error reporting\n    \n    // Handle errors\n?>',
            'hint': 'Use error_reporting(), set_error_handler()',
            'solution': '<?php\n    // Set error reporting\n    error_reporting(E_ALL);\n    ini_set(\'display_errors\', 1);\n    \n    // Custom error handler\n    function customErrorHandler(\$errno, \$errstr, \$errfile, \$errline) {\n        echo "<b>Custom error:</b> [\$errno] \$errstr\\n";\n        echo "Error on line \$errline in \$errfile\\n";\n    }\n    \n    set_error_handler("customErrorHandler");\n    \n    // Trigger errors\n    echo \$undefinedVariable; // This will trigger custom error handler\n    \n    // Restore original error handler\n    restore_error_handler();\n    \n    echo "Program continues after error handling.\\n";\n    \n    // Error logging\n    error_log("This is a custom error message", 3, "error_log.txt");\n    echo "Error logged to file.\\n";\n?>',
            'testCases': ['Custom error:', 'Error on line', 'Program continues after error handling', 'Error logged to file']
          },
        ];
        break;

      default:
        _exercises = [
          {
            'title': 'Basic PHP Program',
            'description': 'Write a simple PHP program',
            'starterCode': '<?php\n    // Write your code here\n    \n?>',
            'hint': 'Start with echo to display output',
            'solution': '<?php\n    echo "Welcome to PHP Programming!";\n?>',
            'testCases': ['Welcome to PHP Programming!']
          },
        ];
    }
  }

  void _runCode() {
    setState(() {
      _isRunning = true;
      _output = '🚀 Executing your PHP code...\n\n';
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isRunning = false;

        List<String> errors = _checkForErrors(_codeController.text);

        if (errors.isEmpty) {
          _output += '✅ No syntax errors found!\n';
          _output += '✅ Executing program...\n\n';

          String userOutput = _simulateProgramExecution(_codeController.text);
          _output += userOutput;

          _checkSolution(userOutput);
        } else {
          _output += '❌ PHP syntax errors found:\n\n';

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

    // Check for PHP tags
    if (!code.contains('<?php') && !code.contains('<?=')) {
      errors.add('Missing PHP opening tag: <?php');
    }

    // Check for semicolons
    List<String> lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Check for semicolons in PHP statements
      if ((line.contains('echo') || (line.contains(r'$') && line.contains('='))) &&
          !line.endsWith(';') && !line.endsWith('{') && !line.endsWith('}') &&
          !line.startsWith('//') && !line.startsWith('/*') && !line.startsWith('*') &&
          !line.endsWith('*/') && line.isNotEmpty && !line.contains('<?php') &&
          !line.contains('?>') && !line.contains('function') && !line.contains('class')) {
        errors.add('Missing semicolon (;) at line ${i + 1}');
      }

      // Check for string quotes
      if (_countOccurrences(line, '"') % 2 != 0) {
        errors.add('Unclosed quotation marks (") at line ${i + 1}');
      }

      // Check for single quotes
      if (_countOccurrences(line, "'") % 2 != 0) {
        errors.add("Unclosed single quote (') at line ${i + 1}");
      }
    }

    // Check for matching braces
    int openBraces = _countOccurrences(code, '{');
    int closeBraces = _countOccurrences(code, '}');
    if (openBraces != closeBraces) {
      errors.add('Unmatched curly braces { }');
    }

    // Check for matching parentheses
    int openParen = _countOccurrences(code, '(');
    int closeParen = _countOccurrences(code, ')');
    if (openParen != closeParen) {
      errors.add('Unmatched parentheses ( )');
    }

    return errors;
  }

  String _simulateProgramExecution(String code) {
    Map<String, dynamic> variables = {};
    List<String> outputLines = [];

    String cleanCode = code.replaceAll(RegExp(r'//.*'), '');
    cleanCode = cleanCode.replaceAll(RegExp(r'/\*.*?\*/', multiLine: true), '');
    cleanCode = cleanCode.replaceAll(RegExp(r'<\?php|\?>'), '');

    List<String> lines = cleanCode.split('\n');

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Variable declaration and assignment
      if (line.contains(r'$') && line.contains('=') && !line.contains('echo') && !line.contains('function')) {
        RegExp varRegex = RegExp(r'\$(\w+)\s*=\s*(.+);');
        Match? match = varRegex.firstMatch(line);
        if (match != null) {
          String varName = match.group(1)!;
          String value = match.group(2)!;
          value = value.replaceAll('"', '').replaceAll(';', '').trim();

          // Handle different value types
          if (value == 'true') {
            variables[varName] = true;
          } else if (value == 'false') {
            variables[varName] = false;
          } else if (RegExp(r'^\d+$').hasMatch(value)) {
            variables[varName] = int.parse(value);
          } else if (RegExp(r'^\d+\.\d+$').hasMatch(value)) {
            variables[varName] = double.parse(value);
          } else {
            variables[varName] = value;
          }
        }
      }

      // Output statements
      if (line.contains('echo')) {
        String output = _processEchoStatement(line, variables);
        if (output.isNotEmpty) {
          outputLines.add(output);
        }
      }

      // Function calls
      if (line.contains('var_dump')) {
        String output = _processVarDump(line, variables);
        if (output.isNotEmpty) {
          outputLines.add(output);
        }
      }
    }

    return outputLines.join('\n');
  }

  String _processEchoStatement(String line, Map<String, dynamic> variables) {
    String output = '';

    if (line.contains('echo')) {
      String content = line.substring(line.indexOf('echo') + 4).replaceAll(';', '').trim();

      // Handle concatenation
      if (content.contains('.')) {
        List<String> parts = content.split('.');
        for (String part in parts) {
          part = part.trim().replaceAll('"', '').replaceAll("'", "");

          if (part.startsWith(r'$') && variables.containsKey(part.substring(1))) {
            output += variables[part.substring(1)].toString();
          } else {
            output += part;
          }
        }
      } else {
        // Simple string output
        content = content.replaceAll('"', '').replaceAll("'", "");
        if (content.startsWith(r'$') && variables.containsKey(content.substring(1))) {
          output += variables[content.substring(1)].toString();
        } else {
          output += content;
        }
      }

      // Handle newlines
      if (line.contains(r'\n')) {
        output = output.replaceAll(r'\n', '\n');
      }
    }

    return output;
  }

  String _processVarDump(String line, Map<String, dynamic> variables) {
    String output = '';

    if (line.contains('var_dump')) {
      String content = line.substring(line.indexOf('var_dump') + 8);
      content = content.substring(1, content.lastIndexOf(')')).trim();

      if (content.startsWith(r'$') && variables.containsKey(content.substring(1))) {
        dynamic value = variables[content.substring(1)];
        if (value is String) {
          output = 'string(${value.length}) "$value"';
        } else if (value is int) {
          output = 'int($value)';
        } else if (value is double) {
          output = 'float($value)';
        } else if (value is bool) {
          output = 'bool(${value ? 'true' : 'false'})';
        }
      }
    }

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
    bool allTestsPassed = true;
    List<String> failedTests = [];

    for (String testCase in testCases) {
      if (!userOutput.contains(testCase)) {
        allTestsPassed = false;
        failedTests.add(testCase);
      }
    }

    if (allTestsPassed) {
      _output += '\n🎉 All tests passed! Excellent work!\n';
    } else {
      _output += '\n⚠️  Some tests failed:\n';
      for (String failedTest in failedTests) {
        _output += '   • Expected: $failedTest\n';
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
                        'Expected Output:',
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
                language: 'php',
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
          content: Text('🎉 Congratulations! You completed all PHP exercises!'),
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
          'PHP IDE - ${widget.moduleTitle}',
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
                    Icon(Icons.code,
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
                        '📝 PHP Code Editor',
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
                        tooltip: 'Reset Code',
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
                                      language: 'php',
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
                      '📊 Output',
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
                        _output.isEmpty ? '🚀 Click "Run Code" to execute your PHP program...' : _output,
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
                        '📝 PHP Code Editor',
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
                        tooltip: 'Reset Code',
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
                                      language: 'php',
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
                      '📊 Output',
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
                        _output.isEmpty ? '🚀 Click "Run Code" to execute your PHP program...' : _output,
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
              _isRunning ? 'Running...' : 'Run Code',
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