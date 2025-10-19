import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'cpp_practice_screen.dart';

class CppLearningScreen extends StatefulWidget {
  final String moduleTitle;
  final String fileName;
  final Color primaryColor;

  const CppLearningScreen({
    Key? key,
    required this.moduleTitle,
    required this.fileName,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<CppLearningScreen> createState() => _CppLearningScreenState();
}

class _CppLearningScreenState extends State<CppLearningScreen> {
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
      case 'C++ Introduction':
        return '''
# C++ Introduction

C++ is a powerful general-purpose programming language created by Bjarne Stroustrup as an extension of the C programming language.

## What is C++?

C++ is a cross-platform language that can be used to create high-performance applications. It gives programmers a high level of control over system resources and memory.

## Key Features:

- **Object-Oriented**: Supports classes and objects
- **Portable**: Can be used to develop applications that can be adapted to multiple platforms
- **Mid-level**: Combines features of both high-level and low-level languages
- **Rich Library**: Has a rich set of library functions
- **Speed**: C++ programs tend to be very fast

## Why Learn C++?

- C++ is one of the world's most popular programming languages
- Used in operating systems, graphical user interfaces, and embedded systems
- Great for performance-critical applications
- Basis for understanding other programming languages
''';

      case 'C++ Syntax':
        return '''
# C++ Syntax

## Basic Structure
Every C++ program has a specific structure that must be followed. The most basic program includes headers, main function, and statements.

## Basic Syntax Example:
''';

      case 'C++ Data Types':
        return '''
# C++ Data Types

## Basic Data Types
C++ provides various data types to store different kinds of data:

- **int**: Integer numbers (e.g., 10, -5, 0)
- **float/double**: Floating-point numbers (e.g., 3.14, -2.5)
- **char**: Single character (e.g., 'A', 'b', '1')
- **bool**: Boolean values (true or false)
- **string**: Sequence of characters

## Type Modifiers:
- **signed**: Can hold both positive and negative values
- **unsigned**: Can hold only positive values
- **short**: Smaller range of values
- **long**: Larger range of values
''';

      case 'C++ Operators':
        return '''
# C++ Operators

## Types of Operators:

### Arithmetic Operators
Used for mathematical operations:
- `+` Addition
- `-` Subtraction
- `*` Multiplication
- `/` Division
- `%` Modulus (remainder)

### Relational Operators
Used for comparisons:
- `==` Equal to
- `!=` Not equal to
- `>` Greater than
- `<` Less than
- `>=` Greater than or equal to
- `<=` Less than or equal to

### Logical Operators
Used for logical operations:
- `&&` Logical AND
- `||` Logical OR
- `!` Logical NOT
''';

      case 'C++ Conditions':
        return '''
# C++ Conditions

## Conditional Statements
Conditional statements allow your program to make decisions based on certain conditions.

### if Statement
Executes a block of code if a specified condition is true.

### if-else Statement
Executes one block if condition is true, another if false.

### else-if Statement
Tests multiple conditions.

### switch Statement
Selects one of many code blocks to execute.
''';

      case 'C++ Loops':
        return '''
# C++ Loops

## Types of Loops

### for Loop
Used when you know exactly how many times you want to loop.

### while Loop
Repeats a block of code while a condition is true.

### do-while Loop
Similar to while loop, but executes at least once.

## Loop Control Statements:
- **break**: Exits the loop immediately
- **continue**: Skips the current iteration
- **goto**: Jumps to a labeled statement
''';

      case 'C++ Arrays':
        return '''
# C++ Arrays

## What are Arrays?
Arrays are used to store multiple values of the same type in a single variable.

## Array Characteristics:
- Fixed size
- Contiguous memory locations
- Index starts from 0
- Can be single or multi-dimensional

## Types of Arrays:
- **One-dimensional arrays**
- **Multi-dimensional arrays** (2D, 3D, etc.)
- **Character arrays** (C-style strings)
''';

      case 'C++ Functions':
        return '''
# C++ Functions

## What are Functions?
Functions are blocks of code that perform specific tasks. They help in organizing code and making it reusable.

## Function Components:
- **Return type**: Data type of the value returned
- **Function name**: Identifier for the function
- **Parameters**: Input values to the function
- **Function body**: Code that defines what the function does

## Types of Functions:
- **Built-in functions** (from standard library)
- **User-defined functions** (created by programmer)
- **Recursive functions** (functions that call themselves)
''';

      case 'C++ Pointers':
        return '''
# C++ Pointers

## What are Pointers?
Pointers are variables that store memory addresses rather than actual values.

## Pointer Concepts:
- **Address operator** (`&`): Gets the address of a variable
- **Dereference operator** (`*`): Accesses the value at a pointer's address
- **Pointer arithmetic**: Performing operations on pointer addresses

## Uses of Pointers:
- Dynamic memory allocation
- Array manipulation
- Function arguments (pass by reference)
- Data structures (linked lists, trees, etc.)
''';

      case 'C++ Strings':
        return '''
# C++ Strings

## String Types in C++

### C-style Strings
Character arrays terminated with null character (`\\0`)

### C++ String Class
Part of the Standard Template Library (STL), provides more functionality and safety.

## String Operations:
- **Concatenation**: Combining strings
- **Comparison**: Comparing string values
- **Substring**: Extracting parts of strings
- **Searching**: Finding characters or substrings
- **Modification**: Changing string content
''';

      case 'C++ Math':
        return '''
# C++ Math

## Mathematical Operations
C++ provides various mathematical functions through the `<cmath>` header.

## Common Math Functions:
- **Basic operations**: +, -, *, /
- **Power functions**: pow(), sqrt()
- **Trigonometric**: sin(), cos(), tan()
- **Logarithmic**: log(), log10()
- **Rounding**: ceil(), floor(), round()
- **Absolute value**: abs(), fabs()

## Random Numbers:
- **rand()**: Generates random numbers
- **srand()**: Seeds the random number generator
''';

      case 'C++ Classes':
        return '''
# C++ Classes

## Object-Oriented Programming
Classes are the foundation of Object-Oriented Programming (OOP) in C++.

## Class Components:
- **Data members**: Variables that store data
- **Member functions**: Functions that operate on the data
- **Access specifiers**: public, private, protected
- **Constructors**: Special functions for object initialization
- **Destructors**: Special functions for cleanup

## OOP Principles:
- **Encapsulation**: Bundling data and methods
- **Inheritance**: Creating new classes from existing ones
- **Polymorphism**: Same interface, different implementations
''';

      case 'C++ Inheritance':
        return '''
# C++ Inheritance

## What is Inheritance?
Inheritance allows a class to inherit properties and behaviors from another class.

## Inheritance Types:
- **Single inheritance**: One base class, one derived class
- **Multiple inheritance**: Multiple base classes, one derived class
- **Multilevel inheritance**: Derived class becomes base for another
- **Hierarchical inheritance**: One base class, multiple derived classes
- **Hybrid inheritance**: Combination of multiple types

## Access Specifiers in Inheritance:
- **public inheritance**: Public members remain public
- **protected inheritance**: Public members become protected
- **private inheritance**: All members become private
''';

      case 'C++ Files Handling':
        return '''
# C++ Files Handling

## File Operations
C++ provides file handling through the `<fstream>` header.

## File Stream Classes:
- **ifstream**: Input file stream (reading)
- **ofstream**: Output file stream (writing)
- **fstream**: File stream (both reading and writing)

## File Operations:
- **Opening files**: Specifying file names and modes
- **Reading data**: Extracting data from files
- **Writing data**: Inserting data into files
- **Closing files**: Releasing file resources
- **Error handling**: Checking for file operation success
''';

      case 'C++ Exceptions Handling':
        return '''
# C++ Exceptions Handling

## What are Exceptions?
Exceptions are runtime errors or unexpected conditions that disrupt normal program flow.

## Exception Handling Mechanism:
- **try block**: Code that might throw exceptions
- **catch block**: Code that handles exceptions
- **throw statement**: Code that signals an exception

## Standard Exceptions:
- **runtime_error**: Runtime errors
- **logic_error**: Logic errors in program
- **invalid_argument**: Invalid arguments to functions
- **out_of_range**: Array index out of bounds

## Benefits:
- Separates error handling from main logic
- Makes code more readable and maintainable
- Prevents program crashes
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
        builder: (context) => CppPracticeScreen(
          moduleTitle: widget.moduleTitle,
          primaryColor: widget.primaryColor,
          language: 'C++', // Add this required parameter
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
                'C++ Example',
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
      case 'C++ Introduction':
        return '''
#include <iostream>
using namespace std;

int main() {
    cout << "Hello, World!" << endl;
    cout << "Welcome to C++ Programming!" << endl;
    return 0;
}
''';

      case 'C++ Syntax':
        return '''
#include <iostream>
using namespace std;

int main() {
    int number = 10;
    cout << "Number: " << number;
    return 0;
}
''';

      case 'C++ Data Types':
        return '''
#include <iostream>
#include <string>
using namespace std;

int main() {
    int number = 10;
    double decimal = 10.5;
    char letter = 'A';
    bool flag = true;
    string text = "Hello";
    
    cout << "Integer: " << number << endl;
    cout << "Double: " << decimal << endl;
    cout << "Character: " << letter << endl;
    cout << "Boolean: " << flag << endl;
    cout << "String: " << text << endl;
    
    return 0;
}
''';

      case 'C++ Operators':
        return '''
#include <iostream>
using namespace std;

int main() {
    int a = 10, b = 3;
    
    cout << "a + b = " << (a + b) << endl;
    cout << "a - b = " << (a - b) << endl;
    cout << "a * b = " << (a * b) << endl;
    cout << "a / b = " << (a / b) << endl;
    cout << "a % b = " << (a % b) << endl;
    
    cout << "a == b: " << (a == b) << endl;
    cout << "a != b: " << (a != b) << endl;
    cout << "a > b: " << (a > b) << endl;
    
    return 0;
}
''';

      case 'C++ Conditions':
        return '''
#include <iostream>
using namespace std;

int main() {
    int age = 18;

    if (age >= 18) {
        cout << "Adult";
    } else if (age >= 13) {
        cout << "Teenager";
    } else {
        cout << "Child";
    }
    
    return 0;
}
''';

      case 'C++ Loops':
        return '''
#include <iostream>
using namespace std;

int main() {
    // For loop
    for (int i = 0; i < 5; i++) {
        cout << i << endl;
    }
    
    // While loop
    int j = 0;
    while (j < 3) {
        cout << "While: " << j << endl;
        j++;
    }
    
    return 0;
}
''';

      case 'C++ Arrays':
        return '''
#include <iostream>
using namespace std;

int main() {
    int numbers[5] = {1, 2, 3, 4, 5};
    string names[3] = {"John", "Jane", "Doe"};
    int matrix[2][3] = {{1,2,3}, {4,5,6}};
    
    // Accessing array elements
    for (int i = 0; i < 5; i++) {
        cout << numbers[i] << " ";
    }
    cout << endl;
    
    return 0;
}
''';

      case 'C++ Functions':
        return '''
#include <iostream>
using namespace std;

// Function declaration
int add(int a, int b);
void greet(string name);

int main() {
    int result = add(5, 3);
    cout << "Sum: " << result << endl;
    
    greet("Alice");
    return 0;
}

// Function definition
int add(int a, int b) {
    return a + b;
}

void greet(string name) {
    cout << "Hello, " << name << endl;
}
''';

      case 'C++ Pointers':
        return '''
#include <iostream>
using namespace std;

int main() {
    int number = 10;
    int* ptr = &number;

    cout << "Value: " << *ptr << endl;
    cout << "Address: " << ptr << endl;
    cout << "Address of number: " << &number << endl;
    
    // Modify value through pointer
    *ptr = 20;
    cout << "New value: " << number << endl;
    
    return 0;
}
''';

      case 'C++ Strings':
        return '''
#include <iostream>
#include <string>
using namespace std;

int main() {
    string greeting = "Hello";
    string name("John");
    string fullName = greeting + " " + name;
    
    cout << greeting << endl;
    cout << name << endl;
    cout << fullName << endl;
    cout << "Length: " << fullName.length() << endl;
    
    return 0;
}
''';

      case 'C++ Math':
        return '''
#include <iostream>
#include <cmath>
using namespace std;

int main() {
    cout << "Square root of 25: " << sqrt(25) << endl;
    cout << "2 to the power of 3: " << pow(2, 3) << endl;
    cout << "Absolute value of -10: " << abs(-10) << endl;
    cout << "Ceiling of 4.2: " << ceil(4.2) << endl;
    cout << "Floor of 4.7: " << floor(4.7) << endl;
    
    return 0;
}
''';

      case 'C++ Classes':
        return '''
#include <iostream>
#include <string>
using namespace std;

class Person {
private:
    string name;
    int age;
    
public:
    Person(string n, int a) : name(n), age(a) {}
    
    void display() {
        cout << "Name: " << name << ", Age: " << age << endl;
    }
};

int main() {
    Person person1("John", 25);
    person1.display();
    
    return 0;
}
''';

      case 'C++ Inheritance':
        return '''
#include <iostream>
using namespace std;

class Animal {
public:
    void eat() { 
        cout << "Eating..." << endl; 
    }
};

class Dog : public Animal {
public:
    void bark() { 
        cout << "Barking..." << endl; 
    }
};

int main() {
    Dog dog;
    dog.eat();   // Inherited from Animal
    dog.bark();  // Own method
    
    return 0;
}
''';

      case 'C++ Files Handling':
        return '''
#include <iostream>
#include <fstream>
#include <string>
using namespace std;

int main() {
    // Writing to a file
    ofstream outFile("example.txt");
    outFile << "Hello, File Handling!" << endl;
    outFile << "This is a C++ tutorial." << endl;
    outFile.close();
    
    // Reading from a file
    ifstream inFile("example.txt");
    string line;
    
    while (getline(inFile, line)) {
        cout << line << endl;
    }
    inFile.close();
    
    return 0;
}
''';

      case 'C++ Exceptions Handling':
        return '''
#include <iostream>
#include <stdexcept>
using namespace std;

int main() {
    int x = 0;
    
    try {
        if (x == 0) throw runtime_error("Division by zero");
        int result = 10 / x;
        cout << "Result: " << result << endl;
    } catch (const exception& e) {
        cout << "Error: " << e.what() << endl;
    }
    
    return 0;
}
''';

      default:
        return '''
#include <iostream>
using namespace std;

int main() {
    cout << "Welcome to C++ Programming!" << endl;
    cout << "This is a sample C++ program." << endl;
    return 0;
}
''';
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
              'Loading C++ Tutorial...',
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
                    'Learn C++ step by step with examples and explanations',
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
            _buildContentSection('C++ Tutorial Content', _content),

            // Example Section
            _buildCodeExample(
              _getExampleCode(widget.moduleTitle),
              'C++',
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
                        'C++ Practice Exercises',
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
                    'Test your C++ knowledge with interactive coding exercises:',
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
