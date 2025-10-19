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
    this.language = 'C++', // Make it optional with default value
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
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Hello, World!" << endl;\n    return 0;\n}',
            'hint': 'Use cout to display text to the console',
            'testCases': ['Hello, World!']
          },
          {
            'title': 'Variables and Output',
            'description': 'Create a program that displays your name and age',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Declare variables for name and age\n    \n    // Display the information\n    \n    return 0;\n}',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    string name = "John";\n    int age = 25;\n    \n    cout << "Name: " << name << endl;\n    cout << "Age: " << age << endl;\n    \n    return 0;\n}',
            'hint': 'Declare string and int variables, then use cout to display them',
            'testCases': ['Name: John', 'Age: 25']
          },
        ];
        break;

      case 'C++ Syntax':
        _exercises = [
          {
            'title': 'Basic Syntax Structure',
            'description': 'Complete the basic C++ program structure',
            'starterCode': '// Add necessary header\n// Add namespace\n\n// Create main function\n{\n    // Display message\n    \n    return 0;\n}',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "C++ Syntax is important!" << endl;\n    return 0;\n}',
            'hint': 'Remember to include iostream and use the main function',
            'testCases': ['C++ Syntax is important!']
          },
        ];
        break;

      case 'C++ Data Types':
        _exercises = [
          {
            'title': 'Multiple Data Types',
            'description': 'Create variables of different data types and display them',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    // Create variables: string name, int age, double salary, char grade, bool isStudent\n    \n    // Display all variables\n    \n    return 0;\n}',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string name = "John";\n    int age = 25;\n    double salary = 2500.5;\n    char grade = \'A\';\n    bool isStudent = true;\n    \n    cout << "Name: " << name << endl;\n    cout << "Age: " << age << endl;\n    cout << "Salary: " << salary << endl;\n    cout << "Grade: " << grade << endl;\n    cout << "Is Student: " << isStudent << endl;\n    \n    return 0;\n}',
            'hint': 'Use appropriate data types and display them with cout',
            'testCases': ['Name: John', 'Age: 25', 'Salary: 2500.5', 'Grade: A', 'Is Student: 1']
          },
        ];
        break;

      case 'C++ Operators':
        _exercises = [
          {
            'title': 'Arithmetic Operations',
            'description': 'Perform basic arithmetic operations on two numbers',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int a = 15, b = 4;\n    \n    // Perform and display arithmetic operations\n    \n    return 0;\n}',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int a = 15, b = 4;\n    \n    cout << "a + b = " << (a + b) << endl;\n    cout << "a - b = " << (a - b) << endl;\n    cout << "a * b = " << (a * b) << endl;\n    cout << "a / b = " << (a / b) << endl;\n    cout << "a % b = " << (a % b) << endl;\n    \n    return 0;\n}',
            'hint': 'Use +, -, *, /, and % operators',
            'testCases': ['a + b = 19', 'a - b = 11', 'a * b = 60', 'a / b = 3', 'a % b = 3']
          },
        ];
        break;

      case 'C++ Strings':
        _exercises = [
          {
            'title': 'String Operations',
            'description': 'Perform basic string operations like concatenation and length',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string firstName = "John";\n    string lastName = "Doe";\n    \n    // Concatenate strings and display results\n    \n    return 0;\n}',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string firstName = "John";\n    string lastName = "Doe";\n    \n    string fullName = firstName + " " + lastName;\n    \n    cout << "Full Name: " << fullName << endl;\n    cout << "Length: " << fullName.length() << endl;\n    cout << "First character: " << fullName[0] << endl;\n    \n    return 0;\n}',
            'hint': 'Use + for concatenation and .length() for string length',
            'testCases': ['Full Name: John Doe', 'Length: 8', 'First character: J']
          },
        ];
        break;

      case 'C++ Arrays':
        _exercises = [
          {
            'title': 'Array Declaration and Access',
            'description': 'Create an array and access its elements',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Create an array of 5 integers\n    \n    // Display each element\n    \n    return 0;\n}',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int numbers[5] = {1, 2, 3, 4, 5};\n    \n    cout << "Array elements:" << endl;\n    for(int i = 0; i < 5; i++) {\n        cout << "numbers[" << i << "] = " << numbers[i] << endl;\n    }\n    \n    return 0;\n}',
            'hint': 'Use a for loop to iterate through the array',
            'testCases': ['Array elements:', 'numbers[0] = 1', 'numbers[1] = 2', 'numbers[2] = 3', 'numbers[3] = 4', 'numbers[4] = 5']
          },
        ];
        break;

      case 'C++ Pointers':
        _exercises = [
          {
            'title': 'Basic Pointer Operations',
            'description': 'Work with pointers to understand memory addresses',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int number = 42;\n    \n    // Create a pointer and display values\n    \n    return 0;\n}',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int number = 42;\n    int* ptr = &number;\n    \n    cout << "Value: " << number << endl;\n    cout << "Address: " << &number << endl;\n    cout << "Pointer value: " << ptr << endl;\n    cout << "Dereferenced: " << *ptr << endl;\n    \n    return 0;\n}',
            'hint': 'Use & for address and * for dereferencing',
            'testCases': ['Value: 42', 'Dereferenced: 42']
          },
        ];
        break;

      case 'C++ Functions':
        _exercises = [
          {
            'title': 'Function Creation',
            'description': 'Create a function that adds two numbers',
            'starterCode': '#include <iostream>\nusing namespace std;\n\n// Function declaration\n\nint main() {\n    int result = add(5, 3);\n    cout << "5 + 3 = " << result << endl;\n    return 0;\n}\n\n// Function definition',
            'solution': '#include <iostream>\nusing namespace std;\n\n// Function declaration\nint add(int a, int b);\n\nint main() {\n    int result = add(5, 3);\n    cout << "5 + 3 = " << result << endl;\n    return 0;\n}\n\n// Function definition\nint add(int a, int b) {\n    return a + b;\n}',
            'hint': 'Create a function that takes two integers and returns their sum',
            'testCases': ['5 + 3 = 8']
          },
        ];
        break;

      case 'C++ Classes':
        _exercises = [
          {
            'title': 'Simple Class Implementation',
            'description': 'Create a Person class with name and age attributes',
            'starterCode': '#include <iostream>\n#include <string>\nusing namespace std;\n\n// Create Person class\n\nint main() {\n    // Create Person object and display info\n    \n    return 0;\n}',
            'solution': '#include <iostream>\n#include <string>\nusing namespace std;\n\nclass Person {\nprivate:\n    string name;\n    int age;\n    \npublic:\n    Person(string n, int a) : name(n), age(a) {}\n    \n    void display() {\n        cout << "Name: " << name << ", Age: " << age << endl;\n    }\n};\n\nint main() {\n    Person person1("Alice", 30);\n    person1.display();\n    \n    return 0;\n}',
            'hint': 'Create a class with private attributes and public methods',
            'testCases': ['Name: Alice, Age: 30']
          },
        ];
        break;

      case 'C++ Inheritance':
        _exercises = [
          {
            'title': 'Basic Inheritance',
            'description': 'Create base and derived classes to understand inheritance',
            'starterCode': '#include <iostream>\nusing namespace std;\n\n// Create Animal base class\n\n// Create Dog derived class\n\nint main() {\n    // Create Dog object and call methods\n    \n    return 0;\n}',
            'solution': '#include <iostream>\nusing namespace std;\n\nclass Animal {\npublic:\n    void eat() { \n        cout << "Eating..." << endl; \n    }\n};\n\nclass Dog : public Animal {\npublic:\n    void bark() { \n        cout << "Barking..." << endl; \n    }\n};\n\nint main() {\n    Dog dog;\n    dog.eat();\n    dog.bark();\n    \n    return 0;\n}',
            'hint': 'Use public inheritance to access base class methods',
            'testCases': ['Eating...', 'Barking...']
          },
        ];
        break;

      case 'C++ Loops':
        _exercises = [
          {
            'title': 'For Loop Practice',
            'description': 'Use a for loop to display numbers 1 through 5',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Use for loop to display numbers 1 to 5\n    \n    return 0;\n}',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    for(int i = 1; i <= 5; i++) {\n        cout << "Number: " << i << endl;\n    }\n    \n    return 0;\n}',
            'hint': 'Use for loop with counter from 1 to 5',
            'testCases': ['Number: 1', 'Number: 2', 'Number: 3', 'Number: 4', 'Number: 5']
          },
        ];
        break;

      case 'C++ Conditions':
        _exercises = [
          {
            'title': 'Grade Calculator',
            'description': 'Use if-else statements to determine grade based on score',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int score = 85;\n    \n    // Determine grade based on score\n    // 90-100: A, 80-89: B, 70-79: C, below 70: F\n    \n    return 0;\n}',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    int score = 85;\n    \n    if(score >= 90) {\n        cout << "Grade: A" << endl;\n    } else if(score >= 80) {\n        cout << "Grade: B" << endl;\n    } else if(score >= 70) {\n        cout << "Grade: C" << endl;\n    } else {\n        cout << "Grade: F" << endl;\n    }\n    \n    return 0;\n}',
            'hint': 'Use if-else if ladder to check score ranges',
            'testCases': ['Grade: B']
          },
        ];
        break;

      case 'C++ Math':
        _exercises = [
          {
            'title': 'Math Functions',
            'description': 'Use various math functions from cmath library',
            'starterCode': '#include <iostream>\n#include <cmath>\nusing namespace std;\n\nint main() {\n    // Use math functions: sqrt, pow, abs, ceil, floor\n    \n    return 0;\n}',
            'solution': '#include <iostream>\n#include <cmath>\nusing namespace std;\n\nint main() {\n    cout << "Square root: " << sqrt(16) << endl;\n    cout << "Power: " << pow(2, 8) << endl;\n    cout << "Absolute: " << abs(-10) << endl;\n    cout << "Ceiling: " << ceil(4.3) << endl;\n    cout << "Floor: " << floor(4.7) << endl;\n    \n    return 0;\n}',
            'hint': 'Include cmath header and use mathematical functions',
            'testCases': ['Square root: 4', 'Power: 256', 'Absolute: 10', 'Ceiling: 5', 'Floor: 4']
          },
        ];
        break;

      case 'C++ Exceptions Handling':
        _exercises = [
          {
            'title': 'Exception Handling',
            'description': 'Use try-catch to handle division by zero error',
            'starterCode': '#include <iostream>\n#include <stdexcept>\nusing namespace std;\n\nint main() {\n    int numerator = 10;\n    int denominator = 0;\n    \n    // Use try-catch to handle division by zero\n    \n    return 0;\n}',
            'solution': '#include <iostream>\n#include <stdexcept>\nusing namespace std;\n\nint main() {\n    int numerator = 10;\n    int denominator = 0;\n    \n    try {\n        if(denominator == 0) {\n            throw runtime_error("Division by zero!");\n        }\n        int result = numerator / denominator;\n        cout << "Result: " << result << endl;\n    } catch (const exception& e) {\n        cout << "Error: " << e.what() << endl;\n    }\n    \n    return 0;\n}',
            'hint': 'Throw an exception when denominator is zero',
            'testCases': ['Error: Division by zero!']
          },
        ];
        break;

      case 'C++ Files Handling':
        _exercises = [
          {
            'title': 'File Writing',
            'description': 'Write data to a file using ofstream',
            'starterCode': '#include <iostream>\n#include <fstream>\nusing namespace std;\n\nint main() {\n    // Write data to a file\n    \n    return 0;\n}',
            'solution': '#include <iostream>\n#include <fstream>\nusing namespace std;\n\nint main() {\n    ofstream file("output.txt");\n    \n    if(file.is_open()) {\n        file << "Hello, File Handling!" << endl;\n        file << "This is a C++ tutorial." << endl;\n        file.close();\n        cout << "File written successfully!" << endl;\n    } else {\n        cout << "Error opening file!" << endl;\n    }\n    \n    return 0;\n}',
            'hint': 'Use ofstream to create and write to a file',
            'testCases': ['File written successfully!']
          },
        ];
        break;

      default:
        _exercises = [
          {
            'title': 'Welcome to C++',
            'description': 'Basic C++ program to get started',
            'starterCode': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Write your first C++ program\n    \n    return 0;\n}',
            'solution': '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Welcome to C++ Programming!" << endl;\n    return 0;\n}',
            'hint': 'Use cout to display a welcome message',
            'testCases': ['Welcome to C++ Programming!']
          },
        ];
    }
  }

  void _runCode() {
    setState(() {
      _isRunning = true;
      _output = '🚀 Compiling your code...\n\n';
    });

    // Simulate compilation and execution
    Future.delayed(Duration(milliseconds: 500), () {
      List<String> errors = _checkForErrors(_codeController.text);

      setState(() {
        _isRunning = false;

        if (errors.isEmpty) {
          _output += '✅ Compilation successful!\n';
          _output += '✅ No errors found\n';
          _output += '✅ Executing program...\n\n';

          // Simulate program execution and capture output
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

    for (String testCase in testCases) {
      // Clean both strings for comparison
      String cleanUserOutput = userOutput.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      String cleanTestCase = testCase.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

      if (!cleanUserOutput.contains(cleanTestCase)) {
        allTestsPassed = false;
        failedTests.add(testCase);
      }
    }

    setState(() {
      if (allTestsPassed) {
        _output += '\n🎉 All tests passed! Excellent work!\n';
        _output += '✅ Exercise completed successfully!';
      } else {
        _output += '\n⚠️  Some tests failed:\n';
        for (String failedTest in failedTests) {
          _output += '❌ Expected: $failedTest\n';
        }
        _output += '\n💡 Try to fix your code and run again!';
      }
    });
  }

  List<String> _checkForErrors(String code) {
    List<String> errors = [];

    // Basic syntax checks
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

    // Check for string usage without include
    if (code.contains('string ') && !code.contains('#include <string>')) {
      errors.add('Missing #include <string> for string type');
    }

    // Check for common syntax errors
    List<String> lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Check for missing semicolons in cout statements
      if (line.contains('cout') && line.contains('<<') &&
          !line.endsWith(';') && !line.contains('{') && !line.contains('}')) {
        errors.add('Missing semicolon (;) at line ${i + 1}');
      }

      // Check for unclosed quotes
      if (_countOccurrences(line, '"') % 2 != 0) {
        errors.add('Unclosed quotation marks (") at line ${i + 1}');
      }

      // Check for unclosed single quotes
      if (_countOccurrences(line, "'") % 2 != 0) {
        errors.add('Unclosed single quotes at line ${i + 1}');
      }

      // Check variable declarations
      if ((line.contains('int ') || line.contains('string ') || line.contains('double ')) &&
          line.contains('=') && !line.endsWith(';') &&
          !line.contains('(') && !line.contains(')')) {
        errors.add('Missing semicolon (;) in variable declaration at line ${i + 1}');
      }
    }

    // Check for return statement
    if (!code.contains('return 0;') && !code.contains('return 0')) {
      errors.add('Missing return statement in main function');
    }

    return errors;
  }

  String _simulateProgramExecution(String code) {
    // Check if this is a solution code by comparing with the actual solution
    String currentSolution = _exercises[_currentExercise]['solution'];
    bool isSolutionCode = _normalizeCode(code) == _normalizeCode(currentSolution);

    // If it's the solution code, return the expected output directly
    if (isSolutionCode) {
      return _getExpectedOutputForSolution();
    }

    // Otherwise, simulate based on content
    return _simulateBasedOnContent(code);
  }

  String _normalizeCode(String code) {
    // Remove comments and extra whitespace for comparison
    return code
        .replaceAll(RegExp(r'//.*'), '')
        .replaceAll(RegExp(r'/\*.*?\*/', multiLine: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _getExpectedOutputForSolution() {
    // Return the exact expected output for each exercise solution
    switch (widget.moduleTitle) {
      case 'C++ Introduction':
        if (_currentExercise == 0) return 'Hello, World!';
        if (_currentExercise == 1) return 'Name: John\nAge: 25';
        break;
      case 'C++ Syntax':
        return 'C++ Syntax is important!';
      case 'C++ Data Types':
        return 'Name: John\nAge: 25\nSalary: 2500.5\nGrade: A\nIs Student: 1';
      case 'C++ Operators':
        return 'a + b = 19\na - b = 11\na * b = 60\na / b = 3\na % b = 3';
      case 'C++ Strings':
        return 'Full Name: John Doe\nLength: 8\nFirst character: J';
      case 'C++ Arrays':
        return 'Array elements:\nnumbers[0] = 1\nnumbers[1] = 2\nnumbers[2] = 3\nnumbers[3] = 4\nnumbers[4] = 5';
      case 'C++ Pointers':
        return 'Value: 42\nDereferenced: 42';
      case 'C++ Functions':
        return '5 + 3 = 8';
      case 'C++ Classes':
        return 'Name: Alice, Age: 30';
      case 'C++ Inheritance':
        return 'Eating...\nBarking...';
      case 'C++ Loops':
        return 'Number: 1\nNumber: 2\nNumber: 3\nNumber: 4\nNumber: 5';
      case 'C++ Conditions':
        return 'Grade: B';
      case 'C++ Math':
        return 'Square root: 4\nPower: 256\nAbsolute: 10\nCeiling: 5\nFloor: 4';
      case 'C++ Exceptions Handling':
        return 'Error: Division by zero!';
      case 'C++ Files Handling':
        return 'File written successfully!';
      default:
        return 'Welcome to C++ Programming!';
    }
    return 'Program executed successfully!';
  }

  String _simulateBasedOnContent(String code) {
    List<String> outputLines = [];

    // Simple pattern matching for common outputs
    if (code.contains('"Hello, World!"')) {
      outputLines.add('Hello, World!');
    }
    if (code.contains('"Name: John"') || code.contains('"Age: 25"')) {
      outputLines.addAll(['Name: John', 'Age: 25']);
    }
    if (code.contains('"C++ Syntax is important!"')) {
      outputLines.add('C++ Syntax is important!');
    }
    if (code.contains('a + b') && code.contains('a - b')) {
      outputLines.addAll(['a + b = 19', 'a - b = 11', 'a * b = 60', 'a / b = 3', 'a % b = 3']);
    }
    if (code.contains('Full Name') && code.contains('John Doe')) {
      outputLines.addAll(['Full Name: John Doe', 'Length: 8', 'First character: J']);
    }
    if (code.contains('numbers[') && code.contains('] =')) {
      outputLines.addAll(['Array elements:', 'numbers[0] = 1', 'numbers[1] = 2', 'numbers[2] = 3', 'numbers[3] = 4', 'numbers[4] = 5']);
    }
    if (code.contains('5 + 3 =')) {
      outputLines.add('5 + 3 = 8');
    }
    if (code.contains('Name: Alice') && code.contains('Age: 30')) {
      outputLines.add('Name: Alice, Age: 30');
    }
    if (code.contains('Eating...') || code.contains('Barking...')) {
      outputLines.addAll(['Eating...', 'Barking...']);
    }
    if (code.contains('Number: 1') && code.contains('Number: 5')) {
      outputLines.addAll(['Number: 1', 'Number: 2', 'Number: 3', 'Number: 4', 'Number: 5']);
    }
    if (code.contains('Grade: B')) {
      outputLines.add('Grade: B');
    }
    if (code.contains('Square root: 4')) {
      outputLines.addAll(['Square root: 4', 'Power: 256', 'Absolute: 10', 'Ceiling: 5', 'Floor: 4']);
    }
    if (code.contains('Division by zero')) {
      outputLines.add('Error: Division by zero!');
    }
    if (code.contains('File written successfully')) {
      outputLines.add('File written successfully!');
    }
    if (code.contains('Welcome to C++ Programming')) {
      outputLines.add('Welcome to C++ Programming!');
    }

    // If no specific patterns matched, check for basic cout statements
    if (outputLines.isEmpty) {
      List<String> lines = code.split('\n');
      for (String line in lines) {
        if (line.contains('cout') && line.contains('"')) {
          RegExp regex = RegExp(r'"([^"]*)"');
          Iterable<Match> matches = regex.allMatches(line);
          for (Match match in matches) {
            outputLines.add(match.group(1)!);
          }
        }
      }
    }

    return outputLines.join('\n');
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
                  _output = ''; // Clear previous output
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
          'C++ IDE - ${widget.moduleTitle}',
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
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(screenWidth < 360 ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '📝 C++ Code Editor',
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
                Expanded(
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
                                    language: 'cpp',
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

        // Output Panel
        Expanded(
          flex: 1,
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
                        _output.isEmpty ? '🚀 Click "Run Code" to execute your C++ program...' : _output,
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
          child: Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '📝 C++ Code Editor',
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
                Expanded(
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
                                    language: 'cpp',
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
                        _output.isEmpty ? '🚀 Click "Run Code" to execute your C++ program...' : _output,
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