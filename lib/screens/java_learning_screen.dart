import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'java_practice_screen.dart';

class JavaLearningScreen extends StatefulWidget {
  final String moduleTitle;
  final String fileName;
  final Color primaryColor;

  const JavaLearningScreen({
    Key? key,
    required this.moduleTitle,
    required this.fileName,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<JavaLearningScreen> createState() => _JavaLearningScreenState();
}

class _JavaLearningScreenState extends State<JavaLearningScreen> {
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
      case 'Java Introduction':
        return '''
Java is a high-level, class-based, object-oriented programming language designed to have as few implementation dependencies as possible.

Key Features:
• Platform Independent: Write once, run anywhere (WORA)
• Object-Oriented: Follows OOP principles
• Simple and Familiar: C/C++ like syntax
• Secure: Built-in security features
• Multithreaded: Can perform multiple tasks simultaneously
• High Performance: Just-In-Time (JIT) compiler

Java Platforms:
• Java SE (Standard Edition)
• Java EE (Enterprise Edition) 
• Java ME (Micro Edition)

Java is widely used for enterprise applications, web development, mobile apps (Android), and big data technologies.
''';

      case 'Java Syntax':
        return '''
Java Syntax refers to the set of rules that define how a Java program is written and interpreted.

Basic Syntax Rules:
1. Case Sensitivity: Java is case-sensitive
2. Class Names: Should start with uppercase letter
3. Method Names: Should start with lowercase letter
4. Program File Name: Must match class name
5. public static void main(String[] args): Main method required

Every Java application must contain a main method, which is the entry point for the program.

Common Syntax Elements:
• Semicolons: End each statement
• Curly Braces: Define blocks of code
• Comments: // for single-line, /* */ for multi-line
• Identifiers: Names for variables, methods, classes
''';

      case 'Java Data Types':
        return '''
Java Data Types specify the different sizes and values that can be stored in variables.

Primitive Data Types:
1. byte: 8-bit integer (-128 to 127)
2. short: 16-bit integer (-32,768 to 32,767)
3. int: 32-bit integer (-2^31 to 2^31-1)
4. long: 64-bit integer (-2^63 to 2^63-1)
5. float: 32-bit floating point
6. double: 64-bit floating point
7. boolean: true or false
8. char: 16-bit Unicode character

Non-Primitive Data Types:
• String: Sequence of characters
• Arrays: Collection of similar type elements
• Classes: User-defined data types

Type casting is required when converting between incompatible types.
''';

      case 'Java Variables':
        return '''
Variables are containers for storing data values in Java.

Variable Declaration:
• type variableName = value;

Types of Variables:
1. Local Variables: Declared inside methods
2. Instance Variables: Declared in class, outside methods
3. Static Variables: Declared with static keyword

Variable Naming Rules:
• Must start with letter, \$, or _
• Case sensitive
• No reserved keywords
• Can contain letters, digits, _, \$

Variable Scope:
• Local: Accessible only within method
• Instance: Accessible throughout class
• Static: Shared among all instances
''';

      case 'Java Operators':
        return '''
Operators are special symbols that perform operations on operands.

Types of Operators:
1. Arithmetic: +, -, *, /, %, ++, --
2. Assignment: =, +=, -=, *=, /=, %=
3. Comparison: ==, !=, >, <, >=, <=
4. Logical: &&, ||, !
5. Bitwise: &, |, ^, ~, <<, >>, >>>

Operator Precedence:
1. Postfix: expr++ expr--
2. Unary: ++expr --expr +expr -expr ~ !
3. Multiplicative: * / %
4. Additive: + -
5. Shift: << >> >>>
6. Relational: < > <= >= instanceof
7. Equality: == !=
8. Bitwise AND: &
9. Bitwise XOR: ^
10. Bitwise OR: |
11. Logical AND: &&
12. Logical OR: ||
13. Ternary: ? :
14. Assignment: = += -= etc.
''';

      case 'Java Strings':
        return '''
String in Java is an object that represents a sequence of characters.

String Creation:
• String literal: String s = "Hello";
• Using new keyword: String s = new String("Hello");

Important String Methods:
• length(): Returns string length
• charAt(): Returns character at index
• substring(): Returns substring
• equals(): Compares strings
• toLowerCase()/toUpperCase(): Case conversion
• trim(): Removes whitespace
• split(): Splits string into array

String Immutability:
Strings are immutable in Java - once created cannot be changed.

StringBuilder and StringBuffer:
Used for mutable sequences of characters.
''';

      case 'Java Arrays':
        return '''
Arrays are used to store multiple values in a single variable.

Array Declaration:
• Single-dimensional: int[] numbers = new int[5];
• Multi-dimensional: int[][] matrix = new int[3][3];

Array Initialization:
• int[] numbers = {1, 2, 3, 4, 5};
• String[] names = new String[]{"John", "Jane"};

Array Properties:
• Fixed size once created
• Zero-based indexing
• length property gives array size
• Can store primitive types or objects

Common Array Operations:
• Accessing: array[index]
• Modifying: array[index] = value
• Iterating: for loop or for-each loop
• Sorting: Arrays.sort(array)
''';

      case 'Java Methods':
        return '''
Methods are blocks of code that perform specific tasks and can be reused.

Method Declaration:
accessModifier returnType methodName(parameters) {
    // method body
    return value;
}

Method Components:
1. Access Modifier: public, private, protected
2. Return Type: void if no return value
3. Method Name: Should be descriptive
4. Parameters: Input values for method
5. Method Body: Code to be executed
6. Return Statement: Returns value (if any)

Method Types:
• Instance Methods: Called on objects
• Static Methods: Called using class name
• Abstract Methods: No implementation

Method Overloading:
Multiple methods with same name but different parameters.
''';

      case 'Java OOP':
        return '''
Object-Oriented Programming (OOP) in Java organizes software design around objects.

OOP Principles:
1. Encapsulation: Bundling data and methods
2. Inheritance: Creating new classes from existing ones
3. Polymorphism: Same method, different implementations
4. Abstraction: Hiding implementation details

Class and Object:
• Class: Blueprint for objects
• Object: Instance of a class

Key Concepts:
• Constructors: Special methods for object initialization
• this keyword: Refers to current object
• Access Modifiers: public, private, protected
• Packages: Organize related classes

Benefits of OOP:
• Code reusability
• Modularity
• Maintainability
• Security
''';

      case 'Java Inheritance':
        return '''
Inheritance allows a class to acquire properties and methods of another class.

Types of Inheritance:
1. Single: One class extends another
2. Multilevel: Chain of inheritance
3. Hierarchical: Multiple classes extend one class
4. Multiple: Not supported in Java (use interfaces)

Keywords:
• extends: For class inheritance
• implements: For interface implementation
• super: Refers to parent class
• final: Prevents inheritance

Method Overriding:
Subclass provides specific implementation of parent class method.

Abstract Classes:
• Cannot be instantiated
• Can have abstract and concrete methods
• Must be extended by subclasses
''';

      case 'Java Loops':
        return '''
Loops are used to execute a block of code repeatedly.

Types of Loops:
1. for loop: Known number of iterations
2. while loop: Unknown iterations, condition checked first
3. do-while loop: Unknown iterations, executes at least once
4. for-each loop: Iterates through arrays/collections

Loop Control Statements:
• break: Exits the loop
• continue: Skips current iteration
• return: Exits the method

Nested Loops:
Loops inside other loops.

Infinite Loops:
Loops that never terminate (usually unintentional).
''';

      case 'Java Conditions':
        return '''
Conditional statements are used to perform different actions based on different conditions.

Types of Conditional Statements:
1. if statement: Executes code if condition is true
2. if-else statement: Executes one block if true, another if false
3. if-else-if ladder: Multiple conditions checked in sequence
4. switch statement: Multiple possible execution paths

Comparison Operators:
• == : Equal to
• != : Not equal to
• > : Greater than
• < : Less than
• >= : Greater than or equal to
• <= : Less than or equal to

Logical Operators:
• && : Logical AND
• || : Logical OR
• ! : Logical NOT

Ternary Operator:
condition ? expression1 : expression2
''';

      case 'Java Collections':
        return '''
Collections Framework provides architecture to store and manipulate groups of objects.

Main Interfaces:
1. List: Ordered collection, allows duplicates
2. Set: Unordered collection, no duplicates
3. Map: Key-value pairs, unique keys
4. Queue: FIFO ordering

Common Implementations:
• ArrayList: Resizable array implementation
• LinkedList: Doubly-linked list implementation
• HashSet: Hash table implementation of Set
• HashMap: Hash table based implementation of Map
• TreeSet: Red-black tree implementation of Set

Collection Methods:
• add(), remove(), contains(), size(), isEmpty()
• Collections class provides utility methods

Benefits:
• Reduces programming effort
• Increases performance
• Provides common language
''';

      case 'Java Exception Handling':
        return '''
Exception Handling manages runtime errors to maintain normal flow of application.

Types of Exceptions:
1. Checked Exceptions: Checked at compile-time
2. Unchecked Exceptions: Checked at runtime
3. Errors: Beyond program control

Exception Handling Keywords:
• try: Block of code to monitor for exceptions
• catch: Handles the exception
• finally: Always executes (cleanup code)
• throw: Throws an exception explicitly
• throws: Declares exceptions that might be thrown

Common Exceptions:
• NullPointerException
• ArrayIndexOutOfBoundsException
• ArithmeticException
• IOException

Custom Exceptions:
User-defined exception classes extending Exception class.
''';

      case 'Java File Handling':
        return '''
File Handling allows Java programs to create, read, update, and delete files.

Key Classes:
1. File: File and directory pathnames
2. FileReader: Reads character files
3. FileWriter: Writes character files
4. BufferedReader: Reads text efficiently
5. BufferedWriter: Writes text efficiently
6. Scanner: Parses primitive types and strings

Common Operations:
• Create file: File.createNewFile()
• Read file: FileReader, BufferedReader, Scanner
• Write file: FileWriter, BufferedWriter
• Delete file: File.delete()
• Check existence: File.exists()

Streams:
• Byte Streams: InputStream, OutputStream
• Character Streams: Reader, Writer

Exception Handling:
File operations throw IOException that must be handled.
''';

      case 'Java Multithreading':
        return '''
Multithreading allows concurrent execution of two or more parts of a program.

Thread Creation Methods:
1. Extending Thread class
2. Implementing Runnable interface

Thread Lifecycle:
1. New: Thread created but not started
2. Runnable: Thread ready to run
3. Running: Thread executing
4. Blocked: Thread waiting for monitor lock
5. Waiting: Thread waiting indefinitely
6. Timed Waiting: Thread waiting for specified time
7. Terminated: Thread completed execution

Synchronization:
Prevents thread interference and consistency problems.

Thread Methods:
• start(): Starts thread execution
• run(): Entry point for thread
• sleep(): Suspends thread execution
• join(): Waits for thread to die
• interrupt(): Interrupts thread execution
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
        builder: (context) => JavaPracticeScreen(
          moduleTitle: widget.moduleTitle,
          primaryColor: widget.primaryColor,
          language: 'Java', // Add this required parameter
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
                'Java Example',
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
      case 'Java Introduction':
        return '''
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}''';

      case 'Java Syntax':
        return '''
public class Main {
    public static void main(String[] args) {
        // This is a single-line comment
        System.out.println("Hello Java!");
        
        /* This is a 
           multi-line comment */
    }
}''';

      case 'Java Data Types':
        return '''
public class DataTypes {
    public static void main(String[] args) {
        int number = 10;
        double decimal = 10.5;
        char letter = 'A';
        boolean flag = true;
        String text = "Hello Java";
        
        System.out.println("Integer: " + number);
        System.out.println("Double: " + decimal);
        System.out.println("Character: " + letter);
        System.out.println("Boolean: " + flag);
        System.out.println("String: " + text);
    }
}''';

      case 'Java Variables':
        return '''
public class Variables {
    static int classVariable = 100; // Static variable
    
    public static void main(String[] args) {
        int localVar = 50; // Local variable
        final double PI = 3.14159; // Constant
        
        System.out.println("Class Variable: " + classVariable);
        System.out.println("Local Variable: " + localVar);
        System.out.println("Constant PI: " + PI);
    }
}''';

      case 'Java Operators':
        return '''
public class Operators {
    public static void main(String[] args) {
        int a = 10, b = 5;
        
        // Arithmetic operators
        System.out.println("a + b = " + (a + b));
        System.out.println("a - b = " + (a - b));
        System.out.println("a * b = " + (a * b));
        System.out.println("a / b = " + (a / b));
        
        // Comparison operators
        System.out.println("a == b: " + (a == b));
        System.out.println("a > b: " + (a > b));
        
        // Logical operators
        boolean x = true, y = false;
        System.out.println("x && y: " + (x && y));
        System.out.println("x || y: " + (x || y));
    }
}''';

      case 'Java Strings':
        return '''
public class StringExample {
    public static void main(String[] args) {
        String str1 = "Hello";
        String str2 = "World";
        
        // String concatenation
        String result = str1 + " " + str2;
        System.out.println(result);
        
        // String methods
        System.out.println("Length: " + result.length());
        System.out.println("Uppercase: " + result.toUpperCase());
        System.out.println("Substring: " + result.substring(0, 5));
        System.out.println("Contains 'World': " + result.contains("World"));
    }
}''';

      case 'Java Arrays':
        return '''
import java.util.Arrays;

public class ArrayExample {
    public static void main(String[] args) {
        // Array declaration and initialization
        int[] numbers = {1, 2, 3, 4, 5};
        String[] names = new String[3];
        names[0] = "John";
        names[1] = "Jane";
        names[2] = "Doe";
        
        // Accessing array elements
        System.out.println("First number: " + numbers[0]);
        System.out.println("Array length: " + numbers.length);
        
        // Looping through array
        for (int i = 0; i < numbers.length; i++) {
            System.out.println("numbers[" + i + "] = " + numbers[i]);
        }
        
        // Enhanced for loop
        for (String name : names) {
            System.out.println("Name: " + name);
        }
    }
}''';

      case 'Java Methods':
        return '''
public class MethodExample {
    
    // Method with return value and parameters
    public static int add(int a, int b) {
        return a + b;
    }
    
    // Method without return value
    public static void greet(String name) {
        System.out.println("Hello, " + name + "!");
    }
    
    // Method overloading
    public static int add(int a, int b, int c) {
        return a + b + c;
    }
    
    public static void main(String[] args) {
        int sum = add(5, 3);
        System.out.println("Sum: " + sum);
        
        greet("Alice");
        
        int tripleSum = add(1, 2, 3);
        System.out.println("Triple Sum: " + tripleSum);
    }
}''';

      case 'Java OOP':
        return '''
// Class definition
class Car {
    // Fields (attributes)
    private String brand;
    private String color;
    private int year;
    
    // Constructor
    public Car(String brand, String color, int year) {
        this.brand = brand;
        this.color = color;
        this.year = year;
    }
    
    // Methods
    public void startEngine() {
        System.out.println(brand + " engine started!");
    }
    
    public void displayInfo() {
        System.out.println("Brand: " + brand + 
                         ", Color: " + color + 
                         ", Year: " + year);
    }
}

public class OOPExample {
    public static void main(String[] args) {
        // Creating objects
        Car car1 = new Car("Toyota", "Red", 2020);
        Car car2 = new Car("Honda", "Blue", 2022);
        
        // Using object methods
        car1.displayInfo();
        car1.startEngine();
        
        car2.displayInfo();
        car2.startEngine();
    }
}''';

      case 'Java Inheritance':
        return '''
// Parent class
class Animal {
    protected String name;
    
    public Animal(String name) {
        this.name = name;
    }
    
    public void eat() {
        System.out.println(name + " is eating.");
    }
    
    public void sleep() {
        System.out.println(name + " is sleeping.");
    }
}

// Child class
class Dog extends Animal {
    private String breed;
    
    public Dog(String name, String breed) {
        super(name); // Call parent constructor
        this.breed = breed;
    }
    
    // Method overriding
    @Override
    public void eat() {
        System.out.println(name + " the " + breed + " is eating dog food.");
    }
    
    // Additional method
    public void bark() {
        System.out.println(name + " is barking!");
    }
}

public class InheritanceExample {
    public static void main(String[] args) {
        Dog myDog = new Dog("Buddy", "Golden Retriever");
        myDog.eat();    // Overridden method
        myDog.sleep();  // Inherited method
        myDog.bark();   // Child class method
    }
}''';

      case 'Java Loops':
        return '''
public class LoopExample {
    public static void main(String[] args) {
        // For loop
        System.out.println("For loop:");
        for (int i = 1; i <= 5; i++) {
            System.out.println("Count: " + i);
        }
        
        // While loop
        System.out.println("\\nWhile loop:");
        int j = 1;
        while (j <= 3) {
            System.out.println("While count: " + j);
            j++;
        }
        
        // Do-while loop
        System.out.println("\\nDo-while loop:");
        int k = 1;
        do {
            System.out.println("Do-while count: " + k);
            k++;
        } while (k <= 3);
        
        // For-each loop with array
        System.out.println("\\nFor-each loop:");
        int[] numbers = {10, 20, 30, 40, 50};
        for (int number : numbers) {
            System.out.println("Number: " + number);
        }
    }
}''';

      case 'Java Conditions':
        return '''
public class ConditionExample {
    public static void main(String[] args) {
        int score = 85;
        String grade;
        
        // If-else if-else ladder
        if (score >= 90) {
            grade = "A";
        } else if (score >= 80) {
            grade = "B";
        } else if (score >= 70) {
            grade = "C";
        } else if (score >= 60) {
            grade = "D";
        } else {
            grade = "F";
        }
        
        System.out.println("Score: " + score + ", Grade: " + grade);
        
        // Switch statement
        int day = 3;
        String dayName;
        
        switch (day) {
            case 1:
                dayName = "Monday";
                break;
            case 2:
                dayName = "Tuesday";
                break;
            case 3:
                dayName = "Wednesday";
                break;
            case 4:
                dayName = "Thursday";
                break;
            case 5:
                dayName = "Friday";
                break;
            default:
                dayName = "Weekend";
        }
        
        System.out.println("Day " + day + " is " + dayName);
        
        // Ternary operator
        int age = 20;
        String status = (age >= 18) ? "Adult" : "Minor";
        System.out.println("Age " + age + ": " + status);
    }
}''';

      case 'Java Collections':
        return '''
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

public class CollectionExample {
    public static void main(String[] args) {
        // ArrayList example
        ArrayList<String> fruits = new ArrayList<>();
        fruits.add("Apple");
        fruits.add("Banana");
        fruits.add("Orange");
        System.out.println("ArrayList: " + fruits);
        
        // HashSet example
        HashSet<Integer> numbers = new HashSet<>();
        numbers.add(1);
        numbers.add(2);
        numbers.add(3);
        numbers.add(1); // Duplicate, won't be added
        System.out.println("HashSet: " + numbers);
        
        // HashMap example
        HashMap<String, Integer> ageMap = new HashMap<>();
        ageMap.put("John", 25);
        ageMap.put("Jane", 30);
        ageMap.put("Bob", 35);
        System.out.println("HashMap: " + ageMap);
        System.out.println("John's age: " + ageMap.get("John"));
        
        // Iterating through collections
        System.out.println("\\nFruits list:");
        for (String fruit : fruits) {
            System.out.println("- " + fruit);
        }
    }
}''';

      case 'Java Exception Handling':
        return '''
import java.util.Scanner;

public class ExceptionExample {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        try {
            System.out.print("Enter first number: ");
            int num1 = scanner.nextInt();
            
            System.out.print("Enter second number: ");
            int num2 = scanner.nextInt();
            
            // Potential division by zero
            int result = num1 / num2;
            System.out.println("Result: " + result);
            
            // Potential array index out of bounds
            int[] arr = new int[5];
            arr[10] = 100; // This will throw exception
            
        } catch (ArithmeticException e) {
            System.out.println("Error: Division by zero is not allowed!");
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("Error: Array index out of bounds!");
        } catch (Exception e) {
            System.out.println("Error: Something went wrong!");
        } finally {
            System.out.println("This block always executes.");
            scanner.close();
        }
        
        // Custom exception example
        try {
            checkAge(15);
        } catch (Exception e) {
            System.out.println("Caught exception: " + e.getMessage());
        }
    }
    
    static void checkAge(int age) throws Exception {
        if (age < 18) {
            throw new Exception("Age must be 18 or older!");
        }
        System.out.println("Age is valid: " + age);
    }
}''';

      case 'Java File Handling':
        return '''
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;

public class FileExample {
    public static void main(String[] args) {
        // Create file
        try {
            File file = new File("example.txt");
            if (file.createNewFile()) {
                System.out.println("File created: " + file.getName());
            } else {
                System.out.println("File already exists.");
            }
        } catch (IOException e) {
            System.out.println("Error creating file.");
            e.printStackTrace();
        }
        
        // Write to file
        try {
            FileWriter writer = new FileWriter("example.txt");
            writer.write("Hello, File Handling in Java!\\n");
            writer.write("This is a second line.\\n");
            writer.close();
            System.out.println("Successfully wrote to the file.");
        } catch (IOException e) {
            System.out.println("Error writing to file.");
            e.printStackTrace();
        }
        
        // Read from file
        try {
            File file = new File("example.txt");
            Scanner reader = new Scanner(file);
            System.out.println("File content:");
            while (reader.hasNextLine()) {
                String data = reader.nextLine();
                System.out.println(data);
            }
            reader.close();
        } catch (IOException e) {
            System.out.println("Error reading file.");
            e.printStackTrace();
        }
        
        // File information
        File file = new File("example.txt");
        if (file.exists()) {
            System.out.println("\\nFile Information:");
            System.out.println("File name: " + file.getName());
            System.out.println("Absolute path: " + file.getAbsolutePath());
            System.out.println("Writable: " + file.canWrite());
            System.out.println("Readable: " + file.canRead());
            System.out.println("File size in bytes: " + file.length());
        }
    }
}''';

      case 'Java Multithreading':
        return '''
// Method 1: Extending Thread class
class MyThread extends Thread {
    private String threadName;
    
    MyThread(String name) {
        threadName = name;
    }
    
    public void run() {
        try {
            for (int i = 1; i <= 5; i++) {
                System.out.println(threadName + ": Count " + i);
                Thread.sleep(1000); // Pause for 1 second
            }
        } catch (InterruptedException e) {
            System.out.println(threadName + " interrupted.");
        }
        System.out.println(threadName + " exiting.");
    }
}

// Method 2: Implementing Runnable interface
class MyRunnable implements Runnable {
    private String threadName;
    
    MyRunnable(String name) {
        threadName = name;
    }
    
    public void run() {
        try {
            for (int i = 1; i <= 5; i++) {
                System.out.println(threadName + ": Count " + i);
                Thread.sleep(500); // Pause for 0.5 seconds
            }
        } catch (InterruptedException e) {
            System.out.println(threadName + " interrupted.");
        }
        System.out.println(threadName + " exiting.");
    }
}

public class MultithreadingExample {
    public static void main(String[] args) {
        // Using Thread class
        MyThread thread1 = new MyThread("Thread-1");
        MyThread thread2 = new MyThread("Thread-2");
        
        // Using Runnable interface
        Thread thread3 = new Thread(new MyRunnable("Thread-3"));
        Thread thread4 = new Thread(new MyRunnable("Thread-4"));
        
        // Start threads
        thread1.start();
        thread2.start();
        thread3.start();
        thread4.start();
        
        // Wait for threads to finish
        try {
            thread1.join();
            thread2.join();
            thread3.join();
            thread4.join();
        } catch (InterruptedException e) {
            System.out.println("Main thread interrupted.");
        }
        
        System.out.println("Main thread exiting.");
    }
}''';

      default:
        return '''
public class DefaultExample {
    public static void main(String[] args) {
        System.out.println("Welcome to Java Programming!");
        System.out.println("This is a basic Java program structure.");
    }
}''';
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
            _buildContentSection('Java Tutorial Content', _content),

            // Example Section
            _buildCodeExample(
              _getExampleCode(widget.moduleTitle),
              'Java',
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
                        'Java Practice Exercises',
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
                    'Test your Java knowledge with interactive coding exercises:',
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