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
            'description': 'Write your first Java program that displays "Hello, World!"',
            'starterCode': 'public class HelloWorld {\n    public static void main(String[] args) {\n        // Write your code here\n        \n    }\n}',
            'hint': 'Use System.out.println("Hello, World!"); to display text. Make sure to include the semicolon at the end.',
            'solution': 'public class HelloWorld {\n    public static void main(String[] args) {\n        System.out.println("Hello, World!");\n    }\n}',
            'testCases': ['Hello, World!']
          },
          {
            'title': 'Basic Output',
            'description': 'Display your name and age using print statements',
            'starterCode': 'public class PersonalInfo {\n    public static void main(String[] args) {\n        // Display your name\n        \n        // Display your age\n        \n    }\n}',
            'hint': 'Use multiple System.out.println() statements. Example: System.out.println("Name: John");',
            'solution': 'public class PersonalInfo {\n    public static void main(String[] args) {\n        System.out.println("Name: John");\n        System.out.println("Age: 25");\n    }\n}',
            'testCases': ['Name: John', 'Age: 25']
          },
          {
            'title': 'Multiple Lines Output',
            'description': 'Display text on different lines using println',
            'starterCode': 'public class MultiLine {\n    public static void main(String[] args) {\n        // Display text on multiple lines\n        \n    }\n}',
            'hint': 'Use System.out.println() for each line. Each println automatically moves to next line.',
            'solution': 'public class MultiLine {\n    public static void main(String[] args) {\n        System.out.println("Line 1");\n        System.out.println("Line 2");\n        System.out.println("Line 3");\n    }\n}',
            'testCases': ['Line 1', 'Line 2', 'Line 3']
          },
        ];
        break;

      case 'Java Syntax':
        _exercises = [
          {
            'title': 'Variable Declaration',
            'description': 'Declare different types of variables and display them',
            'starterCode': 'public class Variables {\n    public static void main(String[] args) {\n        // Declare variables here\n        \n        // Display variables\n        \n    }\n}',
            'hint': 'Declare int, double, char, boolean, and String variables. Example: int age = 25;',
            'solution': 'public class Variables {\n    public static void main(String[] args) {\n        int age = 25;\n        double price = 19.99;\n        char grade = \'A\';\n        boolean isStudent = true;\n        String name = "John";\n        \n        System.out.println("Age: " + age);\n        System.out.println("Price: " + price);\n        System.out.println("Grade: " + grade);\n        System.out.println("Is Student: " + isStudent);\n        System.out.println("Name: " + name);\n    }\n}',
            'testCases': ['Age: 25', 'Price: 19.99', 'Grade: A', 'Is Student: true', 'Name: John']
          },
          {
            'title': 'Basic Input',
            'description': 'Get user input using Scanner and display it back',
            'starterCode': 'import java.util.Scanner;\n\npublic class UserInput {\n    public static void main(String[] args) {\n        // Create Scanner object\n        \n        // Get user input\n        \n        // Display the input\n        \n    }\n}',
            'hint': 'Use Scanner scanner = new Scanner(System.in); and scanner.nextLine() for input',
            'solution': 'import java.util.Scanner;\n\npublic class UserInput {\n    public static void main(String[] args) {\n        Scanner scanner = new Scanner(System.in);\n        \n        System.out.print("Enter your name: ");\n        String name = scanner.nextLine();\n        \n        System.out.print("Enter your age: ");\n        int age = scanner.nextInt();\n        \n        System.out.println("Hello " + name + ", you are " + age + " years old.");\n        \n        scanner.close();\n    }\n}',
            'testCases': ['Hello', 'years old']
          },
          {
            'title': 'Comments Practice',
            'description': 'Use single-line and multi-line comments in your code',
            'starterCode': 'public class Comments {\n    public static void main(String[] args) {\n        // Add your code with comments\n        \n    }\n}',
            'hint': 'Use // for single-line comments and /* */ for multi-line comments',
            'solution': 'public class Comments {\n    public static void main(String[] args) {\n        // This is a single-line comment\n        \n        /*\n        This is a multi-line comment\n        It can span multiple lines\n        */\n        \n        System.out.println("Learning Java comments!"); // Comment after code\n    }\n}',
            'testCases': ['Learning Java comments!']
          },
        ];
        break;

      case 'Java Variables':
        _exercises = [
          {
            'title': 'Variable Declaration and Initialization',
            'description': 'Declare and initialize different types of variables',
            'starterCode': 'public class VariablePractice {\n    public static void main(String[] args) {\n        // Declare and initialize variables\n        \n    }\n}',
            'hint': 'Declare variables with different data types and assign values',
            'solution': 'public class VariablePractice {\n    public static void main(String[] args) {\n        int studentCount = 30;\n        double averageScore = 85.5;\n        char firstInitial = \'J\';\n        boolean isPassed = true;\n        String courseName = "Java Programming";\n        \n        System.out.println("Student Count: " + studentCount);\n        System.out.println("Average Score: " + averageScore);\n        System.out.println("First Initial: " + firstInitial);\n        System.out.println("Passed: " + isPassed);\n        System.out.println("Course: " + courseName);\n    }\n}',
            'testCases': ['Student Count: 30', 'Average Score: 85.5', 'First Initial: J', 'Passed: true', 'Course: Java Programming']
          },
          {
            'title': 'Variable Reassignment',
            'description': 'Change variable values and observe the changes',
            'starterCode': 'public class VariableChange {\n    public static void main(String[] args) {\n        int score = 85;\n        // Change the score value\n        \n    }\n}',
            'hint': 'Assign new values to variables and print before and after',
            'solution': 'public class VariableChange {\n    public static void main(String[] args) {\n        int score = 85;\n        System.out.println("Original score: " + score);\n        \n        score = 90; // Reassigning the variable\n        System.out.println("Updated score: " + score);\n        \n        score = score + 5; // Using the variable in calculation\n        System.out.println("Final score: " + score);\n    }\n}',
            'testCases': ['Original score: 85', 'Updated score: 90', 'Final score: 95']
          },
          {
            'title': 'Multiple Variable Operations',
            'description': 'Perform operations with multiple variables',
            'starterCode': 'public class MultipleVariables {\n    public static void main(String[] args) {\n        int a = 10, b = 5;\n        // Perform operations with a and b\n        \n    }\n}',
            'hint': 'Use arithmetic operations with multiple variables',
            'solution': 'public class MultipleVariables {\n    public static void main(String[] args) {\n        int a = 10, b = 5;\n        \n        int sum = a + b;\n        int difference = a - b;\n        int product = a * b;\n        int quotient = a / b;\n        \n        System.out.println("Sum: " + sum);\n        System.out.println("Difference: " + difference);\n        System.out.println("Product: " + product);\n        System.out.println("Quotient: " + quotient);\n    }\n}',
            'testCases': ['Sum: 15', 'Difference: 5', 'Product: 50', 'Quotient: 2']
          },
        ];
        break;

      case 'Java Data Types':
        _exercises = [
          {
            'title': 'Primitive Data Types',
            'description': 'Work with Java primitive data types',
            'starterCode': 'public class PrimitiveTypes {\n    public static void main(String[] args) {\n        // Declare primitive data types\n        \n    }\n}',
            'hint': 'Declare byte, short, int, long, float, double, char, boolean with appropriate values',
            'solution': 'public class PrimitiveTypes {\n    public static void main(String[] args) {\n        byte smallNumber = 100;\n        short mediumNumber = 10000;\n        int number = 100000;\n        long bigNumber = 1000000000L;\n        float decimal = 3.14f;\n        double preciseDecimal = 3.14159265359;\n        char letter = \'J\';\n        boolean isJavaFun = true;\n        \n        System.out.println("byte: " + smallNumber);\n        System.out.println("short: " + mediumNumber);\n        System.out.println("int: " + number);\n        System.out.println("long: " + bigNumber);\n        System.out.println("float: " + decimal);\n        System.out.println("double: " + preciseDecimal);\n        System.out.println("char: " + letter);\n        System.out.println("boolean: " + isJavaFun);\n    }\n}',
            'testCases': ['byte: 100', 'short: 10000', 'int: 100000', 'long: 1000000000', 'float: 3.14', 'double: 3.14159265359', 'char: J', 'boolean: true']
          },
          {
            'title': 'Reference Data Types',
            'description': 'Work with String and Arrays',
            'starterCode': 'public class ReferenceTypes {\n    public static void main(String[] args) {\n        // Work with String and arrays\n        \n    }\n}',
            'hint': 'Create String object and integer array',
            'solution': 'public class ReferenceTypes {\n    public static void main(String[] args) {\n        String message = new String("Hello Java");\n        String greeting = "Welcome"; // String literal\n        \n        int[] numbers = {1, 2, 3, 4, 5};\n        String[] names = {"Alice", "Bob", "Charlie"};\n        \n        System.out.println(message);\n        System.out.println(greeting);\n        System.out.println("First number: " + numbers[0]);\n        System.out.println("Second name: " + names[1]);\n    }\n}',
            'testCases': ['Hello Java', 'Welcome', 'First number: 1', 'Second name: Bob']
          },
          {
            'title': 'Type Conversion',
            'description': 'Practice type casting and conversion',
            'starterCode': 'public class TypeConversion {\n    public static void main(String[] args) {\n        // Practice type conversion\n        \n    }\n}',
            'hint': 'Use widening (automatic) and narrowing (manual) casting',
            'solution': 'public class TypeConversion {\n    public static void main(String[] args) {\n        // Widening casting (automatic)\n        int myInt = 9;\n        double myDouble = myInt; // Automatic casting: int to double\n        \n        // Narrowing casting (manual)\n        double anotherDouble = 9.78;\n        int anotherInt = (int) anotherDouble; // Manual casting: double to int\n        \n        System.out.println("Original int: " + myInt);\n        System.out.println("Converted to double: " + myDouble);\n        System.out.println("Original double: " + anotherDouble);\n        System.out.println("Converted to int: " + anotherInt);\n        \n        // String to int\n        String numberStr = "123";\n        int numberFromStr = Integer.parseInt(numberStr);\n        System.out.println("String to int: " + numberFromStr);\n    }\n}',
            'testCases': ['Original int: 9', 'Converted to double: 9.0', 'Original double: 9.78', 'Converted to int: 9', 'String to int: 123']
          },
        ];
        break;

      case 'Java Strings':
        _exercises = [
          {
            'title': 'String Basics',
            'description': 'Create and manipulate strings',
            'starterCode': 'public class StringBasics {\n    public static void main(String[] args) {\n        // Work with strings\n        \n    }\n}',
            'hint': 'Create strings, concatenate them, and find length',
            'solution': 'public class StringBasics {\n    public static void main(String[] args) {\n        String firstName = "John";\n        String lastName = "Doe";\n        String fullName = firstName + " " + lastName;\n        \n        System.out.println("First Name: " + firstName);\n        System.out.println("Last Name: " + lastName);\n        System.out.println("Full Name: " + fullName);\n        System.out.println("Length: " + fullName.length());\n    }\n}',
            'testCases': ['First Name: John', 'Last Name: Doe', 'Full Name: John Doe', 'Length: 8']
          },
          {
            'title': 'String Methods',
            'description': 'Use various string methods',
            'starterCode': 'public class StringMethods {\n    public static void main(String[] args) {\n        String text = "Hello Java Programming";\n        \n        // Use string methods\n        \n    }\n}',
            'hint': 'Try substring(), indexOf(), toUpperCase(), toLowerCase() methods',
            'solution': 'public class StringMethods {\n    public static void main(String[] args) {\n        String text = "Hello Java Programming";\n        \n        System.out.println("Original: " + text);\n        System.out.println("Uppercase: " + text.toUpperCase());\n        System.out.println("Lowercase: " + text.toLowerCase());\n        System.out.println("Substring: " + text.substring(0, 5));\n        System.out.println("Index of Java: " + text.indexOf("Java"));\n        System.out.println("Replace: " + text.replace("Java", "Python"));\n    }\n}',
            'testCases': ['Original: Hello Java Programming', 'Uppercase: HELLO JAVA PROGRAMMING', 'Lowercase: hello java programming', 'Substring: Hello', 'Index of Java: 6', 'Replace: Hello Python Programming']
          },
          {
            'title': 'String Comparison',
            'description': 'Compare strings using different methods',
            'starterCode': 'public class StringComparison {\n    public static void main(String[] args) {\n        String str1 = "Hello";\n        String str2 = "Hello";\n        String str3 = new String("Hello");\n        \n        // Compare strings\n        \n    }\n}',
            'hint': 'Use equals(), equalsIgnoreCase(), and == for comparison',
            'solution': 'public class StringComparison {\n    public static void main(String[] args) {\n        String str1 = "Hello";\n        String str2 = "Hello";\n        String str3 = new String("Hello");\n        String str4 = "HELLO";\n        \n        System.out.println("str1 == str2: " + (str1 == str2));\n        System.out.println("str1 == str3: " + (str1 == str3));\n        System.out.println("str1.equals(str2): " + str1.equals(str2));\n        System.out.println("str1.equals(str3): " + str1.equals(str3));\n        System.out.println("str1.equalsIgnoreCase(str4): " + str1.equalsIgnoreCase(str4));\n    }\n}',
            'testCases': ['str1 == str2: true', 'str1 == str3: false', 'str1.equals(str2): true', 'str1.equals(str3): true', 'str1.equalsIgnoreCase(str4): true']
          },
        ];
        break;

      case 'Java Operators':
        _exercises = [
          {
            'title': 'Arithmetic Operators',
            'description': 'Perform basic arithmetic operations',
            'starterCode': 'public class Arithmetic {\n    public static void main(String[] args) {\n        int a = 15, b = 4;\n        \n        // Perform arithmetic operations\n        \n    }\n}',
            'hint': 'Use +, -, *, /, % operators with variables a and b',
            'solution': 'public class Arithmetic {\n    public static void main(String[] args) {\n        int a = 15, b = 4;\n        \n        System.out.println("a + b = " + (a + b));\n        System.out.println("a - b = " + (a - b));\n        System.out.println("a * b = " + (a * b));\n        System.out.println("a / b = " + (a / b));\n        System.out.println("a % b = " + (a % b));\n    }\n}',
            'testCases': ['a + b = 19', 'a - b = 11', 'a * b = 60', 'a / b = 3', 'a % b = 3']
          },
          {
            'title': 'Comparison Operators',
            'description': 'Use comparison operators to compare values',
            'starterCode': 'public class Comparison {\n    public static void main(String[] args) {\n        int x = 10, y = 20;\n        \n        // Use comparison operators\n        \n    }\n}',
            'hint': 'Use ==, !=, >, <, >=, <= to compare x and y',
            'solution': 'public class Comparison {\n    public static void main(String[] args) {\n        int x = 10, y = 20;\n        \n        System.out.println("x == y: " + (x == y));\n        System.out.println("x != y: " + (x != y));\n        System.out.println("x > y: " + (x > y));\n        System.out.println("x < y: " + (x < y));\n        System.out.println("x >= y: " + (x >= y));\n        System.out.println("x <= y: " + (x <= y));\n    }\n}',
            'testCases': ['x == y: false', 'x != y: true', 'x > y: false', 'x < y: true', 'x >= y: false', 'x <= y: true']
          },
          {
            'title': 'Logical Operators',
            'description': 'Use logical operators with boolean values',
            'starterCode': 'public class Logical {\n    public static void main(String[] args) {\n        boolean p = true, q = false;\n        \n        // Use logical operators\n        \n    }\n}',
            'hint': 'Use && (AND), || (OR), ! (NOT) with p and q',
            'solution': 'public class Logical {\n    public static void main(String[] args) {\n        boolean p = true, q = false;\n        \n        System.out.println("p && q: " + (p && q));\n        System.out.println("p || q: " + (p || q));\n        System.out.println("!p: " + (!p));\n        System.out.println("!q: " + (!q));\n    }\n}',
            'testCases': ['p && q: false', 'p || q: true', '!p: false', '!q: true']
          },
        ];
        break;

      case 'Java Conditions':
        _exercises = [
          {
            'title': 'If-Else Statement',
            'description': 'Use if-else to make decisions based on conditions',
            'starterCode': 'public class IfElse {\n    public static void main(String[] args) {\n        int score = 85;\n        \n        // Use if-else statement\n        \n    }\n}',
            'hint': 'Use if-else to assign grades based on score',
            'solution': 'public class IfElse {\n    public static void main(String[] args) {\n        int score = 85;\n        \n        if (score >= 90) {\n            System.out.println("Grade: A");\n        } else if (score >= 80) {\n            System.out.println("Grade: B");\n        } else if (score >= 70) {\n            System.out.println("Grade: C");\n        } else {\n            System.out.println("Grade: F");\n        }\n    }\n}',
            'testCases': ['Grade: B']
          },
          {
            'title': 'Switch Statement',
            'description': 'Use switch statement for multiple choices',
            'starterCode': 'public class SwitchExample {\n    public static void main(String[] args) {\n        int day = 3;\n        \n        // Use switch statement\n        \n    }\n}',
            'hint': 'Use switch with cases for different day values',
            'solution': 'public class SwitchExample {\n    public static void main(String[] args) {\n        int day = 3;\n        \n        switch (day) {\n            case 1:\n                System.out.println("Monday");\n                break;\n            case 2:\n                System.out.println("Tuesday");\n                break;\n            case 3:\n                System.out.println("Wednesday");\n                break;\n            default:\n                System.out.println("Invalid day");\n        }\n    }\n}',
            'testCases': ['Wednesday']
          },
          {
            'title': 'Ternary Operator',
            'description': 'Use ternary operator for simple conditions',
            'starterCode': 'public class Ternary {\n    public static void main(String[] args) {\n        int score = 85;\n        \n        // Use ternary operator\n        \n    }\n}',
            'hint': 'Use condition ? value1 : value2 syntax',
            'solution': 'public class Ternary {\n    public static void main(String[] args) {\n        int score = 85;\n        \n        String result = (score >= 60) ? "Pass" : "Fail";\n        System.out.println("Result: " + result);\n        \n        int max = (score > 80) ? score : 80;\n        System.out.println("Max score: " + max);\n    }\n}',
            'testCases': ['Result: Pass', 'Max score: 85']
          },
        ];
        break;

      case 'Java Loops':
        _exercises = [
          {
            'title': 'For Loop',
            'description': 'Use for loop to repeat actions',
            'starterCode': 'public class ForLoop {\n    public static void main(String[] args) {\n        // Print numbers from 1 to 5 using for loop\n        \n    }\n}',
            'hint': 'Use for (initialization; condition; increment) { code }',
            'solution': 'public class ForLoop {\n    public static void main(String[] args) {\n        for (int i = 1; i <= 5; i++) {\n            System.out.println(i);\n        }\n    }\n}',
            'testCases': ['1', '2', '3', '4', '5']
          },
          {
            'title': 'While Loop',
            'description': 'Use while loop for conditional repetition',
            'starterCode': 'public class WhileLoop {\n    public static void main(String[] args) {\n        int count = 1;\n        \n        // Print numbers from 1 to 3 using while loop\n        \n    }\n}',
            'hint': 'Use while (condition) { code } and update the condition variable',
            'solution': 'public class WhileLoop {\n    public static void main(String[] args) {\n        int count = 1;\n        \n        while (count <= 3) {\n            System.out.println(count);\n            count++;\n        }\n    }\n}',
            'testCases': ['1', '2', '3']
          },
          {
            'title': 'Break and Continue',
            'description': 'Use break and continue in loops',
            'starterCode': 'public class BreakContinue {\n    public static void main(String[] args) {\n        // Use break and continue\n        \n    }\n}',
            'hint': 'Use break to exit loop, continue to skip current iteration',
            'solution': 'public class BreakContinue {\n    public static void main(String[] args) {\n        for (int i = 1; i <= 5; i++) {\n            if (i == 3) continue;\n            if (i == 5) break;\n            System.out.print(i + " ");\n        }\n        System.out.println();\n    }\n}',
            'testCases': ['1 2 4']
          },
        ];
        break;

      case 'Java Arrays':
        _exercises = [
          {
            'title': 'Single-dimensional Array',
            'description': 'Create and use a single-dimensional array',
            'starterCode': 'public class SingleArray {\n    public static void main(String[] args) {\n        // Create and display array\n        \n    }\n}',
            'hint': 'Declare array with type[] name and use for loop to display',
            'solution': 'public class SingleArray {\n    public static void main(String[] args) {\n        int[] numbers = {1, 2, 3, 4, 5};\n        \n        System.out.println("Array elements:");\n        for (int i = 0; i < numbers.length; i++) {\n            System.out.println("Index " + i + ": " + numbers[i]);\n        }\n        \n        // Enhanced for loop\n        System.out.println("Using enhanced for loop:");\n        for (int number : numbers) {\n            System.out.print(number + " ");\n        }\n    }\n}',
            'testCases': ['Array elements:', 'Index 0: 1', 'Index 1: 2', 'Index 2: 3', 'Index 3: 4', 'Index 4: 5', 'Using enhanced for loop:', '1 2 3 4 5']
          },
          {
            'title': 'Multi-dimensional Array',
            'description': 'Work with 2D arrays',
            'starterCode': 'public class MultiArray {\n    public static void main(String[] args) {\n        // Create and display 2D array\n        \n    }\n}',
            'hint': 'Use nested loops for 2D arrays',
            'solution': 'public class MultiArray {\n    public static void main(String[] args) {\n        int[][] matrix = {\n            {1, 2, 3},\n            {4, 5, 6},\n            {7, 8, 9}\n        };\n        \n        System.out.println("2D Array:");\n        for (int i = 0; i < matrix.length; i++) {\n            for (int j = 0; j < matrix[i].length; j++) {\n                System.out.print(matrix[i][j] + " ");\n            }\n            System.out.println();\n        }\n    }\n}',
            'testCases': ['2D Array:', '1 2 3', '4 5 6', '7 8 9']
          },
          {
            'title': 'Array Operations',
            'description': 'Perform operations on arrays',
            'starterCode': 'public class ArrayOperations {\n    public static void main(String[] args) {\n        int[] numbers = {5, 2, 8, 1, 9};\n        \n        // Perform array operations\n        \n    }\n}',
            'hint': 'Find sum, average, max, and min of array elements',
            'solution': 'public class ArrayOperations {\n    public static void main(String[] args) {\n        int[] numbers = {5, 2, 8, 1, 9};\n        \n        int sum = 0;\n        int max = numbers[0];\n        int min = numbers[0];\n        \n        for (int number : numbers) {\n            sum += number;\n            if (number > max) max = number;\n            if (number < min) min = number;\n        }\n        \n        double average = (double) sum / numbers.length;\n        \n        System.out.println("Sum: " + sum);\n        System.out.println("Average: " + average);\n        System.out.println("Maximum: " + max);\n        System.out.println("Minimum: " + min);\n    }\n}',
            'testCases': ['Sum: 25', 'Average: 5.0', 'Maximum: 9', 'Minimum: 1']
          },
        ];
        break;

      case 'Java Methods':
        _exercises = [
          {
            'title': 'Basic Methods',
            'description': 'Create and call basic methods',
            'starterCode': 'public class BasicMethods {\n    public static void main(String[] args) {\n        // Call methods\n        \n    }\n    \n    // Create methods here\n}',
            'hint': 'Create methods for greeting and addition',
            'solution': 'public class BasicMethods {\n    public static void main(String[] args) {\n        greet();\n        int sum = add(5, 3);\n        System.out.println("Sum: " + sum);\n    }\n    \n    static void greet() {\n        System.out.println("Hello from method!");\n    }\n    \n    static int add(int a, int b) {\n        return a + b;\n    }\n}',
            'testCases': ['Hello from method!', 'Sum: 8']
          },
          {
            'title': 'Method Overloading',
            'description': 'Create overloaded methods',
            'starterCode': 'public class MethodOverloading {\n    public static void main(String[] args) {\n        // Use overloaded methods\n        \n    }\n    \n    // Create overloaded methods\n}',
            'hint': 'Create multiple add methods with different parameters',
            'solution': 'public class MethodOverloading {\n    public static void main(String[] args) {\n        System.out.println("Add two integers: " + add(5, 3));\n        System.out.println("Add three integers: " + add(1, 2, 3));\n        System.out.println("Add two doubles: " + add(2.5, 3.7));\n    }\n    \n    static int add(int a, int b) {\n        return a + b;\n    }\n    \n    static int add(int a, int b, int c) {\n        return a + b + c;\n    }\n    \n    static double add(double a, double b) {\n        return a + b;\n    }\n}',
            'testCases': ['Add two integers: 8', 'Add three integers: 6', 'Add two doubles: 6.2']
          },
          {
            'title': 'Recursive Method',
            'description': 'Create a recursive method',
            'starterCode': 'public class RecursiveMethod {\n    public static void main(String[] args) {\n        // Call recursive method\n        \n    }\n    \n    // Create recursive method\n}',
            'hint': 'Create factorial method that calls itself',
            'solution': 'public class RecursiveMethod {\n    public static void main(String[] args) {\n        int fact = factorial(5);\n        System.out.println("Factorial of 5: " + fact);\n    }\n    \n    static int factorial(int n) {\n        if (n == 0 || n == 1) {\n            return 1;\n        }\n        return n * factorial(n - 1);\n    }\n}',
            'testCases': ['Factorial of 5: 120']
          },
        ];
        break;

      case 'Java OOP':
        _exercises = [
          {
            'title': 'Basic Class and Object',
            'description': 'Create a simple class and instantiate objects',
            'starterCode': '// Create a Car class\n\npublic class OOPExample {\n    public static void main(String[] args) {\n        // Create Car objects\n        \n    }\n}',
            'hint': 'Create Car class with attributes and methods, then create objects',
            'solution': 'class Car {\n    String brand;\n    String model;\n    int year;\n    \n    void displayInfo() {\n        System.out.println(brand + " " + model + " " + year);\n    }\n}\n\npublic class OOPExample {\n    public static void main(String[] args) {\n        Car car1 = new Car();\n        car1.brand = "Toyota";\n        car1.model = "Corolla";\n        car1.year = 2020;\n        car1.displayInfo();\n        \n        Car car2 = new Car();\n        car2.brand = "Honda";\n        car2.model = "Civic";\n        car2.year = 2022;\n        car2.displayInfo();\n    }\n}',
            'testCases': ['Toyota Corolla 2020', 'Honda Civic 2022']
          },
          {
            'title': 'Constructor',
            'description': 'Use constructor to initialize objects',
            'starterCode': '// Create a Student class with constructor\n\npublic class ConstructorExample {\n    public static void main(String[] args) {\n        // Create Student objects using constructor\n        \n    }\n}',
            'hint': 'Add constructor to Student class',
            'solution': 'class Student {\n    String name;\n    int age;\n    \n    // Constructor\n    Student(String n, int a) {\n        name = n;\n        age = a;\n    }\n    \n    void display() {\n        System.out.println("Name: " + name + ", Age: " + age);\n    }\n}\n\npublic class ConstructorExample {\n    public static void main(String[] args) {\n        Student student1 = new Student("Alice", 20);\n        Student student2 = new Student("Bob", 22);\n        \n        student1.display();\n        student2.display();\n    }\n}',
            'testCases': ['Name: Alice, Age: 20', 'Name: Bob, Age: 22']
          },
          {
            'title': 'Getter and Setter Methods',
            'description': 'Use getter and setter methods for encapsulation',
            'starterCode': '// Create a BankAccount class with private fields\n\npublic class EncapsulationExample {\n    public static void main(String[] args) {\n        // Use getter and setter methods\n        \n    }\n}',
            'hint': 'Create private fields and public getter/setter methods',
            'solution': 'class BankAccount {\n    private String accountNumber;\n    private double balance;\n    \n    // Getter methods\n    public String getAccountNumber() {\n        return accountNumber;\n    }\n    \n    public double getBalance() {\n        return balance;\n    }\n    \n    // Setter methods\n    public void setAccountNumber(String accNum) {\n        accountNumber = accNum;\n    }\n    \n    public void setBalance(double bal) {\n        balance = bal;\n    }\n}\n\npublic class EncapsulationExample {\n    public static void main(String[] args) {\n        BankAccount account = new BankAccount();\n        account.setAccountNumber("123456");\n        account.setBalance(1000.0);\n        \n        System.out.println("Account: " + account.getAccountNumber());\n        System.out.println("Balance: " + account.getBalance());\n    }\n}',
            'testCases': ['Account: 123456', 'Balance: 1000.0']
          },
        ];
        break;

      case 'Java Exception Handling':
        _exercises = [
          {
            'title': 'Basic Exception Handling',
            'description': 'Use try-catch blocks to handle exceptions',
            'starterCode': 'public class ExceptionBasic {\n    public static void main(String[] args) {\n        // Use try-catch for exception handling\n        \n    }\n}',
            'hint': 'Use try, catch, and throw keywords',
            'solution': 'public class ExceptionBasic {\n    public static void main(String[] args) {\n        try {\n            int age = 15;\n            if (age < 18) {\n                throw new Exception("Age must be 18 or older");\n            }\n            System.out.println("Access granted");\n        }\n        catch (Exception e) {\n            System.out.println("Error: " + e.getMessage());\n        }\n    }\n}',
            'testCases': ['Error: Age must be 18 or older']
          },
          {
            'title': 'Multiple Catch Blocks',
            'description': 'Handle different types of exceptions',
            'starterCode': 'public class MultipleCatch {\n    public static void main(String[] args) {\n        // Handle different exception types\n        \n    }\n}',
            'hint': 'Use multiple catch blocks for different exception types',
            'solution': 'public class MultipleCatch {\n    public static void main(String[] args) {\n        try {\n            int[] numbers = {1, 2, 3};\n            System.out.println(numbers[5]); // ArrayIndexOutOfBoundsException\n            \n            int result = 10 / 0; // ArithmeticException\n        }\n        catch (ArrayIndexOutOfBoundsException e) {\n            System.out.println("Array index error: " + e.getMessage());\n        }\n        catch (ArithmeticException e) {\n            System.out.println("Arithmetic error: " + e.getMessage());\n        }\n        catch (Exception e) {\n            System.out.println("General error: " + e.getMessage());\n        }\n    }\n}',
            'testCases': ['Array index error: Index 5 out of bounds for length 3']
          },
          {
            'title': 'Finally Block',
            'description': 'Use finally block for cleanup code',
            'starterCode': 'public class FinallyExample {\n    public static void main(String[] args) {\n        // Use finally block\n        \n    }\n}',
            'hint': 'Use finally block that always executes',
            'solution': 'public class FinallyExample {\n    public static void main(String[] args) {\n        try {\n            int result = 10 / 2;\n            System.out.println("Result: " + result);\n        }\n        catch (ArithmeticException e) {\n            System.out.println("Cannot divide by zero");\n        }\n        finally {\n            System.out.println("This always executes");\n        }\n        \n        System.out.println("Program continues...");\n    }\n}',
            'testCases': ['Result: 5', 'This always executes', 'Program continues...']
          },
        ];
        break;

      case 'Java Collections':
        _exercises = [
          {
            'title': 'ArrayList Basics',
            'description': 'Work with ArrayList collection',
            'starterCode': 'import java.util.ArrayList;\n\npublic class ArrayListExample {\n    public static void main(String[] args) {\n        // Work with ArrayList\n        \n    }\n}',
            'hint': 'Create ArrayList, add elements, and iterate through them',
            'solution': 'import java.util.ArrayList;\n\npublic class ArrayListExample {\n    public static void main(String[] args) {\n        ArrayList<String> fruits = new ArrayList<>();\n        \n        // Add elements\n        fruits.add("Apple");\n        fruits.add("Banana");\n        fruits.add("Orange");\n        \n        // Display elements\n        System.out.println("Fruits: " + fruits);\n        \n        // Access elements\n        System.out.println("First fruit: " + fruits.get(0));\n        \n        // Remove element\n        fruits.remove("Banana");\n        System.out.println("After removal: " + fruits);\n    }\n}',
            'testCases': ['Fruits: [Apple, Banana, Orange]', 'First fruit: Apple', 'After removal: [Apple, Orange]']
          },
          {
            'title': 'HashMap Basics',
            'description': 'Work with HashMap collection',
            'starterCode': 'import java.util.HashMap;\n\npublic class HashMapExample {\n    public static void main(String[] args) {\n        // Work with HashMap\n        \n    }\n}',
            'hint': 'Create HashMap with key-value pairs',
            'solution': 'import java.util.HashMap;\n\npublic class HashMapExample {\n    public static void main(String[] args) {\n        HashMap<String, Integer> studentGrades = new HashMap<>();\n        \n        // Add key-value pairs\n        studentGrades.put("Alice", 85);\n        studentGrades.put("Bob", 92);\n        studentGrades.put("Charlie", 78);\n        \n        // Display map\n        System.out.println("Student Grades: " + studentGrades);\n        \n        // Access values\n        System.out.println("Alice grade: " + studentGrades.get("Alice"));\n        \n        // Check if key exists\n        System.out.println("Contains David: " + studentGrades.containsKey("David"));\n    }\n}',
            'testCases': ['Student Grades: {Alice=85, Charlie=78, Bob=92}', 'Alice grade: 85', 'Contains David: false']
          },
          {
            'title': 'LinkedList Operations',
            'description': 'Work with LinkedList collection',
            'starterCode': 'import java.util.LinkedList;\n\npublic class LinkedListExample {\n    public static void main(String[] args) {\n        // Work with LinkedList\n        \n    }\n}',
            'hint': 'Create LinkedList and perform various operations',
            'solution': 'import java.util.LinkedList;\n\npublic class LinkedListExample {\n    public static void main(String[] args) {\n        LinkedList<Integer> numbers = new LinkedList<>();\n        \n        // Add elements\n        numbers.add(10);\n        numbers.add(20);\n        numbers.addFirst(5);  // Add at beginning\n        numbers.addLast(30);  // Add at end\n        \n        System.out.println("LinkedList: " + numbers);\n        \n        // Remove elements\n        numbers.removeFirst();\n        System.out.println("After removing first: " + numbers);\n        \n        // Get elements\n        System.out.println("First element: " + numbers.getFirst());\n        System.out.println("Last element: " + numbers.getLast());\n    }\n}',
            'testCases': ['LinkedList: [5, 10, 20, 30]', 'After removing first: [10, 20, 30]', 'First element: 10', 'Last element: 30']
          },
        ];
        break;

      case 'Java File Handling':
        _exercises = [
          {
            'title': 'Write to File',
            'description': 'Create and write data to a text file',
            'starterCode': 'import java.io.FileWriter;\nimport java.io.IOException;\n\npublic class FileWrite {\n    public static void main(String[] args) {\n        // Write data to a file\n        \n    }\n}',
            'hint': 'Use FileWriter to create and write to file',
            'solution': 'import java.io.FileWriter;\nimport java.io.IOException;\n\npublic class FileWrite {\n    public static void main(String[] args) {\n        try {\n            FileWriter writer = new FileWriter("output.txt");\n            writer.write("Hello, this is line 1.\\n");\n            writer.write("This is line 2.\\n");\n            writer.write("Line 3 here.\\n");\n            writer.close();\n            System.out.println("File written successfully!");\n        } catch (IOException e) {\n            System.out.println("Error writing to file: " + e.getMessage());\n        }\n    }\n}',
            'testCases': ['File written successfully!']
          },
          {
            'title': 'Read from File',
            'description': 'Read and display content from a text file',
            'starterCode': 'import java.io.FileReader;\nimport java.io.BufferedReader;\nimport java.io.IOException;\n\npublic class FileRead {\n    public static void main(String[] args) {\n        // Read data from file\n        \n    }\n}',
            'hint': 'Use BufferedReader and FileReader to read from file',
            'solution': 'import java.io.FileReader;\nimport java.io.BufferedReader;\nimport java.io.IOException;\n\npublic class FileRead {\n    public static void main(String[] args) {\n        try {\n            BufferedReader reader = new BufferedReader(new FileReader("output.txt"));\n            String line;\n            System.out.println("File content:");\n            while ((line = reader.readLine()) != null) {\n                System.out.println(line);\n            }\n            reader.close();\n        } catch (IOException e) {\n            System.out.println("Error reading file: " + e.getMessage());\n        }\n    }\n}',
            'testCases': ['File content:', 'Hello, this is line 1.']
          },
          {
            'title': 'File Information',
            'description': 'Get information about a file',
            'starterCode': 'import java.io.File;\n\npublic class FileInfo {\n    public static void main(String[] args) {\n        // Get file information\n        \n    }\n}',
            'hint': 'Use File class to get file properties',
            'solution': 'import java.io.File;\n\npublic class FileInfo {\n    public static void main(String[] args) {\n        File file = new File("output.txt");\n        \n        if (file.exists()) {\n            System.out.println("File name: " + file.getName());\n            System.out.println("Absolute path: " + file.getAbsolutePath());\n            System.out.println("Writable: " + file.canWrite());\n            System.out.println("Readable: " + file.canRead());\n            System.out.println("File size in bytes: " + file.length());\n        } else {\n            System.out.println("File does not exist.");\n        }\n    }\n}',
            'testCases': ['File name: output.txt', 'Writable: true', 'Readable: true']
          },
        ];
        break;

      case 'Java Multithreading':
        _exercises = [
          {
            'title': 'Thread Creation - Extending Thread',
            'description': 'Create thread by extending Thread class',
            'starterCode': '// Create a thread by extending Thread class\n\npublic class ThreadExample {\n    public static void main(String[] args) {\n        // Create and start threads\n        \n    }\n}',
            'hint': 'Create class that extends Thread and override run() method',
            'solution': 'class MyThread extends Thread {\n    private String threadName;\n    \n    MyThread(String name) {\n        threadName = name;\n    }\n    \n    public void run() {\n        for (int i = 1; i <= 3; i++) {\n            System.out.println(threadName + " - Count: " + i);\n            try {\n                Thread.sleep(1000);\n            } catch (InterruptedException e) {\n                System.out.println("Thread interrupted");\n            }\n        }\n    }\n}\n\npublic class ThreadExample {\n    public static void main(String[] args) {\n        MyThread thread1 = new MyThread("Thread 1");\n        MyThread thread2 = new MyThread("Thread 2");\n        \n        thread1.start();\n        thread2.start();\n    }\n}',
            'testCases': ['Thread 1 - Count: 1', 'Thread 2 - Count: 1', 'Thread 1 - Count: 2', 'Thread 2 - Count: 2']
          },
          {
            'title': 'Thread Creation - Implementing Runnable',
            'description': 'Create thread by implementing Runnable interface',
            'starterCode': '// Create a thread by implementing Runnable interface\n\npublic class RunnableExample {\n    public static void main(String[] args) {\n        // Create and start threads\n        \n    }\n}',
            'hint': 'Create class that implements Runnable and pass to Thread constructor',
            'solution': 'class MyRunnable implements Runnable {\n    private String threadName;\n    \n    MyRunnable(String name) {\n        threadName = name;\n    }\n    \n    public void run() {\n        for (int i = 1; i <= 3; i++) {\n            System.out.println(threadName + " - Number: " + i);\n            try {\n                Thread.sleep(500);\n            } catch (InterruptedException e) {\n                System.out.println("Thread interrupted");\n            }\n        }\n    }\n}\n\npublic class RunnableExample {\n    public static void main(String[] args) {\n        Thread thread1 = new Thread(new MyRunnable("Runnable 1"));\n        Thread thread2 = new Thread(new MyRunnable("Runnable 2"));\n        \n        thread1.start();\n        thread2.start();\n    }\n}',
            'testCases': ['Runnable 1 - Number: 1', 'Runnable 2 - Number: 1', 'Runnable 1 - Number: 2', 'Runnable 2 - Number: 2']
          },
          {
            'title': 'Thread Synchronization',
            'description': 'Use synchronized keyword for thread safety',
            'starterCode': '// Create a shared counter with synchronization\n\npublic class SynchronizedExample {\n    public static void main(String[] args) {\n        // Create multiple threads accessing shared resource\n        \n    }\n}',
            'hint': 'Use synchronized method to protect shared resource',
            'solution': 'class Counter {\n    private int count = 0;\n    \n    public synchronized void increment() {\n        count++;\n    }\n    \n    public int getCount() {\n        return count;\n    }\n}\n\nclass CounterThread extends Thread {\n    private Counter counter;\n    \n    CounterThread(Counter c) {\n        counter = c;\n    }\n    \n    public void run() {\n        for (int i = 0; i < 1000; i++) {\n            counter.increment();\n        }\n    }\n}\n\npublic class SynchronizedExample {\n    public static void main(String[] args) throws InterruptedException {\n        Counter counter = new Counter();\n        \n        CounterThread thread1 = new CounterThread(counter);\n        CounterThread thread2 = new CounterThread(counter);\n        \n        thread1.start();\n        thread2.start();\n        \n        thread1.join();\n        thread2.join();\n        \n        System.out.println("Final count: " + counter.getCount());\n    }\n}',
            'testCases': ['Final count: 2000']
          },
        ];
        break;

      default:
        _exercises = [
          {
            'title': 'Basic Java Program',
            'description': 'Write a simple Java program',
            'starterCode': 'public class BasicJava {\n    public static void main(String[] args) {\n        // Write your code here\n        \n    }\n}',
            'hint': 'Start with System.out.println() to display output',
            'solution': 'public class BasicJava {\n    public static void main(String[] args) {\n        System.out.println("Welcome to Java Programming!");\n    }\n}',
            'testCases': ['Welcome to Java Programming!']
          },
        ];
    }
  }
  // I-CONTINUE mo yung ibang methods dito (same as C++ version)
  // _runCode, _checkForErrors, _simulateProgramExecution, etc.
  // Copy mo na lang yung mga methods from C++ version and adjust for Java syntax

  void _runCode() {
    setState(() {
      _isRunning = true;
      _output = '🚀 Compiling your Java code...\n\n';
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

  List<String> _checkForErrors(String code) {
    List<String> errors = [];

    // Check for class declaration
    if (!code.contains('public class')) {
      errors.add('Missing class declaration: public class ClassName');
    }

    // Check for main method
    if (!code.contains('public static void main(String[] args)')) {
      errors.add('Missing main method: public static void main(String[] args)');
    }

    // Check for required imports
    if (code.contains('Scanner') && !code.contains('import java.util.Scanner')) {
      errors.add('Missing import statement: import java.util.Scanner;');
    }

    List<String> lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Check for semicolons
      if ((line.contains('System.out.println') || line.contains('System.out.print') ||
          line.contains('int ') || line.contains('String ') || line.contains('double ')) &&
          !line.endsWith(';') && !line.endsWith('{') && !line.endsWith('}') &&
          !line.startsWith('//') && line.isNotEmpty) {
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
      if (line.contains('int ') && line.contains('=') && !line.contains('System.out')) {
        RegExp intRegex = RegExp(r'int\s+(\w+)\s*=\s*(\d+)');
        Match? match = intRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = int.parse(match.group(2)!);
        }
      }
      else if (line.contains('double ') && line.contains('=') && !line.contains('System.out')) {
        RegExp doubleRegex = RegExp(r'double\s+(\w+)\s*=\s*([0-9.]+)');
        Match? match = doubleRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = double.parse(match.group(2)!);
        }
      }
      else if (line.contains('String ') && line.contains('=') && !line.contains('System.out')) {
        RegExp stringRegex = RegExp(r'String\s+(\w+)\s*=\s*"([^"]*)"');
        Match? match = stringRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = match.group(2)!;
        }
      }
      else if (line.contains('char ') && line.contains('=') && !line.contains('System.out')) {
        RegExp charRegex = RegExp(r"char\s+(\w+)\s*=\s*'([^'])'");
        Match? match = charRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = match.group(2)!;
        }
      }
      else if (line.contains('boolean ') && line.contains('=') && !line.contains('System.out')) {
        RegExp boolRegex = RegExp(r'boolean\s+(\w+)\s*=\s*(true|false)');
        Match? match = boolRegex.firstMatch(line);
        if (match != null) {
          variables[match.group(1)!] = match.group(2)! == 'true';
        }
      }

      // Output statements
      if (line.contains('System.out.println') || line.contains('System.out.print')) {
        String output = _processPrintStatement(line, variables);
        if (output.isNotEmpty) {
          outputLines.add(output);
        }
      }

      // Input simulation
      if (line.contains('Scanner') && line.contains('next')) {
        _processScannerStatement(line, variables);
      }

      // Arithmetic operations
      if (line.contains('=') && !line.contains('System.out') && !line.contains('Scanner')) {
        _processArithmetic(line, variables);
      }
    }

    return outputLines.join('\n');
  }

  String _processPrintStatement(String line, Map<String, dynamic> variables) {
    String output = '';

    if (line.contains('System.out.println')) {
      String content = line.substring(line.indexOf('(') + 1, line.lastIndexOf(')'));

      // Handle concatenation
      if (content.contains('+')) {
        List<String> parts = content.split('+');
        for (String part in parts) {
          part = part.trim().replaceAll('"', '');

          if (variables.containsKey(part)) {
            output += variables[part].toString();
          } else {
            output += part;
          }
        }
      } else {
        // Simple string output
        output = content.replaceAll('"', '');
      }
    }

    return output;
  }

  void _processScannerStatement(String line, Map<String, dynamic> variables) {
    if (line.contains('nextInt()')) {
      RegExp scannerRegex = RegExp(r'(\w+)\s*=\s*scanner\.nextInt\(\)');
      Match? match = scannerRegex.firstMatch(line);
      if (match != null) {
        variables[match.group(1)!] = 25; // Default age
      }
    }
    else if (line.contains('nextLine()')) {
      RegExp scannerRegex = RegExp(r'(\w+)\s*=\s*scanner\.nextLine\(\)');
      Match? match = scannerRegex.firstMatch(line);
      if (match != null) {
        variables[match.group(1)!] = 'John'; // Default name
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