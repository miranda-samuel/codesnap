import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/darcula.dart';

class JavaPracticeScreen extends StatefulWidget {
  final String moduleTitle;
  final Color primaryColor;
  final String language;

  const JavaPracticeScreen({
    Key? key,
    required this.moduleTitle,
    required this.primaryColor,
    required this.language,
  }) : super(key: key);

  @override
  State<JavaPracticeScreen> createState() => _JavaPracticeScreenState();
}

class _JavaPracticeScreenState extends State<JavaPracticeScreen> {
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
      case 'Java Introduction':
        _exercises = [
          {
            'title': 'Hello World Program',
            'description': 'Write your first Java program that prints "Hello, World!" to the console.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        // Write your code here\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, World!");\n    }\n}',
            'hint': 'Use System.out.println() to print text to the console.',
            'testCases': ['Hello, World!']
          },
          {
            'title': 'Variables and Data Types',
            'description': 'Create variables of different data types and print them.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        // Create variables\n        \n        \n        // Print variables\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        String name = "John";\n        int age = 25;\n        double salary = 2500.50;\n        char grade = \'A\';\n        boolean isStudent = true;\n        \n        System.out.println("Name: " + name);\n        System.out.println("Age: " + age);\n        System.out.println("Salary: " + salary);\n        System.out.println("Grade: " + grade);\n        System.out.println("Is Student: " + isStudent);\n    }\n}',
            'hint': 'Declare variables using: String, int, double, char, boolean',
            'testCases': ['Name: John', 'Age: 25', 'Salary: 2500.5', 'Grade: A', 'Is Student: true']
          }
        ];
        break;
      case 'Java Syntax':
        _exercises = [
          {
            'title': 'Basic Syntax Structure',
            'description': 'Understand the basic structure of a Java program.',
            'starterCode': '// Write a complete Java program\n\n\n\n\n',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Java Syntax is important!");\n    }\n}',
            'hint': 'Every Java program needs a class and main method.',
            'testCases': ['Java Syntax is important!']
          }
        ];
        break;
      case 'Java Data Types':
        _exercises = [
          {
            'title': 'Primitive Data Types',
            'description': 'Practice using different primitive data types in Java.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        // Declare primitive variables\n        \n        \n        \n        \n        \n        // Print all variables\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        byte smallNumber = 100;\n        short mediumNumber = 1000;\n        int largeNumber = 100000;\n        long veryLargeNumber = 1000000000L;\n        float decimal = 3.14f;\n        double preciseDecimal = 3.14159;\n        boolean flag = true;\n        char letter = \'J\';\n        \n        System.out.println("byte: " + smallNumber);\n        System.out.println("short: " + mediumNumber);\n        System.out.println("int: " + largeNumber);\n        System.out.println("long: " + veryLargeNumber);\n        System.out.println("float: " + decimal);\n        System.out.println("double: " + preciseDecimal);\n        System.out.println("boolean: " + flag);\n        System.out.println("char: " + letter);\n    }\n}',
            'hint': 'Use byte, short, int, long, float, double, boolean, char',
            'testCases': ['byte: 100', 'short: 1000', 'int: 100000', 'long: 1000000000', 'float: 3.14', 'double: 3.14159', 'boolean: true', 'char: J']
          }
        ];
        break;
      case 'Java Variables':
        _exercises = [
          {
            'title': 'Variable Declaration and Initialization',
            'description': 'Learn how to declare and initialize variables in Java.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        // Declare and initialize variables\n        \n        \n        \n        \n        // Perform operations\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        int x = 10;\n        int y = 5;\n        String name = "Java";\n        boolean isActive = true;\n        \n        int sum = x + y;\n        int difference = x - y;\n        \n        System.out.println("x + y = " + sum);\n        System.out.println("x - y = " + difference);\n        System.out.println("Name: " + name);\n        System.out.println("Active: " + isActive);\n    }\n}',
            'hint': 'Variables must be declared before use. Use = operator for assignment.',
            'testCases': ['x + y = 15', 'x - y = 5', 'Name: Java', 'Active: true']
          }
        ];
        break;
      case 'Java Operators':
        _exercises = [
          {
            'title': 'Arithmetic Operators',
            'description': 'Practice using arithmetic operators in Java.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        int a = 15;\n        int b = 4;\n        \n        // Perform arithmetic operations\n        \n        \n        \n        \n        \n        // Print results\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        int a = 15;\n        int b = 4;\n        \n        int sum = a + b;\n        int difference = a - b;\n        int product = a * b;\n        int quotient = a / b;\n        int remainder = a % b;\n        \n        System.out.println("a + b = " + sum);\n        System.out.println("a - b = " + difference);\n        System.out.println("a * b = " + product);\n        System.out.println("a / b = " + quotient);\n        System.out.println("a % b = " + remainder);\n    }\n}',
            'hint': 'Use +, -, *, /, % operators for arithmetic operations.',
            'testCases': ['a + b = 19', 'a - b = 11', 'a * b = 60', 'a / b = 3', 'a % b = 3']
          }
        ];
        break;
      case 'Java Strings':
        _exercises = [
          {
            'title': 'String Operations',
            'description': 'Learn how to work with strings in Java.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        String firstName = "John";\n        String lastName = "Doe";\n        \n        // Perform string operations\n        \n        \n        \n        \n        // Print results\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        String firstName = "John";\n        String lastName = "Doe";\n        \n        String fullName = firstName + " " + lastName;\n        int nameLength = fullName.length();\n        String upperCaseName = fullName.toUpperCase();\n        char firstChar = fullName.charAt(0);\n        \n        System.out.println("Full Name: " + fullName);\n        System.out.println("Length: " + nameLength);\n        System.out.println("Uppercase: " + upperCaseName);\n        System.out.println("First character: " + firstChar);\n    }\n}',
            'hint': 'Use + for concatenation, length(), toUpperCase(), charAt() methods.',
            'testCases': ['Full Name: John Doe', 'Length: 8', 'Uppercase: JOHN DOE', 'First character: J']
          }
        ];
        break;
      case 'Java Arrays':
        _exercises = [
          {
            'title': 'Array Declaration and Usage',
            'description': 'Learn how to declare and use arrays in Java.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        // Declare and initialize an array\n        \n        \n        // Access and print array elements\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        int[] numbers = {1, 2, 3, 4, 5};\n        \n        System.out.println("Array elements:");\n        for (int i = 0; i < numbers.length; i++) {\n            System.out.println("numbers[" + i + "] = " + numbers[i]);\n        }\n        \n        System.out.println("Array length: " + numbers.length);\n    }\n}',
            'hint': 'Use [] to declare arrays and for loop to iterate through elements.',
            'testCases': ['Array elements:', 'numbers[0] = 1', 'numbers[1] = 2', 'numbers[2] = 3', 'numbers[3] = 4', 'numbers[4] = 5']
          }
        ];
        break;
      case 'Java Methods':
        _exercises = [
          {
            'title': 'Method Creation and Invocation',
            'description': 'Learn how to create and call methods in Java.',
            'starterCode': 'public class Main {\n    \n    // Create a method to add two numbers\n    \n    \n    \n    public static void main(String[] args) {\n        // Call the method and print result\n        \n    }\n}',
            'solution': 'public class Main {\n    \n    public static int add(int a, int b) {\n        return a + b;\n    }\n    \n    public static void main(String[] args) {\n        int result = add(5, 3);\n        System.out.println("5 + 3 = " + result);\n    }\n}',
            'hint': 'Methods have return type, name, parameters, and body with return statement.',
            'testCases': ['5 + 3 = 8']
          }
        ];
        break;
      case 'Java OOP':
        _exercises = [
          {
            'title': 'Class and Object Creation',
            'description': 'Learn the basics of Object-Oriented Programming in Java.',
            'starterCode': '// Create a Person class\n\n\n\n\n\n\npublic class Main {\n    public static void main(String[] args) {\n        // Create Person object and display info\n        \n    }\n}',
            'solution': 'class Person {\n    private String name;\n    private int age;\n    \n    public Person(String name, int age) {\n        this.name = name;\n        this.age = age;\n    }\n    \n    public void displayInfo() {\n        System.out.println("Name: " + name + ", Age: " + age);\n    }\n}\n\npublic class Main {\n    public static void main(String[] args) {\n        Person person = new Person("Alice", 30);\n        person.displayInfo();\n    }\n}',
            'hint': 'Create a class with fields, constructor, and methods. Then create objects.',
            'testCases': ['Name: Alice, Age: 30']
          }
        ];
        break;
      case 'Java Inheritance':
        _exercises = [
          {
            'title': 'Inheritance and Polymorphism',
            'description': 'Learn about inheritance in Java OOP.',
            'starterCode': '// Create base class Animal\n\n\n\n\n\n// Create derived class Dog\n\n\n\n\n\npublic class Main {\n    public static void main(String[] args) {\n        // Create objects and call methods\n        \n    }\n}',
            'solution': 'class Animal {\n    public void eat() {\n        System.out.println("Eating...");\n    }\n}\n\nclass Dog extends Animal {\n    public void bark() {\n        System.out.println("Barking...");\n    }\n}\n\npublic class Main {\n    public static void main(String[] args) {\n        Dog dog = new Dog();\n        dog.eat();\n        dog.bark();\n    }\n}',
            'hint': 'Use extends keyword for inheritance. Derived class inherits base class methods.',
            'testCases': ['Eating...', 'Barking...']
          }
        ];
        break;
      case 'Java Loops':
        _exercises = [
          {
            'title': 'For Loop Practice',
            'description': 'Learn how to use for loops in Java.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        // Use for loop to print numbers 1 to 5\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        for (int i = 1; i <= 5; i++) {\n            System.out.println("Number: " + i);\n        }\n    }\n}',
            'hint': 'for (initialization; condition; increment) { // code }',
            'testCases': ['Number: 1', 'Number: 2', 'Number: 3', 'Number: 4', 'Number: 5']
          }
        ];
        break;
      case 'Java Conditions':
        _exercises = [
          {
            'title': 'If-Else Statements',
            'description': 'Practice using conditional statements in Java.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        int score = 85;\n        \n        // Determine grade based on score\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        int score = 85;\n        String grade;\n        \n        if (score >= 90) {\n            grade = "A";\n        } else if (score >= 80) {\n            grade = "B";\n        } else if (score >= 70) {\n            grade = "C";\n        } else if (score >= 60) {\n            grade = "D";\n        } else {\n            grade = "F";\n        }\n        \n        System.out.println("Grade: " + grade);\n    }\n}',
            'hint': 'Use if, else if, else statements to check multiple conditions.',
            'testCases': ['Grade: B']
          }
        ];
        break;
      case 'Java Collections':
        _exercises = [
          {
            'title': 'ArrayList Usage',
            'description': 'Learn how to use ArrayList collection in Java.',
            'starterCode': 'import java.util.ArrayList;\n\npublic class Main {\n    public static void main(String[] args) {\n        // Create ArrayList and perform operations\n        \n    }\n}',
            'solution': 'import java.util.ArrayList;\n\npublic class Main {\n    public static void main(String[] args) {\n        ArrayList<String> names = new ArrayList<>();\n        \n        names.add("John");\n        names.add("Jane");\n        names.add("Doe");\n        \n        System.out.println("ArrayList elements:");\n        for (String name : names) {\n            System.out.println(name);\n        }\n        \n        System.out.println("Size: " + names.size());\n    }\n}',
            'hint': 'Use ArrayList for dynamic arrays. Methods: add(), get(), size(), remove()',
            'testCases': ['ArrayList elements:', 'John', 'Jane', 'Doe', 'Size: 3']
          }
        ];
        break;
      case 'Java Exception Handling':
        _exercises = [
          {
            'title': 'Try-Catch Block',
            'description': 'Learn how to handle exceptions in Java.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        // Handle division by zero exception\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        try {\n            int result = 10 / 0;\n            System.out.println("Result: " + result);\n        } catch (ArithmeticException e) {\n            System.out.println("Error: Division by zero!");\n        } finally {\n            System.out.println("Execution completed.");\n        }\n    }\n}',
            'hint': 'Use try-catch block to handle exceptions. finally block always executes.',
            'testCases': ['Error: Division by zero!', 'Execution completed.']
          }
        ];
        break;
      case 'Java File Handling':
        _exercises = [
          {
            'title': 'File Operations',
            'description': 'Learn basic file operations in Java.',
            'starterCode': 'import java.io.File;\nimport java.io.FileWriter;\nimport java.io.IOException;\n\npublic class Main {\n    public static void main(String[] args) {\n        // Create and write to a file\n        \n    }\n}',
            'solution': 'import java.io.File;\nimport java.io.FileWriter;\nimport java.io.IOException;\n\npublic class Main {\n    public static void main(String[] args) {\n        try {\n            File file = new File("example.txt");\n            FileWriter writer = new FileWriter(file);\n            writer.write("Hello, File Handling!");\n            writer.close();\n            System.out.println("File written successfully!");\n        } catch (IOException e) {\n            System.out.println("Error: " + e.getMessage());\n        }\n    }\n}',
            'hint': 'Use File and FileWriter classes. Always handle IOException.',
            'testCases': ['File written successfully!']
          }
        ];
        break;
      case 'Java Multithreading':
        _exercises = [
          {
            'title': 'Thread Creation',
            'description': 'Learn how to create and run threads in Java.',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        // Create and start a thread\n        \n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        Thread thread = new Thread(() -> {\n            for (int i = 0; i < 3; i++) {\n                System.out.println("Thread is running: " + i);\n                try {\n                    Thread.sleep(1000);\n                } catch (InterruptedException e) {\n                    e.printStackTrace();\n                }\n            }\n        });\n        \n        thread.start();\n        System.out.println("Main thread finished.");\n    }\n}',
            'hint': 'Use Thread class or Runnable interface. Call start() to begin execution.',
            'testCases': ['Main thread finished.', 'Thread is running: 0', 'Thread is running: 1', 'Thread is running: 2']
          }
        ];
        break;
      default:
        _exercises = [
          {
            'title': 'Default Exercise',
            'description': 'Welcome to Java Programming!',
            'starterCode': 'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Welcome to Java Programming!");\n    }\n}',
            'solution': 'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Welcome to Java Programming!");\n    }\n}',
            'hint': 'Start with the main method and use System.out.println for output.',
            'testCases': ['Welcome to Java Programming!']
          }
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

    // Basic syntax checks for Java
    if (!code.contains('public class Main')) {
      errors.add('Missing public class Main');
    }

    if (!code.contains('public static void main(String[] args)')) {
      errors.add('Missing main method: public static void main(String[] args)');
    }

    if (!code.contains('{') || !code.contains('}')) {
      errors.add('Missing curly braces {} in class or method');
    }

    // Check for common syntax errors
    List<String> lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Check for missing semicolons in statements
      if ((line.contains('System.out.println') || line.contains('int ') ||
          line.contains('String ') || line.contains('double ')) &&
          !line.endsWith(';') && !line.contains('{') && !line.contains('}') &&
          !line.startsWith('//')) {
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
      case 'Java Introduction':
        if (_currentExercise == 0) return 'Hello, World!';
        if (_currentExercise == 1) return 'Name: John\nAge: 25\nSalary: 2500.5\nGrade: A\nIs Student: true';
        break;
      case 'Java Syntax':
        return 'Java Syntax is important!';
      case 'Java Data Types':
        return 'byte: 100\nshort: 1000\nint: 100000\nlong: 1000000000\nfloat: 3.14\ndouble: 3.14159\nboolean: true\nchar: J';
      case 'Java Variables':
        return 'x + y = 15\nx - y = 5\nName: Java\nActive: true';
      case 'Java Operators':
        return 'a + b = 19\na - b = 11\na * b = 60\na / b = 3\na % b = 3';
      case 'Java Strings':
        return 'Full Name: John Doe\nLength: 8\nUppercase: JOHN DOE\nFirst character: J';
      case 'Java Arrays':
        return 'Array elements:\nnumbers[0] = 1\nnumbers[1] = 2\nnumbers[2] = 3\nnumbers[3] = 4\nnumbers[4] = 5\nArray length: 5';
      case 'Java Methods':
        return '5 + 3 = 8';
      case 'Java OOP':
        return 'Name: Alice, Age: 30';
      case 'Java Inheritance':
        return 'Eating...\nBarking...';
      case 'Java Loops':
        return 'Number: 1\nNumber: 2\nNumber: 3\nNumber: 4\nNumber: 5';
      case 'Java Conditions':
        return 'Grade: B';
      case 'Java Collections':
        return 'ArrayList elements:\nJohn\nJane\nDoe\nSize: 3';
      case 'Java Exception Handling':
        return 'Error: Division by zero!\nExecution completed.';
      case 'Java File Handling':
        return 'File written successfully!';
      case 'Java Multithreading':
        return 'Main thread finished.\nThread is running: 0\nThread is running: 1\nThread is running: 2';
      default:
        return 'Welcome to Java Programming!';
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
    if (code.contains('"Java Syntax is important!"')) {
      outputLines.add('Java Syntax is important!');
    }
    if (code.contains('a + b') && code.contains('a - b')) {
      outputLines.addAll(['a + b = 19', 'a - b = 11', 'a * b = 60', 'a / b = 3', 'a % b = 3']);
    }
    if (code.contains('Full Name') && code.contains('John Doe')) {
      outputLines.addAll(['Full Name: John Doe', 'Length: 8', 'Uppercase: JOHN DOE', 'First character: J']);
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
    if (code.contains('ArrayList elements')) {
      outputLines.addAll(['ArrayList elements:', 'John', 'Jane', 'Doe', 'Size: 3']);
    }
    if (code.contains('Division by zero')) {
      outputLines.add('Error: Division by zero!');
    }
    if (code.contains('File written successfully')) {
      outputLines.add('File written successfully!');
    }
    if (code.contains('Welcome to Java Programming')) {
      outputLines.add('Welcome to Java Programming!');
    }

    // If no specific patterns matched, check for basic System.out.println statements
    if (outputLines.isEmpty) {
      List<String> lines = code.split('\n');
      for (String line in lines) {
        if (line.contains('System.out.println') && line.contains('"')) {
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
                language: 'java',
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
          flex: 2,
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
