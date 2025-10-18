import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/darcula.dart';

class CppPracticeScreen extends StatefulWidget {
  final String moduleTitle;
  final Color primaryColor;
  final String language;

  const CppPracticeScreen({
    Key? key,
    required this.moduleTitle,
    required this.primaryColor,
    required this.language,
  }) : super(key: key);

  @override
  State<CppPracticeScreen> createState() => _CppPracticeScreenState();
}

class _CppPracticeScreenState extends State<CppPracticeScreen> {
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
      case 'C++ Introduction':
        _exercises = [
          {
            'title': 'Hello World Program',
            'description': 'Write your first C++ program that displays "Hello, World!"',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Write your code here\n    \n    return 0;\n}',
            'hint': 'Use cout << "Hello, World!"; to display text. Make sure to include the semicolon at the end.',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Hello, World!";\n    return 0;\n}',
            'testCases': ['Hello, World!']
          },
          {
            'title': 'Basic Output',
            'description': 'Display your name and age using cout statements',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Display your name\n    \n    // Display your age\n    \n    return 0;\n}',
            'hint': 'Use multiple cout statements. Example: cout << "Name: John"; and cout << "Age: 25";',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Name: John" << endl;\n    cout << "Age: 25" << endl;\n    return 0;\n}',
            'testCases': ['Name: John', 'Age: 25']
          },
          {
            'title': 'Multiple Lines Output',
            'description': 'Display text on different lines using endl or \\n',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Display text on multiple lines\n    \n    return 0;\n}',
            'hint': 'Use endl or \\n to create new lines. Example: cout << "Line 1" << endl; or cout << "Line 2\\n";',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Line 1" << endl;\n    cout << "Line 2" << endl;\n    cout << "Line 3" << endl;\n    return 0;\n}',
            'testCases': ['Line 1', 'Line 2', 'Line 3']
          },
        ];
        break;

      case 'C++ Syntax':
        _exercises = [
          {
            'title': 'Variable Declaration',
            'description': 'Declare different types of variables and display them',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Declare variables here\n    \n    // Display variables\n    \n    return 0;\n}',
            'hint': 'Declare int, double, char, bool, and string variables. Example: int age = 25; double price = 19.99;',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    int age = 25;\n    double price = 19.99;\n    char grade = \'A\';\n    bool isStudent = true;\n    string name = "John";\n    \n    cout << "Age: " << age << endl;\n    cout << "Price: " << price << endl;\n    cout << "Grade: " << grade << endl;\n    cout << "Is Student: " << isStudent << endl;\n    cout << "Name: " << name << endl;\n    \n    return 0;\n}',
            'testCases': ['Age: 25', 'Price: 19.99', 'Grade: A', 'Is Student: 1', 'Name: John']
          },
          {
            'title': 'Basic Input',
            'description': 'Get user input and display it back',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    // Get user input\n    \n    // Display the input\n    \n    return 0;\n}',
            'hint': 'Use cin to get input. Example: cin >> variable;',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string name;\n    int age;\n    \n    cout << "Enter your name: ";\n    cin >> name;\n    cout << "Enter your age: ";\n    cin >> age;\n    \n    cout << "Hello " << name << ", you are " << age << " years old." << endl;\n    \n    return 0;\n}',
            'testCases': ['Hello', 'years old']
          },
          {
            'title': 'Comments Practice',
            'description': 'Use single-line and multi-line comments in your code',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Add your code with comments\n    \n    return 0;\n}',
            'hint': 'Use // for single-line comments and /* */ for multi-line comments',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // This is a single-line comment\n    \n    /*\n    This is a multi-line comment\n    It can span multiple lines\n    */\n    \n    cout << "Learning C++ comments!" << endl;  // Comment after code\n    \n    return 0;\n}',
            'testCases': ['Learning C++ comments!']
          },
        ];
        break;

      case 'C++ Data Types':
        _exercises = [
          {
            'title': 'Basic Data Types',
            'description': 'Work with int, float, double, char, and bool',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Declare basic data types\n    \n    return 0;\n}',
            'hint': 'Declare variables: int, float, double, char, bool with appropriate values',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int integerVar = 100;\n    float floatVar = 3.14f;\n    double doubleVar = 3.14159;\n    char charVar = \'C\';\n    bool boolVar = true;\n    \n    cout << "Integer: " << integerVar << endl;\n    cout << "Float: " << floatVar << endl;\n    cout << "Double: " << doubleVar << endl;\n    cout << "Character: " << charVar << endl;\n    cout << "Boolean: " << boolVar << endl;\n    \n    return 0;\n}',
            'testCases': ['Integer: 100', 'Float: 3.14', 'Double: 3.14159', 'Character: C', 'Boolean: 1']
          },
          {
            'title': 'Type Modifiers',
            'description': 'Use short, long, unsigned, and signed modifiers',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Use type modifiers\n    \n    return 0;\n}',
            'hint': 'Try short, long, unsigned int with appropriate values',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    short shortVar = 32767;\n    long longVar = 2147483647L;\n    unsigned int unsignedVar = 4000000000;\n    signed int signedVar = -100;\n    \n    cout << "Short: " << shortVar << endl;\n    cout << "Long: " << longVar << endl;\n    cout << "Unsigned: " << unsignedVar << endl;\n    cout << "Signed: " << signedVar << endl;\n    \n    return 0;\n}',
            'testCases': ['Short: 32767', 'Long: 2147483647', 'Unsigned: 4000000000', 'Signed: -100']
          },
          {
            'title': 'Sizeof Operator',
            'description': 'Use sizeof to find the size of different data types',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Use sizeof operator\n    \n    return 0;\n}',
            'hint': 'Use sizeof(variable) or sizeof(datatype) to get size in bytes',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Size of int: " << sizeof(int) << " bytes" << endl;\n    cout << "Size of float: " << sizeof(float) << " bytes" << endl;\n    cout << "Size of double: " << sizeof(double) << " bytes" << endl;\n    cout << "Size of char: " << sizeof(char) << " bytes" << endl;\n    cout << "Size of bool: " << sizeof(bool) << " bytes" << endl;\n    \n    return 0;\n}',
            'testCases': ['Size of int:', 'bytes', 'Size of float:', 'Size of double:', 'Size of char:', 'Size of bool:']
          },
        ];
        break;

      case 'C++ Operators':
        _exercises = [
          {
            'title': 'Arithmetic Operators',
            'description': 'Perform basic arithmetic operations',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int a = 15, b = 4;\n    \n    // Perform arithmetic operations\n    \n    return 0;\n}',
            'hint': 'Use +, -, *, /, % operators with variables a and b',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int a = 15, b = 4;\n    \n    cout << "a + b = " << (a + b) << endl;\n    cout << "a - b = " << (a - b) << endl;\n    cout << "a * b = " << (a * b) << endl;\n    cout << "a / b = " << (a / b) << endl;\n    cout << "a % b = " << (a % b) << endl;\n    \n    return 0;\n}',
            'testCases': ['a + b = 19', 'a - b = 11', 'a * b = 60', 'a / b = 3', 'a % b = 3']
          },
          {
            'title': 'Comparison Operators',
            'description': 'Use comparison operators to compare values',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int x = 10, y = 20;\n    \n    // Use comparison operators\n    \n    return 0;\n}',
            'hint': 'Use ==, !=, >, <, >=, <= to compare x and y',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int x = 10, y = 20;\n    \n    cout << "x == y: " << (x == y) << endl;\n    cout << "x != y: " << (x != y) << endl;\n    cout << "x > y: " << (x > y) << endl;\n    cout << "x < y: " << (x < y) << endl;\n    cout << "x >= y: " << (x >= y) << endl;\n    cout << "x <= y: " << (x <= y) << endl;\n    \n    return 0;\n}',
            'testCases': ['x == y: 0', 'x != y: 1', 'x > y: 0', 'x < y: 1', 'x >= y: 0', 'x <= y: 1']
          },
          {
            'title': 'Logical Operators',
            'description': 'Use logical operators with boolean values',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    bool p = true, q = false;\n    \n    // Use logical operators\n    \n    return 0;\n}',
            'hint': 'Use && (AND), || (OR), ! (NOT) with p and q',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    bool p = true, q = false;\n    \n    cout << "p && q: " << (p && q) << endl;\n    cout << "p || q: " << (p || q) << endl;\n    cout << "!p: " << (!p) << endl;\n    cout << "!q: " << (!q) << endl;\n    \n    return 0;\n}',
            'testCases': ['p && q: 0', 'p || q: 1', '!p: 0', '!q: 1']
          },
        ];
        break;

      case 'C++ Strings':
        _exercises = [
          {
            'title': 'String Basics',
            'description': 'Create and manipulate strings',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    // Work with strings\n    \n    return 0;\n}',
            'hint': 'Create strings, concatenate them, and find length',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string firstName = "John";\n    string lastName = "Doe";\n    string fullName = firstName + " " + lastName;\n    \n    cout << "First Name: " << firstName << endl;\n    cout << "Last Name: " << lastName << endl;\n    cout << "Full Name: " << fullName << endl;\n    cout << "Length: " << fullName.length() << endl;\n    \n    return 0;\n}',
            'testCases': ['First Name: John', 'Last Name: Doe', 'Full Name: John Doe', 'Length: 8']
          },
          {
            'title': 'String Methods',
            'description': 'Use various string methods',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string text = "Hello C++ Programming";\n    \n    // Use string methods\n    \n    return 0;\n}',
            'hint': 'Try substr(), find(), replace() methods on the text string',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string text = "Hello C++ Programming";\n    \n    cout << "Original: " << text << endl;\n    cout << "Substring: " << text.substr(0, 5) << endl;\n    cout << "Find C++: " << text.find("C++") << endl;\n    \n    text.replace(6, 3, "Java");\n    cout << "After replace: " << text << endl;\n    \n    return 0;\n}',
            'testCases': ['Original: Hello C++ Programming', 'Substring: Hello', 'Find C++: 6', 'After replace: Hello Java Programming']
          },
          {
            'title': 'String Input',
            'description': 'Get string input from user',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    // Get string input\n    \n    return 0;\n}',
            'hint': 'Use getline(cin, variable) to get full line input',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string name, city;\n    \n    cout << "Enter your name: ";\n    getline(cin, name);\n    \n    cout << "Enter your city: ";\n    getline(cin, city);\n    \n    cout << "Hello " << name << " from " << city << "!" << endl;\n    \n    return 0;\n}',
            'testCases': ['Hello', 'from']
          },
        ];
        break;

      case 'C++ Math':
        _exercises = [
          {
            'title': 'Basic Math Operations',
            'description': 'Use basic math functions like sqrt, pow, abs',
            'starterCode': '#include <iostream>\n#include <cmath>\nusing namespace std;\n\nint main() {\n    double number = 16.0;\n    \n    // Use math functions\n    \n    return 0;\n}',
            'hint': 'Use sqrt(), pow(), abs() functions from cmath library',
            'solution': '#include <iostream>\n#include <cmath>\nusing namespace std;\n\nint main() {\n    double number = 16.0;\n    \n    cout << "Square root: " << sqrt(number) << endl;\n    cout << "Power: " << pow(2, 3) << endl;\n    cout << "Absolute: " << abs(-5) << endl;\n    \n    return 0;\n}',
            'testCases': ['Square root: 4', 'Power: 8', 'Absolute: 5']
          },
          {
            'title': 'Rounding Functions',
            'description': 'Use round, ceil, and floor functions',
            'starterCode': '#include <iostream>\n#include <cmath>\nusing namespace std;\n\nint main() {\n    double num1 = 3.7, num2 = 3.2;\n    \n    // Use rounding functions\n    \n    return 0;\n}',
            'hint': 'Use round(), ceil(), floor() for different rounding methods',
            'solution': '#include <iostream>\n#include <cmath>\nusing namespace std;\n\nint main() {\n    double num1 = 3.7, num2 = 3.2;\n    \n    cout << "Round 3.7: " << round(3.7) << endl;\n    cout << "Ceil 3.2: " << ceil(3.2) << endl;\n    cout << "Floor 3.8: " << floor(3.8) << endl;\n    \n    return 0;\n}',
            'testCases': ['Round 3.7: 4', 'Ceil 3.2: 4', 'Floor 3.8: 3']
          },
          {
            'title': 'Max and Min Functions',
            'description': 'Find maximum and minimum values',
            'starterCode': '#include <iostream>\n#include <cmath>\nusing namespace std;\n\nint main() {\n    // Find max and min\n    \n    return 0;\n}',
            'hint': 'Use max() and min() functions to compare values',
            'solution': '#include <iostream>\n#include <cmath>\nusing namespace std;\n\nint main() {\n    cout << "Max of 10 and 20: " << max(10, 20) << endl;\n    cout << "Min of 10 and 20: " << min(10, 20) << endl;\n    \n    return 0;\n}',
            'testCases': ['Max of 10 and 20: 20', 'Min of 10 and 20: 10']
          },
        ];
        break;

      case 'C++ Conditions':
        _exercises = [
          {
            'title': 'If-Else Statement',
            'description': 'Use if-else to make decisions based on conditions',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int score = 85;\n    \n    // Use if-else statement\n    \n    return 0;\n}',
            'hint': 'Use if-else to assign grades based on score',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int score = 85;\n    \n    if (score >= 90) {\n        cout << "Grade: A" << endl;\n    } else if (score >= 80) {\n        cout << "Grade: B" << endl;\n    } else if (score >= 70) {\n        cout << "Grade: C" << endl;\n    } else {\n        cout << "Grade: F" << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['Grade: B']
          },
          {
            'title': 'Switch Statement',
            'description': 'Use switch statement for multiple choices',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int day = 3;\n    \n    // Use switch statement\n    \n    return 0;\n}',
            'hint': 'Use switch with cases for different day values',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int day = 3;\n    \n    switch (day) {\n        case 1:\n            cout << "Monday" << endl;\n            break;\n        case 2:\n            cout << "Tuesday" << endl;\n            break;\n        case 3:\n            cout << "Wednesday" << endl;\n            break;\n        default:\n            cout << "Invalid day" << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['Wednesday']
          },
          {
            'title': 'Ternary Operator',
            'description': 'Use ternary operator for simple conditions',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int score = 85;\n    \n    // Use ternary operator\n    \n    return 0;\n}',
            'hint': 'Use condition ? value1 : value2 syntax',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int score = 85;\n    \n    string result = (score >= 60) ? "Pass" : "Fail";\n    cout << "Result: " << result << endl;\n    \n    return 0;\n}',
            'testCases': ['Result: Pass']
          },
        ];
        break;

      case 'C++ Loops':
        _exercises = [
          {
            'title': 'For Loop',
            'description': 'Use for loop to repeat actions',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Print numbers from 1 to 5 using for loop\n    \n    return 0;\n}',
            'hint': 'Use for (initialization; condition; increment) { code }',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    for (int i = 1; i <= 5; i++) {\n        cout << i << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['1', '2', '3', '4', '5']
          },
          {
            'title': 'While Loop',
            'description': 'Use while loop for conditional repetition',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int count = 1;\n    \n    // Print numbers from 1 to 3 using while loop\n    \n    return 0;\n}',
            'hint': 'Use while (condition) { code } and update the condition variable',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int count = 1;\n    \n    while (count <= 3) {\n        cout << count << endl;\n        count++;\n    }\n    \n    return 0;\n}',
            'testCases': ['1', '2', '3']
          },
          {
            'title': 'Break and Continue',
            'description': 'Use break and continue in loops',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Use break and continue\n    \n    return 0;\n}',
            'hint': 'Use break to exit loop, continue to skip current iteration',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    for (int i = 1; i <= 5; i++) {\n        if (i == 3) continue;\n        if (i == 5) break;\n        cout << i << " ";\n    }\n    cout << endl;\n    \n    return 0;\n}',
            'testCases': ['1 2 4']
          },
        ];
        break;

      case 'C++ Arrays':
        _exercises = [
          {
            'title': 'Single-dimensional Array',
            'description': 'Create and use a single-dimensional array',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Create and display array\n    \n    return 0;\n}',
            'hint': 'Declare array with type name[size] and use for loop to display',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int numbers[5] = {1, 2, 3, 4, 5};\n    \n    for (int i = 0; i < 5; i++) {\n        cout << numbers[i] << " ";\n    }\n    cout << endl;\n    \n    return 0;\n}',
            'testCases': ['1 2 3 4 5']
          },
          {
            'title': 'Multi-dimensional Array',
            'description': 'Work with 2D arrays',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Create and display 2D array\n    \n    return 0;\n}',
            'hint': 'Use nested loops for 2D arrays',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int matrix[2][3] = {{1, 2, 3}, {4, 5, 6}};\n    \n    for (int i = 0; i < 2; i++) {\n        for (int j = 0; j < 3; j++) {\n            cout << matrix[i][j] << " ";\n        }\n        cout << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['1 2 3', '4 5 6']
          },
          {
            'title': 'Array Size',
            'description': 'Find the size of an array',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int arr[] = {1, 2, 3, 4, 5};\n    \n    // Find array size\n    \n    return 0;\n}',
            'hint': 'Use sizeof(array) / sizeof(array[0]) to get array size',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int arr[] = {1, 2, 3, 4, 5};\n    int size = sizeof(arr) / sizeof(arr[0]);\n    \n    cout << "Array size: " << size << endl;\n    \n    return 0;\n}',
            'testCases': ['Array size: 5']
          },
        ];
        break;

      case 'C++ Functions':
        _exercises = [
          {
            'title': 'Basic Functions',
            'description': 'Create and call basic functions',
            'starterCode': '#include <iostream>\nusing namespace std;\n\n// Function declaration\n\nint main() {\n    // Call functions\n    \n    return 0;\n}\n\n// Function definition',
            'hint': 'Create functions for addition and greeting',
            'solution': '#include <iostream>\nusing namespace std;\n\n// Function declaration\nvoid greet();\nint add(int a, int b);\n\nint main() {\n    greet();\n    int sum = add(5, 3);\n    cout << "Sum: " << sum << endl;\n    return 0;\n}\n\n// Function definitions\nvoid greet() {\n    cout << "Hello from function!" << endl;\n}\n\nint add(int a, int b) {\n    return a + b;\n}',
            'testCases': ['Hello from function!', 'Sum: 8']
          },
          {
            'title': 'Function Parameters',
            'description': 'Use functions with different parameters',
            'starterCode': '#include <iostream>\nusing namespace std;\n\n// Create functions\n\nint main() {\n    // Use functions\n    \n    return 0;\n}',
            'hint': 'Create functions that take different data types as parameters',
            'solution': '#include <iostream>\nusing namespace std;\n\ndouble multiply(double a, double b) {\n    return a * b;\n}\n\nvoid printMessage(string message, int times) {\n    for (int i = 0; i < times; i++) {\n        cout << message << endl;\n    }\n}\n\nint main() {\n    double product = multiply(2.5, 4.0);\n    cout << "Product: " << product << endl;\n    printMessage("Hello", 2);\n    return 0;\n}',
            'testCases': ['Product: 10', 'Hello', 'Hello']
          },
          {
            'title': 'Recursive Function',
            'description': 'Create a recursive function',
            'starterCode': '#include <iostream>\nusing namespace std;\n\n// Create recursive function\n\nint main() {\n    // Call recursive function\n    \n    return 0;\n}',
            'hint': 'Create factorial function that calls itself',
            'solution': '#include <iostream>\nusing namespace std;\n\nint factorial(int n) {\n    if (n == 0 || n == 1) {\n        return 1;\n    }\n    return n * factorial(n - 1);\n}\n\nint main() {\n    int fact = factorial(5);\n    cout << "Factorial of 5: " << fact << endl;\n    return 0;\n}',
            'testCases': ['Factorial of 5: 120']
          },
        ];
        break;

      case 'C++ Classes/Objects':
        _exercises = [
          {
            'title': 'Basic Class',
            'description': 'Create a simple class with attributes and methods',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\n// Create class\n\nint main() {\n    // Create objects\n    \n    return 0;\n}',
            'hint': 'Create a Car class with brand, model, year and display method',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nclass Car {\npublic:\n    string brand;\n    string model;\n    int year;\n    \n    void displayInfo() {\n        cout << brand << " " << model << " " << year << endl;\n    }\n};\n\nint main() {\n    Car car1;\n    car1.brand = "Toyota";\n    car1.model = "Corolla";\n    car1.year = 2020;\n    car1.displayInfo();\n    \n    return 0;\n}',
            'testCases': ['Toyota Corolla 2020']
          },
          {
            'title': 'Constructor',
            'description': 'Use constructor to initialize objects',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\n// Create class with constructor\n\nint main() {\n    // Create objects using constructor\n    \n    return 0;\n}',
            'hint': 'Add constructor to Car class',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nclass Car {\npublic:\n    string brand;\n    string model;\n    int year;\n    \n    Car(string b, string m, int y) {\n        brand = b;\n        model = m;\n        year = y;\n    }\n    \n    void displayInfo() {\n        cout << brand << " " << model << " " << year << endl;\n    }\n};\n\nint main() {\n    Car car1("Honda", "Civic", 2022);\n    car1.displayInfo();\n    \n    return 0;\n}',
            'testCases': ['Honda Civic 2022']
          },
          {
            'title': 'Setter Method',
            'description': 'Use setter method to modify object attributes',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\n// Create class with setter\n\nint main() {\n    // Use setter method\n    \n    return 0;\n}',
            'hint': 'Add setYear method to Car class',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nclass Car {\npublic:\n    string brand;\n    string model;\n    int year;\n    \n    Car(string b, string m, int y) {\n        brand = b;\n        model = m;\n        year = y;\n    }\n    \n    void setYear(int newYear) {\n        year = newYear;\n    }\n    \n    void displayInfo() {\n        cout << brand << " " << model << " " << year << endl;\n    }\n};\n\nint main() {\n    Car car1("Toyota", "Corolla", 2020);\n    car1.setYear(2021);\n    car1.displayInfo();\n    \n    return 0;\n}',
            'testCases': ['Toyota Corolla 2021']
          },
        ];
        break;

      case 'C++ Exceptions':
        _exercises = [
          {
            'title': 'Basic Exception Handling',
            'description': 'Use try-catch blocks to handle exceptions',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Use try-catch for exception handling\n    \n    return 0;\n}',
            'hint': 'Use try, catch, and throw keywords',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    try {\n        int age = 15;\n        if (age < 18) {\n            throw "Age must be 18 or older";\n        }\n        cout << "Access granted" << endl;\n    }\n    catch (const char* msg) {\n        cout << "Error: " << msg << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['Error: Age must be 18 or older']
          },
          {
            'title': 'Multiple Catch Blocks',
            'description': 'Handle different types of exceptions',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Handle different exception types\n    \n    return 0;\n}',
            'hint': 'Use multiple catch blocks for different data types',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    try {\n        int choice;\n        cout << "Enter 1 for int error, 2 for string error: ";\n        cin >> choice;\n        \n        if (choice == 1) {\n            throw 404;\n        } else if (choice == 2) {\n            throw string("Not found");\n        } else {\n            throw \'X\';\n        }\n    }\n    catch (int errorCode) {\n        cout << "Integer error: " << errorCode << endl;\n    }\n    catch (string errorMsg) {\n        cout << "String error: " << errorMsg << endl;\n    }\n    catch (...) {\n        cout << "Unknown error occurred" << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['Integer error:', 'String error:', 'Unknown error occurred']
          },
          {
            'title': 'Division with Exception',
            'description': 'Handle division by zero exception',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int numerator = 10, denominator = 0;\n    // Handle division by zero\n    \n    return 0;\n}',
            'hint': 'Check denominator before division and throw exception if zero',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int numerator = 10, denominator = 0;\n    \n    try {\n        if (denominator == 0) {\n            throw runtime_error("Division by zero!");\n        }\n        int result = numerator / denominator;\n        cout << "Result: " << result << endl;\n    }\n    catch (const runtime_error& e) {\n        cout << "Runtime error: " << e.what() << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['Runtime error: Division by zero!']
          },
        ];
        break;

      case 'C++ Files':
        _exercises = [
          {
            'title': 'Write to File',
            'description': 'Create and write data to a text file',
            'starterCode': '#include <iostream>\n#include <fstream>\nusing namespace std;\n\nint main() {\n    // Write data to a file\n    \n    return 0;\n}',
            'hint': 'Use ofstream to create and write to file',
            'solution': '#include <iostream>\n#include <fstream>\nusing namespace std;\n\nint main() {\n    ofstream myfile("example.txt");\n    \n    if (myfile.is_open()) {\n        myfile << "Hello, this is line 1.\\n";\n        myfile << "This is line 2.\\n";\n        myfile << "Line 3 here.\\n";\n        myfile.close();\n        cout << "File written successfully!" << endl;\n    } else {\n        cout << "Unable to open file" << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['File written successfully!']
          },
          {
            'title': 'Read from File',
            'description': 'Read and display content from a text file',
            'starterCode': '#include <iostream>\n#include <fstream>\n#include <string>\nusing namespace std;\n\nint main() {\n    // Read data from file\n    \n    return 0;\n}',
            'hint': 'Use ifstream to read from file and getline() for each line',
            'solution': '#include <iostream>\n#include <fstream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string line;\n    ifstream myfile("example.txt");\n    \n    if (myfile.is_open()) {\n        cout << "File content:" << endl;\n        while (getline(myfile, line)) {\n            cout << line << endl;\n        }\n        myfile.close();\n    } else {\n        cout << "Unable to open file" << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['File content:', 'Hello, this is line 1.']
          },
          {
            'title': 'File Append Mode',
            'description': 'Append data to existing file',
            'starterCode': '#include <iostream>\n#include <fstream>\nusing namespace std;\n\nint main() {\n    // Append data to file\n    \n    return 0;\n}',
            'hint': 'Use ios::app flag with ofstream to append to file',
            'solution': '#include <iostream>\n#include <fstream>\nusing namespace std;\n\nint main() {\n    ofstream myfile("example.txt", ios::app);\n    \n    if (myfile.is_open()) {\n        myfile << "This line is appended.\\n";\n        myfile << "Another appended line.\\n";\n        myfile.close();\n        cout << "Data appended successfully!" << endl;\n    } else {\n        cout << "Unable to open file" << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['Data appended successfully!']
          },
        ];
        break;

      case 'C++ Inheritance':
        _exercises = [
          {
            'title': 'Basic Inheritance',
            'description': 'Create base and derived classes',
            'starterCode': '#include <iostream>\nusing namespace std;\n\n// Create base and derived classes\n\nint main() {\n    // Test inheritance\n    \n    return 0;\n}',
            'hint': 'Create Animal base class and Dog derived class',
            'solution': '#include <iostream>\nusing namespace std;\n\nclass Animal {\npublic:\n    void eat() {\n        cout << "Animal is eating" << endl;\n    }\n    void sleep() {\n        cout << "Animal is sleeping" << endl;\n    }\n};\n\nclass Dog : public Animal {\npublic:\n    void bark() {\n        cout << "Dog is barking" << endl;\n    }\n};\n\nint main() {\n    Dog myDog;\n    myDog.eat();\n    myDog.sleep();\n    myDog.bark();\n    \n    return 0;\n}',
            'testCases': ['Animal is eating', 'Animal is sleeping', 'Dog is barking']
          },
          {
            'title': 'Constructor Inheritance',
            'description': 'Use constructors in inheritance',
            'starterCode': '#include <iostream>\nusing namespace std;\n\n// Use constructors with inheritance\n\nint main() {\n    // Test constructor inheritance\n    \n    return 0;\n}',
            'hint': 'Create Person base class and Student derived class with constructors',
            'solution': '#include <iostream>\nusing namespace std;\n\nclass Person {\nprotected:\n    string name;\n    int age;\npublic:\n    Person(string n, int a) : name(n), age(a) {\n        cout << "Person constructor called" << endl;\n    }\n    void display() {\n        cout << "Name: " << name << ", Age: " << age << endl;\n    }\n};\n\nclass Student : public Person {\nprivate:\n    string studentId;\npublic:\n    Student(string n, int a, string id) : Person(n, a), studentId(id) {\n        cout << "Student constructor called" << endl;\n    }\n    void showStudent() {\n        display();\n        cout << "Student ID: " << studentId << endl;\n    }\n};\n\nint main() {\n    Student student1("Juan", 20, "S12345");\n    student1.showStudent();\n    \n    return 0;\n}',
            'testCases': ['Person constructor called', 'Student constructor called', 'Name: Juan', 'Student ID: S12345']
          },
          {
            'title': 'Multiple Inheritance',
            'description': 'Implement multiple inheritance',
            'starterCode': '#include <iostream>\nusing namespace std;\n\n// Implement multiple inheritance\n\nint main() {\n    // Test multiple inheritance\n    \n    return 0;\n}',
            'hint': 'Create multiple base classes and inherit from them',
            'solution': '#include <iostream>\nusing namespace std;\n\nclass Printable {\npublic:\n    virtual void print() = 0; // Pure virtual function\n};\n\nclass Drawable {\npublic:\n    void draw() {\n        cout << "Drawing object" << endl;\n    }\n};\n\nclass Shape : public Printable, public Drawable {\nprivate:\n    string name;\npublic:\n    Shape(string n) : name(n) {}\n    \n    void print() override {\n        cout << "Shape: " << name << endl;\n    }\n};\n\nint main() {\n    Shape circle("Circle");\n    circle.print();\n    circle.draw();\n    \n    return 0;\n}',
            'testCases': ['Shape: Circle', 'Drawing object']
          },
        ];
        break;

      case 'C++ Pointers':
        _exercises = [
          {
            'title': 'Basic Pointers',
            'description': 'Work with basic pointers',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int var = 5;\n    \n    // Work with pointers\n    \n    return 0;\n}',
            'hint': 'Create pointer, get address, and dereference',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int var = 5;\n    int* ptr = &var;\n    \n    cout << "Variable: " << var << endl;\n    cout << "Address: " << &var << endl;\n    cout << "Pointer: " << ptr << endl;\n    cout << "Dereference: " << *ptr << endl;\n    \n    return 0;\n}',
            'testCases': ['Variable: 5', 'Dereference: 5']
          },
          {
            'title': 'Pointer Arithmetic',
            'description': 'Use pointer arithmetic with arrays',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int numbers[3] = {10, 20, 30};\n    \n    // Use pointer arithmetic\n    \n    return 0;\n}',
            'hint': 'Use pointer to traverse array',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int numbers[3] = {10, 20, 30};\n    int* numPtr = numbers;\n    \n    for (int i = 0; i < 3; i++) {\n        cout << "Element " << i << ": " << *(numPtr + i) << endl;\n    }\n    \n    return 0;\n}',
            'testCases': ['Element 0: 10', 'Element 1: 20', 'Element 2: 30']
          },
          {
            'title': 'Dynamic Memory',
            'description': 'Use dynamic memory allocation',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Use dynamic memory\n    \n    return 0;\n}',
            'hint': 'Use new and delete operators',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int* dynamicPtr = new int;\n    *dynamicPtr = 100;\n    \n    cout << "Dynamic value: " << *dynamicPtr << endl;\n    \n    delete dynamicPtr;\n    \n    return 0;\n}',
            'testCases': ['Dynamic value: 100']
          },
        ];
        break;

    }
  }
  void _runCode() {
    setState(() {
      _isRunning = true;
      _output = '🚀 Compiling your code...\n\n';
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isRunning = false;

        List<String> errors = _checkForErrors(_codeController.text);

        if (errors.isEmpty) {
          _output += '✅ Compilation successful!\n';
          _output += '✅ No errors found\n';
          _output += '✅ Executing program...\n\n';

          String userOutput = _simulateProgramExecution(_codeController.text);
          _output += userOutput;

          // Check if output matches expected test cases
          _checkSolution(userOutput);
        } else {
          _output += '❌ Compilation failed!\n';
          _output += '❌ ${errors.length} error(s) found:\n\n';

          for (String error in errors) {
            _output += '• $error\n';
          }

          _output += '\n💡 Hint: ${_exercises[_currentExercise]['hint']}';
        }
      });
    });
  }

  void _checkSolution(String userOutput) {
    List<String> testCases = List<String>.from(_exercises[_currentExercise]['testCases'] ?? []);
    bool allTestsPassed = true;
    List<String> failedTests = [];
  }

  List<String> _checkForErrors(String code) {
    List<String> errors = [];

    if (!code.contains('#include <iostream>')) {
      errors.add('Missing #include <iostream>');
    }

    if (!code.contains('using namespace std;')) {
      errors.add('Missing "using namespace std;"');
    }

    if (!code.contains('int main()')) {
      errors.add('Missing main function: int main()');
    }

    if (!code.contains('{') || !code.contains('}')) {
      errors.add('Missing curly braces {} in main function');
    }

    List<String> lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      if (line.contains('cout') && line.contains('<<') && !line.endsWith(';') && !line.contains('{') && !line.contains('}')) {
        errors.add('Missing semicolon (;) at line ${i + 1}');
      }

      if (line.contains('cin') && line.contains('>>') && !line.endsWith(';') && !line.contains('{') && !line.contains('}')) {
        errors.add('Missing semicolon (;) at line ${i + 1}');
      }

      if (_countOccurrences(line, '"') % 2 != 0) {
        errors.add('Unclosed quotation marks (") at line ${i + 1}');
      }

      if ((line.contains('int ') || line.contains('string ') || line.contains('double ')) &&
          !line.endsWith(';') && !line.contains('(') && !line.contains(')')) {
        errors.add('Missing semicolon (;) in variable declaration at line ${i + 1}');
      }
    }

    if (!code.contains('return 0;') && !code.contains('return 0')) {
      errors.add('Missing return statement in main function');
    }

    return errors;
  }

  String _simulateProgramExecution(String code) {
    Map<String, dynamic> variables = {};
    List<String> outputLines = [];

    String cleanCode = code.replaceAll(RegExp(r'//.*'), '');
    cleanCode = cleanCode.replaceAll(RegExp(r'/\*.*?\*/', multiLine: true), '');

    List<String> lines = cleanCode.split('\n');

    for (String line in lines) {
      line = line.trim();

      // Variable declaration and assignment
      if (line.contains('int ') && line.contains('=')) {
        RegExp intRegex = RegExp(r'int\s+(\w+)\s*=\s*(\d+)');
        Match? match = intRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = int.parse(match.group(2)!);
        }
      }
      else if (line.contains('double ') && line.contains('=')) {
        RegExp doubleRegex = RegExp(r'double\s+(\w+)\s*=\s*([0-9.]+)');
        Match? match = doubleRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = double.parse(match.group(2)!);
        }
      }
      else if (line.contains('string ') && line.contains('=')) {
        RegExp stringRegex = RegExp(r'string\s+(\w+)\s*=\s*"([^"]*)"');
        Match? match = stringRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = match.group(2)!;
        }
      }
      else if (line.contains('char ') && line.contains('=')) {
        RegExp charRegex = RegExp(r"char\s+(\w+)\s*=\s*'([^'])'");
        Match? match = charRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = match.group(2)!;
        }
      }
      else if (line.contains('bool ') && line.contains('=')) {
        RegExp boolRegex = RegExp(r'bool\s+(\w+)\s*=\s*(true|false)');
        Match? match = boolRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = match.group(2)! == 'true';
        }
      }

      // Output statements
      if (line.contains('cout') && line.contains('<<')) {
        String output = _processCoutStatement(line, variables);
        if (output.isNotEmpty) {
          outputLines.add(output);
        }
      }

      // Input simulation
      if (line.contains('cin')) {
        _processCinStatement(line, variables);
      }

      // Arithmetic operations
      if (line.contains('=') && !line.contains('cout') && !line.contains('cin')) {
        _processArithmetic(line, variables);
      }

      // Control structures simulation
      if (line.contains('if') || line.contains('for') || line.contains('while')) {
        _processControlStructures(line, variables, outputLines);
      }
    }

    return outputLines.join('\n');
  }

  String _processCoutStatement(String line, Map<String, dynamic> variables) {
    String output = '';

    String content = line.substring(line.indexOf('<<') + 2);
    content = content.replaceAll(';', '').trim();

    List<String> parts = content.split('<<');

    for (String part in parts) {
      part = part.trim();

      if (part.contains('"')) {
        RegExp quoteRegex = RegExp(r'"([^"]*)"');
        Match? match = quoteRegex.firstMatch(part);
        if (match != null) {
          output += match.group(1)!;
        }
      }

      else if (variables.containsKey(part)) {
        dynamic value = variables[part];
        if (value is bool) {
          output += value ? '1' : '0';
        } else {
          output += value.toString();
        }
      }

      else if (part.contains('+') || part.contains('-') || part.contains('*') || part.contains('/')) {
        output += _evaluateExpression(part, variables).toString();
      }

      else if (part.contains('.length()')) {
        String varName = part.replaceAll('.length()', '');
        if (variables.containsKey(varName) && variables[varName] is String) {
          output += (variables[varName] as String).length.toString();
        }
      }

      else if (part == 'endl' || part == '\\n') {
        output += '\n';
      }
    }

    return output;
  }

  void _processCinStatement(String line, Map<String, dynamic> variables) {
    RegExp cinRegex = RegExp(r'cin\s*>>\s*(\w+)');
    Match? match = cinRegex.firstMatch(line);

    if (match != null) {
      String varName = match.group(1)!;

      if (varName.contains('name')) {
        variables[varName] = 'John';
      } else if (varName.contains('age')) {
        variables[varName] = 25;
      } else if (varName.contains('num')) {
        variables[varName] = 10;
      } else {
        variables[varName] = 'user_input';
      }
    }
  }

  void _processArithmetic(String line, Map<String, dynamic> variables) {
    RegExp assignRegex = RegExp(r'(\w+)\s*=\s*(.+)');
    Match? match = assignRegex.firstMatch(line);

    if (match != null) {
      String varName = match.group(1)!;
      String expression = match.group(2)!;

      expression = expression.replaceAll(';', '').trim();

      dynamic result = _evaluateExpression(expression, variables);
      variables[varName] = result;
    }
  }

  void _processControlStructures(String line, Map<String, dynamic> variables, List<String> outputLines) {
    // Simple simulation of control structures
    if (line.contains('if') && line.contains('>')) {
      RegExp ifRegex = RegExp(r'if\s*\(\s*(\w+)\s*>\s*(\d+)\s*\)');
      Match? match = ifRegex.firstMatch(line);
      if (match != null) {
        String varName = match.group(1)!;
        int value = int.parse(match.group(2)!);
        if (variables.containsKey(varName) && variables[varName] > value) {
          // Condition is true
        }
      }
    }

    if (line.contains('for') && line.contains('int i=')) {
      // Simple for loop simulation
      for (int i = 1; i <= 5; i++) {
        variables['i'] = i;
        // This will be handled by the cout statements inside the loop
      }
    }

    if (line.contains('while') && line.contains('count')) {
      // Simple while loop simulation
      int count = variables['count'] ?? 1;
      while (count <= 3) {
        variables['count'] = count;
        count++;
      }
    }
  }

  dynamic _evaluateExpression(String expression, Map<String, dynamic> variables) {
    expression = expression.trim();

    if (expression.contains('+')) {
      List<String> parts = expression.split('+');
      dynamic left = _getValue(parts[0].trim(), variables);
      dynamic right = _getValue(parts[1].trim(), variables);
      return left + right;
    }
    else if (expression.contains('-')) {
      List<String> parts = expression.split('-');
      dynamic left = _getValue(parts[0].trim(), variables);
      dynamic right = _getValue(parts[1].trim(), variables);
      return left - right;
    }
    else if (expression.contains('*')) {
      List<String> parts = expression.split('*');
      dynamic left = _getValue(parts[0].trim(), variables);
      dynamic right = _getValue(parts[1].trim(), variables);
      return left * right;
    }
    else if (expression.contains('/')) {
      List<String> parts = expression.split('/');
      dynamic left = _getValue(parts[0].trim(), variables);
      dynamic right = _getValue(parts[1].trim(), variables);
      return left ~/ right;
    }
    else if (expression.contains('%')) {
      List<String> parts = expression.split('%');
      dynamic left = _getValue(parts[0].trim(), variables);
      dynamic right = _getValue(parts[1].trim(), variables);
      return left % right;
    }

    return _getValue(expression, variables);
  }

  dynamic _getValue(String token, Map<String, dynamic> variables) {
    if (variables.containsKey(token)) {
      return variables[token];
    }

    if (RegExp(r'^\d+$').hasMatch(token)) {
      return int.parse(token);
    }
    if (RegExp(r'^\d+\.\d+$').hasMatch(token)) {
      return double.parse(token);
    }

    if (token.startsWith('"') && token.endsWith('"')) {
      return token.substring(1, token.length - 1);
    }

    return token;
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
                language: 'cpp',
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
          content: Text('🎉 Congratulations! You completed all exercises!'),
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
          'Java IDE - ${widget.moduleTitle}',
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
                        '📝 Java Code Editor',
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
                                      language: 'java',
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
                        _output.isEmpty ? '🚀 Click "Run Code" to execute your Java program...' : _output,
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
                        '📝 Java Code Editor',
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
                                      language: 'java',
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
                        _output.isEmpty ? '🚀 Click "Run Code" to execute your Java program...' : _output,
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

// DAGDAG MO ITO SA STATE CLASS
  double _calculateEditorHeight() {
    int lineCount = _codeLines.length;
    double baseHeight = 40.0; // Minimum height
    double lineHeight = 20.0; // Height per line

    // Calculate height based on number of lines
    double calculatedHeight = baseHeight + (lineCount * lineHeight);

    // Set maximum height to 70% of screen height
    double maxHeight = MediaQuery.of(context).size.height * 0.7;

    return calculatedHeight.clamp(200.0, maxHeight); // Min 200, max 70% of screen
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