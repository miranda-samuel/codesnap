import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/darcula.dart';

class PythonPracticeScreen extends StatefulWidget {
  final String moduleTitle;
  final Color primaryColor;
  final String language;

  const PythonPracticeScreen({
    Key? key,
    required this.moduleTitle,
    required this.primaryColor,
    required this.language,
  }) : super(key: key);

  @override
  State<PythonPracticeScreen> createState() => _PythonPracticeScreenState();
}

class _PythonPracticeScreenState extends State<PythonPracticeScreen> {
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
      case 'Python Introduction':
        _exercises = [
          {
            'title': 'Hello World Program',
            'description': 'Write your first Python program that displays "Hello, World!"',
            'starterCode': '# Write your first Python program here\n',
            'hint': 'Use print("Hello, World!") to display text. No semicolon needed in Python.',
            'solution': 'print("Hello, World!")',
            'testCases': ['Hello, World!']
          },
          {
            'title': 'Basic Output',
            'description': 'Display your name and age using print statements',
            'starterCode': '# Display your name and age\n',
            'hint': 'Use multiple print() statements. Example: print("Name: John")',
            'solution': 'print("Name: John")\nprint("Age: 25")',
            'testCases': ['Name: John', 'Age: 25']
          },
          {
            'title': 'Multiple Lines Output',
            'description': 'Display text on different lines using print',
            'starterCode': '# Display text on multiple lines\n',
            'hint': 'Use print() for each line. Each print automatically moves to next line.',
            'solution': 'print("Line 1")\nprint("Line 2")\nprint("Line 3")',
            'testCases': ['Line 1', 'Line 2', 'Line 3']
          },
        ];
        break;

      case 'Python Syntax':
        _exercises = [
          {
            'title': 'Variable Declaration',
            'description': 'Declare different types of variables and display them',
            'starterCode': '# Declare and display variables\n',
            'hint': 'Declare variables without type specification. Example: name = "John"',
            'solution': 'name = "John"\nage = 25\nprice = 19.99\nis_student = True\n\nprint("Name:", name)\nprint("Age:", age)\nprint("Price:", price)\nprint("Is Student:", is_student)',
            'testCases': ['Name: John', 'Age: 25', 'Price: 19.99', 'Is Student: True']
          },
          {
            'title': 'Basic Input',
            'description': 'Get user input using input() and display it back',
            'starterCode': '# Get user input and display it\n',
            'hint': 'Use input() for string input, int() or float() for numbers',
            'solution': 'name = input("Enter your name: ")\nage = int(input("Enter your age: "))\n\nprint(f"Hello {name}, you are {age} years old.")',
            'testCases': ['Hello', 'years old']
          },
          {
            'title': 'Comments Practice',
            'description': 'Use single-line and multi-line comments in your code',
            'starterCode': '# Add your code with comments\n',
            'hint': 'Use # for single-line comments and triple quotes for multi-line comments',
            'solution': '# This is a single-line comment\n\n"""\nThis is a multi-line comment\nIt can span multiple lines\n"""\n\nprint("Learning Python comments!")  # Comment after code',
            'testCases': ['Learning Python comments!']
          },
        ];
        break;

      case 'Python Variables':
        _exercises = [
          {
            'title': 'Variable Declaration and Initialization',
            'description': 'Declare and initialize different types of variables',
            'starterCode': '# Declare and initialize variables\n',
            'hint': 'Python variables don\'t need explicit type declaration',
            'solution': 'student_count = 30\naverage_score = 85.5\nfirst_initial = \'J\'\nis_passed = True\ncourse_name = "Python Programming"\n\nprint("Student Count:", student_count)\nprint("Average Score:", average_score)\nprint("First Initial:", first_initial)\nprint("Passed:", is_passed)\nprint("Course:", course_name)',
            'testCases': ['Student Count: 30', 'Average Score: 85.5', 'First Initial: J', 'Passed: True', 'Course: Python Programming']
          },
          {
            'title': 'Variable Reassignment',
            'description': 'Change variable values and observe the changes',
            'starterCode': 'score = 85\n# Change the score value\n',
            'hint': 'Assign new values to variables and print before and after',
            'solution': 'score = 85\nprint("Original score:", score)\n\nscore = 90  # Reassigning the variable\nprint("Updated score:", score)\n\nscore = score + 5  # Using the variable in calculation\nprint("Final score:", score)',
            'testCases': ['Original score: 85', 'Updated score: 90', 'Final score: 95']
          },
          {
            'title': 'Multiple Variable Operations',
            'description': 'Perform operations with multiple variables',
            'starterCode': 'a = 10\nb = 5\n# Perform operations with a and b\n',
            'hint': 'Use arithmetic operations with multiple variables',
            'solution': 'a = 10\nb = 5\n\nsum_result = a + b\ndifference = a - b\nproduct = a * b\nquotient = a / b\n\nprint("Sum:", sum_result)\nprint("Difference:", difference)\nprint("Product:", product)\nprint("Quotient:", quotient)',
            'testCases': ['Sum: 15', 'Difference: 5', 'Product: 50', 'Quotient: 2.0']
          },
        ];
        break;

      case 'Python Data Types':
        _exercises = [
          {
            'title': 'Basic Data Types',
            'description': 'Work with Python basic data types',
            'starterCode': '# Work with basic data types\n',
            'hint': 'Python has int, float, str, bool, list, tuple, dict, set',
            'solution': '# Integer\nage = 25\n\n# Float\nprice = 19.99\n\n# String\nname = "John"\n\n# Boolean\nis_active = True\n\n# List\nfruits = ["apple", "banana", "cherry"]\n\n# Tuple\ncoordinates = (10, 20)\n\n# Dictionary\nperson = {"name": "John", "age": 25}\n\nprint("Age:", age, type(age))\nprint("Price:", price, type(price))\nprint("Name:", name, type(name))\nprint("Active:", is_active, type(is_active))\nprint("Fruits:", fruits, type(fruits))\nprint("Coordinates:", coordinates, type(coordinates))\nprint("Person:", person, type(person))',
            'testCases': ['Age: 25', 'Price: 19.99', 'Name: John', 'Active: True']
          },
          {
            'title': 'Type Conversion',
            'description': 'Practice type casting and conversion',
            'starterCode': '# Practice type conversion\n',
            'hint': 'Use int(), float(), str(), bool() for type conversion',
            'solution': '# String to integer\nnumber_str = "123"\nnumber_int = int(number_str)\nprint("String to int:", number_int, type(number_int))\n\n# Integer to string\nage = 25\nage_str = str(age)\nprint("Int to string:", age_str, type(age_str))\n\n# Float to integer\nprice = 19.99\nprice_int = int(price)\nprint("Float to int:", price_int, type(price_int))\n\n# Boolean conversion\nprint("bool(1):", bool(1))\nprint("bool(0):", bool(0))\nprint("bool(\"hello\"):", bool("hello"))\nprint("bool(\"\"):", bool(""))',
            'testCases': ['String to int: 123', 'Int to string: 25', 'Float to int: 19']
          },
          {
            'title': 'Type Checking',
            'description': 'Check and verify data types',
            'starterCode': '# Check data types\n',
            'hint': 'Use type() function to check data types',
            'solution': 'x = 5\ny = 3.14\nz = "Hello"\nw = True\n\nprint("Type of x:", type(x))\nprint("Type of y:", type(y))\nprint("Type of z:", type(z))\nprint("Type of w:", type(w))\n\n# Using isinstance\nprint("x is integer:", isinstance(x, int))\nprint("y is float:", isinstance(y, float))\nprint("z is string:", isinstance(z, str))\nprint("w is boolean:", isinstance(w, bool))',
            'testCases': ['Type of x: <class \'int\'>', 'Type of y: <class \'float\'>', 'x is integer: True']
          },
        ];
        break;

      case 'Python Strings':
        _exercises = [
          {
            'title': 'String Basics',
            'description': 'Create and manipulate strings',
            'starterCode': '# Work with strings\n',
            'hint': 'Create strings, concatenate them, and find length',
            'solution': 'first_name = "John"\nlast_name = "Doe"\nfull_name = first_name + " " + last_name\n\nprint("First Name:", first_name)\nprint("Last Name:", last_name)\nprint("Full Name:", full_name)\nprint("Length:", len(full_name))',
            'testCases': ['First Name: John', 'Last Name: Doe', 'Full Name: John Doe', 'Length: 8']
          },
          {
            'title': 'String Methods',
            'description': 'Use various string methods',
            'starterCode': 'text = "Hello Python Programming"\n# Use string methods\n',
            'hint': 'Try upper(), lower(), strip(), replace(), split() methods',
            'solution': 'text = "Hello Python Programming"\n\nprint("Original:", text)\nprint("Uppercase:", text.upper())\nprint("Lowercase:", text.lower())\nprint("Capitalize:", text.capitalize())\nprint("Title case:", text.title())\nprint("Replace:", text.replace("Python", "Java"))\nprint("Split:", text.split())\nprint("Find Python:", text.find("Python"))',
            'testCases': ['Original: Hello Python Programming', 'Uppercase: HELLO PYTHON PROGRAMMING', 'Lowercase: hello python programming']
          },
          {
            'title': 'String Formatting',
            'description': 'Format strings using different methods',
            'starterCode': 'name = "John"\nage = 25\n# Format strings\n',
            'hint': 'Use f-strings, format() method, or % formatting',
            'solution': 'name = "John"\nage = 25\n\n# f-string (Python 3.6+)\nprint(f"My name is {name} and I am {age} years old.")\n\n# format() method\nprint("My name is {} and I am {} years old.".format(name, age))\n\n# % formatting\nprint("My name is %s and I am %d years old." % (name, age))\n\n# String with calculations\nprint(f"Next year I will be {age + 1} years old.")',
            'testCases': ['My name is John and I am 25 years old.', 'Next year I will be 26 years old.']
          },
        ];
        break;

      case 'Python Operators':
        _exercises = [
          {
            'title': 'Arithmetic Operators',
            'description': 'Perform basic arithmetic operations',
            'starterCode': 'a = 15\nb = 4\n# Perform arithmetic operations\n',
            'hint': 'Use +, -, *, /, //, %, ** operators',
            'solution': 'a = 15\nb = 4\n\nprint("a + b =", a + b)\nprint("a - b =", a - b)\nprint("a * b =", a * b)\nprint("a / b =", a / b)\nprint("a // b =", a // b)  # Floor division\nprint("a % b =", a % b)   # Modulus\nprint("a ** b =", a ** b) # Exponentiation',
            'testCases': ['a + b = 19', 'a - b = 11', 'a * b = 60', 'a / b = 3.75', 'a // b = 3', 'a % b = 3']
          },
          {
            'title': 'Comparison Operators',
            'description': 'Use comparison operators to compare values',
            'starterCode': 'x = 10\ny = 20\n# Use comparison operators\n',
            'hint': 'Use ==, !=, >, <, >=, <= to compare x and y',
            'solution': 'x = 10\ny = 20\n\nprint("x == y:", x == y)\nprint("x != y:", x != y)\nprint("x > y:", x > y)\nprint("x < y:", x < y)\nprint("x >= y:", x >= y)\nprint("x <= y:", x <= y)',
            'testCases': ['x == y: False', 'x != y: True', 'x > y: False', 'x < y: True', 'x >= y: False', 'x <= y: True']
          },
          {
            'title': 'Logical Operators',
            'description': 'Use logical operators with boolean values',
            'starterCode': 'p = True\nq = False\n# Use logical operators\n',
            'hint': 'Use and, or, not with p and q',
            'solution': 'p = True\nq = False\n\nprint("p and q:", p and q)\nprint("p or q:", p or q)\nprint("not p:", not p)\nprint("not q:", not q)\n\n# Combined conditions\nprint("p and not q:", p and not q)\nprint("(p or q) and not p:", (p or q) and not p)',
            'testCases': ['p and q: False', 'p or q: True', 'not p: False', 'not q: True']
          },
        ];
        break;

      default:
        _exercises = [
          {
            'title': 'Basic Python Program',
            'description': 'Write a simple Python program',
            'starterCode': '# Write your first Python program\n',
            'hint': 'Start with print() to display output',
            'solution': 'print("Welcome to Python Programming!")\nprint("Python is fun and powerful!")\n\n# Basic calculations\nprint("2 + 3 =", 2 + 3)\nprint("10 - 5 =", 10 - 5)\nprint("6 * 7 =", 6 * 7)\nprint("15 / 3 =", 15 / 3)',
            'testCases': ['Welcome to Python Programming!', 'Python is fun and powerful!', '2 + 3 = 5', '10 - 5 = 5', '6 * 7 = 42', '15 / 3 = 5.0']
          },
          {
            'title': 'Variable Practice',
            'description': 'Practice with variables and basic operations',
            'starterCode': '# Practice with variables\n',
            'hint': 'Use variables to store values and perform operations',
            'solution': '# Variable assignment\nname = "Alice"\nage = 25\nheight = 5.6\nis_student = True\n\n# Display variables\nprint("Name:", name)\nprint("Age:", age)\nprint("Height:", height)\nprint("Is student:", is_student)\n\n# Variable operations\nnext_year_age = age + 1\nfull_intro = name + " is " + str(age) + " years old"\n\nprint("Next year age:", next_year_age)\nprint("Full introduction:", full_intro)\n\n# Multiple assignment\nx, y, z = 1, 2, 3\nprint("x =", x, "y =", y, "z =", z)\n\n# Swap variables\nx, y = y, x\nprint("After swap: x =", x, "y =", y)',
            'testCases': ['Name: Alice', 'Age: 25', 'Height: 5.6', 'Is student: True', 'Next year age: 26', 'Full introduction: Alice is 25 years old', 'x = 1 y = 2 z = 3', 'After swap: x = 2 y = 1']
          },
          {
            'title': 'Input and Output',
            'description': 'Get user input and display formatted output',
            'starterCode': '# Get user input and display output\n',
            'hint': 'Use input() for input and print() with f-strings for formatted output',
            'solution': '# Get user input\nname = input("Enter your name: ")\nage = int(input("Enter your age: "))\ncity = input("Enter your city: ")\n\n# Display using different methods\nprint("=== Basic Output ===")\nprint("Name:", name)\nprint("Age:", age)\nprint("City:", city)\n\nprint("\\n=== Formatted Output ===")\nprint(f"Hello {name}! You are {age} years old and live in {city}.")\n\nprint("\\n=== Using format() ===")\nprint("Hello {}! You are {} years old and live in {}.".format(name, age, city))\n\nprint("\\n=== Multi-line String ===")\nmessage = f"""\nPersonal Information:\n-------------------\nName: {name}\nAge: {age}\nCity: {city}\nNext Year Age: {age + 1}\n"""\nprint(message)\n\n# Simple calculation with input\nprint("\\n=== Simple Calculator ===")\nnum1 = float(input("Enter first number: "))\nnum2 = float(input("Enter second number: "))\n\nprint(f"{num1} + {num2} = {num1 + num2}")\nprint(f"{num1} - {num2} = {num1 - num2}")\nprint(f"{num1} * {num2} = {num1 * num2}")\nprint(f"{num1} / {num2} = {num1 / num2}")',
            'testCases': ['=== Basic Output ===', '=== Formatted Output ===', '=== Using format() ===', '=== Multi-line String ===', '=== Simple Calculator ===']
          },
        ];
    }
  }

  void _runCode() {
    setState(() {
      _isRunning = true;
      _output = '🚀 Running your Python code...\n\n';
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isRunning = false;

        List<String> errors = _checkForErrors(_codeController.text);

        if (errors.isEmpty) {
          _output += '✅ Code executed successfully!\n';
          _output += '✅ No syntax errors found\n';
          _output += '✅ Program output:\n\n';

          String userOutput = _simulateProgramExecution(_codeController.text);
          _output += userOutput;

          _checkSolution(userOutput);
        } else {
          _output += '❌ Execution failed!\n';
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

    // Check for basic Python syntax issues
    List<String> lines = code.split('\n');
    int indentLevel = 0;
    bool inMultilineString = false;
    String multilineChar = '';

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      String originalLine = lines[i];

      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) continue;

      // Check for multiline strings
      if (!inMultilineString) {
        if (line.contains('"""') || line.contains("'''")) {
          inMultilineString = true;
          multilineChar = line.contains('"""') ? '"""' : "'''";
          // Check if it starts and ends on same line
          int count = line.split(multilineChar).length - 1;
          if (count % 2 == 0) {
            inMultilineString = false;
          }
          continue;
        }
      } else {
        if (line.contains(multilineChar)) {
          inMultilineString = false;
        }
        continue;
      }

      // Check indentation
      if (!inMultilineString) {
        int leadingSpaces = originalLine.length - originalLine.trimLeft().length;
        int expectedSpaces = indentLevel * 4;

        // Check for inconsistent indentation
        if (leadingSpaces % 4 != 0 && leadingSpaces > 0) {
          errors.add('Inconsistent indentation at line ${i + 1} (use 4 spaces per indent)');
        }

        // Check for unexpected indentation
        if (leadingSpaces > expectedSpaces && i > 0) {
          String prevLine = lines[i - 1].trim();
          if (!prevLine.endsWith(':') && !prevLine.isEmpty) {
            errors.add('Unexpected indentation at line ${i + 1}');
          }
        }

        // Check for missing indentation after colon
        if (i > 0) {
          String prevLine = lines[i - 1].trim();
          if (prevLine.endsWith(':') && leadingSpaces <= expectedSpaces) {
            errors.add('Expected indented block after colon at line ${i}');
          }
        }
      }

      // Update indent level based on previous line
      if (i > 0) {
        String prevLine = lines[i - 1].trim();
        if (prevLine.endsWith(':') && !inMultilineString) {
          indentLevel++;
        }
      }

      // Check for common syntax errors
      if (line.contains('print') && !line.contains('(') && !line.contains(')')) {
        errors.add('Missing parentheses in print statement at line ${i + 1}');
      }

      // Check for unmatched parentheses, brackets, braces
      if (_countOccurrences(line, '(') != _countOccurrences(line, ')')) {
        errors.add('Unmatched parentheses at line ${i + 1}');
      }
      if (_countOccurrences(line, '[') != _countOccurrences(line, ']')) {
        errors.add('Unmatched brackets at line ${i + 1}');
      }
      if (_countOccurrences(line, '{') != _countOccurrences(line, '}')) {
        errors.add('Unmatched braces at line ${i + 1}');
      }

      // Check for string quotes
      int singleQuotes = _countOccurrences(line, "'");
      int doubleQuotes = _countOccurrences(line, '"');
      if (singleQuotes % 2 != 0 && doubleQuotes % 2 != 0) {
        errors.add('Unclosed quotation marks at line ${i + 1}');
      }
    }

    // Check if we're still in a multiline string at the end
    if (inMultilineString) {
      errors.add('Unclosed multiline string');
    }

    return errors;
  }

  String _simulateProgramExecution(String code) {
    Map<String, dynamic> variables = {};
    List<String> outputLines = [];
    List<String> inputQueue = [];

    // Predefined inputs for common scenarios
    if (code.contains('input(')) {
      if (code.contains('Enter your name')) {
        inputQueue.add('John');
      }
      if (code.contains('Enter your age')) {
        inputQueue.add('25');
      }
      if (code.contains('Enter first number')) {
        inputQueue.add('10');
        inputQueue.add('5');
      }
    }

    String cleanCode = code.replaceAll(RegExp(r'#.*'), '');
    cleanCode = cleanCode.replaceAll(RegExp(r'""".*?"""', multiLine: true), '');
    cleanCode = cleanCode.replaceAll(RegExp(r"'''.*?'''", multiLine: true), '');

    List<String> lines = cleanCode.split('\n');
    int inputIndex = 0;

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Variable assignment
      if (line.contains('=') && !line.contains('print') && !line.contains('input')) {
        _processAssignment(line, variables);
      }

      // Print statements
      if (line.contains('print(')) {
        String output = _processPrintStatement(line, variables);
        if (output.isNotEmpty) {
          outputLines.add(output);
        }
      }

      // Input statements
      if (line.contains('input(')) {
        String inputValue = inputIndex < inputQueue.length ? inputQueue[inputIndex] : 'test';
        inputIndex++;
        _processInputStatement(line, inputValue, variables);
      }

      // If statements (basic simulation)
      if (line.startsWith('if ') || line.startsWith('elif ') || line.startsWith('else:')) {
        // Simple simulation - just continue execution
        continue;
      }

      // For loops (basic simulation)
      if (line.startsWith('for ') || line.startsWith('while ')) {
        // Simple simulation - just continue execution
        continue;
      }

      // Function definitions (skip for simulation)
      if (line.startsWith('def ') || line.startsWith('class ')) {
        continue;
      }
    }

    return outputLines.join('\n');
  }

  void _processAssignment(String line, Map<String, dynamic> variables) {
    List<String> parts = line.split('=');
    if (parts.length >= 2) {
      String varName = parts[0].trim();
      String expression = parts[1].replaceAll(';', '').trim();

      // Handle multiple assignment
      if (varName.contains(',')) {
        List<String> varNames = varName.split(',').map((s) => s.trim()).toList();
        List<String> values = expression.split(',').map((s) => s.trim()).toList();

        for (int i = 0; i < varNames.length; i++) {
          if (i < values.length) {
            variables[varNames[i]] = _evaluateExpression(values[i], variables);
          }
        }
      } else {
        variables[varName] = _evaluateExpression(expression, variables);
      }
    }
  }

  String _processPrintStatement(String line, Map<String, dynamic> variables) {
    String output = '';

    if (line.contains('print(')) {
      try {
        String content = line.substring(line.indexOf('(') + 1, line.lastIndexOf(')'));

        // Handle f-strings
        if (content.contains('f"') || content.contains("f'")) {
          output = _processFString(content, variables);
        } else {
          // Handle regular print with variables and strings
          output = _processRegularPrint(content, variables);
        }
      } catch (e) {
        output = 'Error in print statement';
      }
    }

    return output;
  }

  String _processFString(String content, Map<String, dynamic> variables) {
    String result = content;

    // Extract expressions inside {}
    RegExp exp = RegExp(r'\{(.*?)\}');
    Iterable<RegExpMatch> matches = exp.allMatches(content);

    for (RegExpMatch match in matches) {
      String expression = match.group(1)!;
      dynamic value = _evaluateExpression(expression, variables);
      result = result.replaceFirst('{$expression}', value.toString());
    }

    // Remove the f prefix and quotes
    result = result.replaceFirst('f"', '').replaceFirst('f\'', '');
    result = result.replaceFirst('"', '').replaceFirst("'", '');

    return result;
  }

  String _processRegularPrint(String content, Map<String, dynamic> variables) {
    List<String> parts = content.split(',');
    List<String> outputParts = [];

    for (String part in parts) {
      part = part.trim();

      if (part.startsWith('"') && part.endsWith('"') ||
          part.startsWith("'") && part.endsWith("'")) {
        // String literal
        outputParts.add(part.substring(1, part.length - 1));
      } else if (variables.containsKey(part)) {
        // Variable
        outputParts.add(variables[part].toString());
      } else {
        // Expression or unknown
        try {
          dynamic value = _evaluateExpression(part, variables);
          outputParts.add(value.toString());
        } catch (e) {
          outputParts.add(part);
        }
      }
    }

    return outputParts.join(' ');
  }

  void _processInputStatement(String line, String inputValue, Map<String, dynamic> variables) {
    if (line.contains('=') && line.contains('input(')) {
      List<String> parts = line.split('=');
      String varName = parts[0].trim();

      // Check if input is converted to int or float
      if (line.contains('int(input')) {
        try {
          variables[varName] = int.parse(inputValue);
        } catch (e) {
          variables[varName] = 0;
        }
      } else if (line.contains('float(input')) {
        try {
          variables[varName] = double.parse(inputValue);
        } catch (e) {
          variables[varName] = 0.0;
        }
      } else {
        variables[varName] = inputValue;
      }
    }
  }

  dynamic _evaluateExpression(String expression, Map<String, dynamic> variables) {
    expression = expression.trim();

    // Handle string concatenation
    if (expression.contains('+') && !expression.contains('" + "') && !expression.contains("' + '")) {
      List<String> parts = expression.split('+');
      if (parts.length == 2) {
        dynamic left = _getValue(parts[0].trim(), variables);
        dynamic right = _getValue(parts[1].trim(), variables);

        // Handle different types
        if (left is String || right is String) {
          return left.toString() + right.toString();
        } else {
          return left + right;
        }
      }
    }

    // Handle arithmetic operations
    if (expression.contains('-')) {
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
      return left / right;
    }
    else if (expression.contains('//')) {
      List<String> parts = expression.split('//');
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
    else if (expression.contains('**')) {
      List<String> parts = expression.split('**');
      dynamic left = _getValue(parts[0].trim(), variables);
      dynamic right = _getValue(parts[1].trim(), variables);
      return left * right; // Simplified
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
    if (token == 'True') return true;
    if (token == 'False') return false;
    if (token == 'None') return null;

    if (token.startsWith('"') && token.endsWith('"')) {
      return token.substring(1, token.length - 1);
    }
    if (token.startsWith("'") && token.endsWith("'")) {
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
                language: 'python',
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
          'Python IDE - ${widget.moduleTitle}',
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
                        '📝 Python Code Editor',
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
                                      // FIXED: Gamitin ang tamang constructor parameters
                                      _codeController.text,
                                      language: 'python',
                                      theme: darculaTheme,
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
                        _output.isEmpty ? '🚀 Click "Run Code" to execute your Python program...' : _output,
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
                        '📝 Python Code Editor',
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
                                      // FIXED: Gamitin ang tamang constructor parameters
                                      _codeController.text,
                                      language: 'python',
                                      theme: darculaTheme,
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
                        _output.isEmpty ? '🚀 Click "Run Code" to execute your Python program...' : _output,
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