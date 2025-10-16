import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'practice_screen.dart'; // MAKE SURE THIS IMPORT IS ADDED

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

  // ADD THIS METHOD FOR PRACTICE NAVIGATION
  void _startPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeScreen(
          moduleTitle: widget.moduleTitle,
          primaryColor: widget.primaryColor,
          language: _getLanguageName(widget.fileName),
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
              // Pwede dagdagan ng features dito like code execution
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
            _buildContentSection('Introduction', _content),

            // Example Section
            _buildCodeExample(
              _getExampleCode(widget.moduleTitle, widget.fileName),
              _getLanguageName(widget.fileName),
            ),

            // UPDATED Practice Section - FIXED ICON
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
                      // FIXED: Changed Icons.exercise to Icons.fitness_center
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
                          // Additional practice features
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

  // ADDITIONAL METHOD FOR QUIZ DIALOG
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
    // Java-specific examples
    if (fileName.contains('java')) {
      return _getJavaExampleCode(moduleTitle);
    }

    // C++ examples
    if (fileName.contains('cpp')) {
      return _getCppExampleCode(moduleTitle);
    }

    // Default examples
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

  String _getJavaExampleCode(String moduleTitle) {
    // ... (same Java code as previous response)
    // Keeping it short here to avoid repetition
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
    // ... rest of Java examples
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
    cout << "Welcome to C++ Programming!" << endl;
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Syntax')) {
      return '''
// C++ Syntax Example
#include <iostream>
#include <string>
using namespace std;

int main() {
    // Variable declaration
    int number = 10;
    double price = 19.99;
    char grade = 'A';
    bool isCppFun = true;
    string message = "Hello C++";
    
    // Output
    cout << "Number: " << number << endl;
    cout << "Price: " << price << endl;
    cout << "Grade: " << grade << endl;
    cout << "Is C++ Fun? " << isCppFun << endl;
    cout << "Message: " << message << endl;
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Data Types')) {
      return '''
// C++ Data Types Example
#include <iostream>
using namespace std;

int main() {
    // Basic data types
    int integerVar = 100;
    float floatVar = 3.14f;
    double doubleVar = 3.14159265359;
    char charVar = 'C';
    bool boolVar = true;
    
    // Type modifiers
    short shortVar = 32767;
    long longVar = 2147483647L;
    unsigned int unsignedVar = 4000000000;
    
    cout << "Integer: " << integerVar << endl;
    cout << "Float: " << floatVar << endl;
    cout << "Double: " << doubleVar << endl;
    cout << "Character: " << charVar << endl;
    cout << "Boolean: " << boolVar << endl;
    cout << "Short: " << shortVar << endl;
    cout << "Long: " << longVar << endl;
    cout << "Unsigned: " << unsignedVar << endl;
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Operators')) {
      return '''
// C++ Operators Example
#include <iostream>
using namespace std;

int main() {
    int a = 15, b = 4;
    
    // Arithmetic operators
    cout << "a + b = " << (a + b) << endl;
    cout << "a - b = " << (a - b) << endl;
    cout << "a * b = " << (a * b) << endl;
    cout << "a / b = " << (a / b) << endl;
    cout << "a % b = " << (a % b) << endl;
    
    // Comparison operators
    cout << "a == b: " << (a == b) << endl;
    cout << "a != b: " << (a != b) << endl;
    cout << "a > b: " << (a > b) << endl;
    cout << "a < b: " << (a < b) << endl;
    
    // Logical operators
    bool x = true, y = false;
    cout << "x && y: " << (x && y) << endl;
    cout << "x || y: " << (x || y) << endl;
    cout << "!x: " << (!x) << endl;
    
    // Assignment operators
    int c = 10;
    c += 5;  // c = c + 5
    cout << "c after += 5: " << c << endl;
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Strings')) {
      return '''
// C++ Strings Example
#include <iostream>
#include <string>
using namespace std;

int main() {
    string greeting = "Hello";
    string name = "World";
    
    // String concatenation
    string message = greeting + " " + name + "!";
    cout << message << endl;
    
    // String methods
    cout << "Length: " << message.length() << endl;
    cout << "First character: " << message[0] << endl;
    cout << "Substring: " << message.substr(0, 5) << endl;
    
    // String comparison
    string str1 = "C++";
    string str2 = "C++";
    cout << "Strings equal: " << (str1 == str2) << endl;
    
    // String input
    string userInput;
    cout << "Enter your name: ";
    getline(cin, userInput);
    cout << "Hello, " << userInput << "!" << endl;
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Math')) {
      return '''
// C++ Math Example
#include <iostream>
#include <cmath>
using namespace std;

int main() {
    double number = 16.0;
    double base = 2.0, exponent = 3.0;
    
    // Basic math operations
    cout << "Square root of " << number << " = " << sqrt(number) << endl;
    cout << base << "^" << exponent << " = " << pow(base, exponent) << endl;
    cout << "Absolute value of -5 = " << abs(-5) << endl;
    cout << "Round 3.7 = " << round(3.7) << endl;
    cout << "Ceil 3.2 = " << ceil(3.2) << endl;
    cout << "Floor 3.8 = " << floor(3.8) << endl;
    
    // Trigonometric functions
    double angle = 45.0;
    double radians = angle * M_PI / 180.0;
    cout << "sin(" << angle << "°) = " << sin(radians) << endl;
    cout << "cos(" << angle << "°) = " << cos(radians) << endl;
    cout << "tan(" << angle << "°) = " << tan(radians) << endl;
    
    // Max and min
    cout << "Max of 10 and 20: " << max(10, 20) << endl;
    cout << "Min of 10 and 20: " << min(10, 20) << endl;
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Conditions')) {
      return '''
// C++ Conditions Example
#include <iostream>
using namespace std;

int main() {
    int score = 85;
    
    // If-else statement
    if (score >= 90) {
        cout << "Grade: A" << endl;
    } else if (score >= 80) {
        cout << "Grade: B" << endl;
    } else if (score >= 70) {
        cout << "Grade: C" << endl;
    } else {
        cout << "Grade: F" << endl;
    }
    
    // Switch statement
    int day = 3;
    switch (day) {
        case 1:
            cout << "Monday" << endl;
            break;
        case 2:
            cout << "Tuesday" << endl;
            break;
        case 3:
            cout << "Wednesday" << endl;
            break;
        default:
            cout << "Invalid day" << endl;
    }
    
    // Ternary operator
    string result = (score >= 60) ? "Pass" : "Fail";
    cout << "Result: " << result << endl;
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Loops')) {
      return '''
// C++ Loops Example
#include <iostream>
using namespace std;

int main() {
    // For loop
    cout << "For loop:" << endl;
    for (int i = 1; i <= 5; i++) {
        cout << "Count: " << i << endl;
    }
    
    // While loop
    cout << "\\nWhile loop:" << endl;
    int j = 1;
    while (j <= 3) {
        cout << "While count: " << j << endl;
        j++;
    }
    
    // Do-while loop
    cout << "\\nDo-while loop:" << endl;
    int k = 1;
    do {
        cout << "Do-while count: " << k << endl;
        k++;
    } while (k <= 3);
    
    // Break and continue
    cout << "\\nBreak example:" << endl;
    for (int i = 1; i <= 10; i++) {
        if (i == 5) break;
        cout << i << " ";
    }
    
    cout << "\\nContinue example:" << endl;
    for (int i = 1; i <= 5; i++) {
        if (i == 3) continue;
        cout << i << " ";
    }
    cout << endl;
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Arrays')) {
      return '''
// C++ Arrays Example
#include <iostream>
using namespace std;

int main() {
    // Single-dimensional array
    int numbers[5] = {1, 2, 3, 4, 5};
    
    cout << "Array elements:" << endl;
    for (int i = 0; i < 5; i++) {
        cout << "Index " << i << ": " << numbers[i] << endl;
    }
    
    // Multi-dimensional array
    int matrix[2][3] = {
        {1, 2, 3},
        {4, 5, 6}
    };
    
    cout << "\\n2D Array:" << endl;
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 3; j++) {
            cout << matrix[i][j] << " ";
        }
        cout << endl;
    }
    
    // Array size
    int size = sizeof(numbers) / sizeof(numbers[0]);
    cout << "\\nArray size: " << size << endl;
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Functions')) {
      return '''
// C++ Functions Example
#include <iostream>
using namespace std;

// Function declaration
void greet();
int add(int a, int b);
double multiply(double a, double b);
int factorial(int n);

int main() {
    // Function calls
    greet();
    
    int sum = add(5, 3);
    cout << "Sum: " << sum << endl;
    
    double product = multiply(2.5, 4.0);
    cout << "Product: " << product << endl;
    
    int fact = factorial(5);
    cout << "Factorial of 5: " << fact << endl;
    
    return 0;
}

// Function definitions
void greet() {
    cout << "Hello from function!" << endl;
}

int add(int a, int b) {
    return a + b;
}

double multiply(double a, double b) {
    return a * b;
}

// Recursive function
int factorial(int n) {
    if (n == 0 || n == 1) {
        return 1;
    }
    return n * factorial(n - 1);
}
      ''';
    } else if (moduleTitle.contains('Classes/Objects') || moduleTitle.contains('Classes')) {
      return '''
// C++ Classes and Objects Example
#include <iostream>
#include <string>
using namespace std;

// Class definition
class Car {
public:
    // Attributes
    string brand;
    string model;
    int year;
    
    // Constructor
    Car(string b, string m, int y) {
        brand = b;
        model = m;
        year = y;
    }
    
    // Method
    void displayInfo() {
        cout << brand << " " << model << " " << year << endl;
    }
    
    // Setter method
    void setYear(int newYear) {
        year = newYear;
    }
};

int main() {
    // Creating objects
    Car car1("Toyota", "Corolla", 2020);
    Car car2("Honda", "Civic", 2022);
    
    // Using objects
    car1.displayInfo();
    car2.displayInfo();
    
    // Modifying object
    car1.setYear(2021);
    cout << "After update: ";
    car1.displayInfo();
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Inheritance')) {
      return '''
// C++ Inheritance Example
#include <iostream>
#include <string>
using namespace std;

// Base class
class Vehicle {
public:
    string brand = "Ford";
    void honk() {
        cout << "Tuut, tuut!" << endl;
    }
};

// Derived class
class Car : public Vehicle {
public:
    string model = "Mustang";
};

// Multiple inheritance example
class Engine {
public:
    void start() {
        cout << "Engine started!" << endl;
    }
};

class SportsCar : public Car, public Engine {
public:
    void display() {
        cout << brand << " " << model << endl;
        honk();
        start();
    }
};

int main() {
    Car myCar;
    cout << myCar.brand << " " << myCar.model << endl;
    myCar.honk();
    
    SportsCar sportsCar;
    sportsCar.display();
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Pointers')) {
      return '''
// C++ Pointers Example
#include <iostream>
using namespace std;

int main() {
    int var = 5;
    int* ptr = &var;
    
    cout << "Variable value: " << var << endl;
    cout << "Variable address: " << &var << endl;
    cout << "Pointer value: " << ptr << endl;
    cout << "Pointer dereference: " << *ptr << endl;
    
    // Pointer arithmetic
    int numbers[3] = {10, 20, 30};
    int* numPtr = numbers;
    
    cout << "\\nArray elements via pointer:" << endl;
    for (int i = 0; i < 3; i++) {
        cout << "*(numPtr + " << i << ") = " << *(numPtr + i) << endl;
    }
    
    // Dynamic memory allocation
    int* dynamicPtr = new int;
    *dynamicPtr = 100;
    cout << "\\nDynamic value: " << *dynamicPtr << endl;
    delete dynamicPtr;
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Files')) {
      return '''
// C++ Files Example
#include <iostream>
#include <fstream>
#include <string>
using namespace std;

int main() {
    // Writing to file
    ofstream outFile("example.txt");
    if (outFile.is_open()) {
        outFile << "Hello C++ File Handling!" << endl;
        outFile << "This is a sample file." << endl;
        outFile.close();
        cout << "File written successfully!" << endl;
    }
    
    // Reading from file
    ifstream inFile("example.txt");
    string line;
    if (inFile.is_open()) {
        cout << "\\nFile content:" << endl;
        while (getline(inFile, line)) {
            cout << line << endl;
        }
        inFile.close();
    }
    
    // Appending to file
    ofstream appFile("example.txt", ios::app);
    if (appFile.is_open()) {
        appFile << "Appended line!" << endl;
        appFile.close();
        cout << "File appended successfully!" << endl;
    }
    
    return 0;
}
      ''';
    } else if (moduleTitle.contains('Exceptions')) {
      return '''
// C++ Exceptions Example
#include <iostream>
#include <stdexcept>
using namespace std;

double divide(double a, double b) {
    if (b == 0) {
        throw runtime_error("Division by zero!");
    }
    return a / b;
}

int main() {
    try {
        // This will work
        double result1 = divide(10.0, 2.0);
        cout << "10 / 2 = " << result1 << endl;
        
        // This will throw exception
        double result2 = divide(10.0, 0.0);
        cout << "10 / 0 = " << result2 << endl;
        
    } catch (const runtime_error& e) {
        cout << "Error: " << e.what() << endl;
    } catch (...) {
        cout << "Unknown error occurred!" << endl;
    }
    
    // Multiple exception types
    try {
        int arr[3] = {1, 2, 3};
        cout << "Array element: " << arr[5] << endl; // Out of bounds
        
    } catch (const out_of_range& e) {
        cout << "Out of range error: " << e.what() << endl;
    } catch (const exception& e) {
        cout << "Standard exception: " << e.what() << endl;
    }
    
    cout << "Program continues after exception handling." << endl;
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