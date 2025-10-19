import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'python_practice_screen.dart';

class PythonLearningScreen extends StatefulWidget {
  final String moduleTitle;
  final String fileName;
  final Color primaryColor;

  const PythonLearningScreen({
    Key? key,
    required this.moduleTitle,
    required this.fileName,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<PythonLearningScreen> createState() => _PythonLearningScreenState();
}

class _PythonLearningScreenState extends State<PythonLearningScreen> {
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
      case 'Python Introduction':
        return '''
Python is a high-level, interpreted programming language known for its simplicity and readability.

Key Features:
• Easy to learn and use
• Cross-platform compatibility
• Extensive standard library
• Supports multiple programming paradigms
• Dynamic typing
• Automatic memory management

Python is widely used in:
- Web Development (Django, Flask)
- Data Science and Machine Learning
- Automation and Scripting
- Scientific Computing
- Artificial Intelligence
''';

      case 'Python Syntax':
        return '''
Python Syntax emphasizes readability and simplicity.

Key Syntax Rules:
• Indentation is used for code blocks (4 spaces recommended)
• No semicolons needed at line endings
• Variables are dynamically typed
• Comments start with #
• Case-sensitive language

Example Structure:
# This is a comment
variable_name = "value"

def function_name():
    # Indented code block
    print("Hello World")
''';

      case 'Python Variables':
        return '''
Variables in Python are created when you assign a value to them.

Variable Rules:
• No need to declare type
• Name must start with letter or underscore
• Can contain letters, numbers, underscores
• Case-sensitive

Data Types:
• int - integer numbers
• float - decimal numbers
• str - text strings
• bool - True/False values
• list - ordered, mutable sequences
• tuple - ordered, immutable sequences
• dict - key-value pairs
• set - unordered, unique elements
''';

      case 'Python Data Types':
        return '''
Python has various built-in data types:

Numeric Types:
• int: 10, -5, 0
• float: 3.14, -2.5, 0.0
• complex: 1+2j

Sequence Types:
• str: "hello", 'world'
• list: [1, 2, 3], ['a', 'b']
• tuple: (1, 2, 3), ('x', 'y')

Mapping Type:
• dict: {'name': 'John', 'age': 25}

Set Types:
• set: {1, 2, 3}
• frozenset: immutable set

Boolean Type:
• bool: True, False

None Type:
• None: represents null
''';

      case 'Python Strings':
        return '''
Strings in Python are sequences of characters enclosed in quotes.

String Creation:
single_quotes = 'hello'
double_quotes = "world"
triple_quotes = """multiline string"""

Common String Methods:
• upper() - convert to uppercase
• lower() - convert to lowercase
• strip() - remove whitespace
• split() - split into list
• replace() - replace substring
• find() - find substring position
• len() - get string length

String Formatting:
• f-strings: f"Hello {name}"
• format(): "Hello {}".format(name)
• % formatting: "Hello %s" % name
''';

      case 'Python Operators':
        return '''
Python supports various types of operators:

Arithmetic Operators:
• + Addition
• - Subtraction
• * Multiplication
• / Division
• % Modulus
• ** Exponentiation
• // Floor Division

Comparison Operators:
• == Equal
• != Not equal
• > Greater than
• < Less than
• >= Greater than or equal
• <= Less than or equal

Logical Operators:
• and - Logical AND
• or - Logical OR
• not - Logical NOT

Assignment Operators:
• = Assign
• += Add and assign
• -= Subtract and assign
• *= Multiply and assign
''';

      case 'Python Lists':
        return '''
Lists are ordered, mutable sequences in Python.

List Creation:
numbers = [1, 2, 3, 4, 5]
fruits = ['apple', 'banana', 'cherry']
mixed = [1, 'hello', 3.14, True]

Common List Methods:
• append() - add element to end
• insert() - insert element at position
• remove() - remove first occurrence
• pop() - remove and return element
• sort() - sort list in place
• reverse() - reverse list in place
• len() - get list length
• index() - find index of element

List Slicing:
• list[start:end] - slice from start to end-1
• list[start:] - slice from start to end
• list[:end] - slice from beginning to end-1
• list[::step] - slice with step
''';

      case 'Python Tuples':
        return '''
Tuples are ordered, immutable sequences in Python.

Tuple Creation:
coordinates = (10, 20)
colors = ('red', 'green', 'blue')
single_element = (42,)  # Note the comma

Key Characteristics:
• Immutable - cannot be changed after creation
• Ordered - elements maintain their position
• Can contain different data types
• Faster than lists for certain operations

Tuple Methods:
• count() - count occurrences of value
• index() - find first occurrence of value

Common Uses:
• Returning multiple values from functions
• Dictionary keys (if all elements are immutable)
• Data that shouldn't be modified
''';

      case 'Python Sets':
        return '''
Sets are unordered collections of unique elements.

Set Creation:
numbers = {1, 2, 3, 4, 5}
fruits = set(['apple', 'banana', 'cherry'])

Key Characteristics:
• Unordered - no index-based access
• Unique elements - no duplicates allowed
• Mutable - can add/remove elements
• Mathematical set operations supported

Set Methods:
• add() - add element to set
• remove() - remove element (raises error if not found)
• discard() - remove element (no error if not found)
• union() or | - set union
• intersection() or & - set intersection
• difference() or - - set difference
''';

      case 'Python Dictionaries':
        return '''
Dictionaries are key-value pairs in Python.

Dictionary Creation:
person = {'name': 'John', 'age': 30, 'city': 'New York'}
empty_dict = {}

Key Characteristics:
• Unordered (until Python 3.7, ordered in 3.7+)
• Mutable - can add, remove, modify items
• Keys must be immutable types
• Values can be any data type

Dictionary Methods:
• get() - safe value access
• keys() - get all keys
• values() - get all values
• items() - get key-value pairs
• update() - update with another dictionary
• pop() - remove key and return value
• clear() - remove all items
''';

      case 'Python Conditions':
        return '''
Conditional statements control program flow based on conditions.

if Statement:
if condition:
    # code to execute if condition is True

if-else Statement:
if condition:
    # code if condition is True
else:
    # code if condition is False

if-elif-else Statement:
if condition1:
    # code if condition1 is True
elif condition2:
    # code if condition2 is True
else:
    # code if all conditions are False

Comparison Operators:
• ==, !=, >, <, >=, <=

Logical Operators:
• and, or, not

Ternary Operator:
value_if_true if condition else value_if_false
''';

      case 'Python Loops':
        return '''
Loops allow executing code repeatedly.

for Loop:
for variable in sequence:
    # code to execute for each item

While Loop:
while condition:
    # code to execute while condition is True

Loop Control Statements:
• break - exit the loop entirely
• continue - skip to next iteration
• pass - do nothing (placeholder)

Range Function:
• range(stop) - 0 to stop-1
• range(start, stop) - start to stop-1
• range(start, stop, step) - with step size

Enumerate Function:
for index, value in enumerate(sequence):
    # access both index and value
''';

      case 'Python Functions':
        return '''
Functions are reusable blocks of code.

Function Definition:
def function_name(parameters):
    """docstring"""
    # function body
    return value

Function Call:
function_name(arguments)

Parameters Types:
• Positional parameters
• Keyword parameters
• Default parameters
• Variable-length parameters (*args, **kwargs)

Lambda Functions:
Small anonymous functions:
lambda arguments: expression

Scope:
• Local scope - inside function
• Global scope - entire program
• Nonlocal scope - nested functions
''';

      case 'Python Classes':
        return '''
Classes are blueprints for creating objects (OOP).

Class Definition:
class ClassName:
    def __init__(self, parameters):
        # constructor
        self.attribute = value
    
    def method(self):
        # method definition
        return result

Object Creation:
object_name = ClassName(arguments)

Key OOP Concepts:
• Inheritance - creating subclasses
• Encapsulation - data hiding
• Polymorphism - same interface, different implementation
• Abstraction - hiding complex reality

Special Methods:
• __init__() - constructor
• __str__() - string representation
• __len__() - length of object
''';

      case 'Python Modules':
        return '''
Modules are Python files containing reusable code.

Importing Modules:
import module_name
from module_name import function_name
from module_name import *
import module_name as alias

Standard Library Modules:
• math - mathematical functions
• os - operating system interfaces
• datetime - date and time handling
• random - random number generation
• json - JSON encoding/decoding
• csv - CSV file handling

Creating Modules:
• Save code in .py file
• Import using filename (without .py)
• Use if __name__ == "__main__" for executable code

Package Installation:
pip install package_name
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
        builder: (context) => PythonPracticeScreen(
          moduleTitle: widget.moduleTitle,
          primaryColor: widget.primaryColor,
          language: 'Python',
        ),
      ),
    );
  }

  Widget _buildContentSection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
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
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeExample(String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 8),
              Text(
                'Python Example',
                style: TextStyle(
                  color: widget.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            code,
            style: const TextStyle(
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
      case 'Python Introduction':
        return 'print("Hello, World!")\n\n# Simple variable assignment\nname = "Python"\nversion = 3.9\nprint(f"Welcome to {name} {version}")';

      case 'Python Syntax':
        return '# Python uses indentation for code blocks\nif True:\n    print("This is indented")\n    print("So is this")\nelse:\n    print("This is else block")\n\n# No semicolons needed\nx = 5\ny = 10\nresult = x + y';

      case 'Python Variables':
        return '# Variable assignment\nname = "Alice"\nage = 25\nheight = 5.6\nis_student = True\n\n# Multiple assignment\nx, y, z = 1, 2, 3\n\n# Print variables\nprint(f"Name: {name}")\nprint(f"Age: {age}")\nprint(f"Height: {height}")';

      case 'Python Data Types':
        return '# Different data types\ninteger_num = 10\nfloat_num = 3.14\nstring_text = "Hello"\nboolean_val = True\nlist_data = [1, 2, 3]\ntuple_data = (1, 2, 3)\ndict_data = {"key": "value"}\n\n# Type checking\nprint(type(integer_num))\nprint(type(string_text))';

      case 'Python Strings':
        return '# String operations\ntext = "Hello World"\n\nprint(text.upper())      # HELLO WORLD\nprint(text.lower())      # hello world\nprint(text.strip())      # Remove whitespace\nprint(text.split())      # [\'Hello\', \'World\']\nprint(text.replace("H", "J"))  # Jello World\n\n# String formatting\nname = "Alice"\nprint(f"Hello, {name}!")';

      case 'Python Operators':
        return '# Arithmetic operators\na = 10\nb = 3\n\nprint(a + b)   # 13\nprint(a - b)   # 7\nprint(a * b)   # 30\nprint(a / b)   # 3.333...\nprint(a % b)   # 1\nprint(a ** b)  # 1000\n\n# Comparison operators\nprint(a == b)  # False\nprint(a > b)   # True';

      case 'Python Lists':
        return '# List operations\nfruits = ["apple", "banana", "cherry"]\n\n# Access elements\nprint(fruits[0])        # apple\nprint(fruits[-1])       # cherry\n\n# Modify list\nfruits.append("orange")  # Add item\nfruits.remove("banana")  # Remove item\nfruits[1] = "berry"     # Change item\n\n# List methods\nprint(len(fruits))      # Length\nprint(sorted(fruits))   # Sort list';

      case 'Python Tuples':
        return '# Tuple examples\ncoordinates = (10, 20)\ncolors = ("red", "green", "blue")\n\n# Access elements\nprint(coordinates[0])   # 10\nprint(colors[1])        # green\n\n# Tuple methods\nprint(colors.count("red"))  # Count occurrences\nprint(colors.index("green")) # Find index\n\n# Note: Tuples are immutable\n# coordinates[0] = 15  # This would cause an error';

      case 'Python Sets':
        return '# Set operations\nset1 = {1, 2, 3, 4, 5}\nset2 = {4, 5, 6, 7, 8}\n\n# Set methods\nset1.add(6)           # Add element\nset1.remove(1)        # Remove element\n\n# Set operations\nprint(set1 | set2)    # Union: {1,2,3,4,5,6,7,8}\nprint(set1 & set2)    # Intersection: {4,5,6}\nprint(set1 - set2)    # Difference: {1,2,3}';

      case 'Python Dictionaries':
        return '# Dictionary examples\nperson = {\n    "name": "John",\n    "age": 30,\n    "city": "New York"\n}\n\n# Access values\nprint(person["name"])     # John\nprint(person.get("age"))  # 30\n\n# Modify dictionary\nperson["age"] = 31        # Update value\nperson["job"] = "Engineer" # Add new key\n\n# Dictionary methods\nprint(person.keys())     # dict_keys([\'name\', \'age\', \'city\'])\nprint(person.values())   # dict_values([\'John\', 31, \'New York\'])';

      case 'Python Conditions':
        return '# Conditional statements\nage = 18\n\nif age >= 18:\n    print("You are an adult")\nelif age >= 13:\n    print("You are a teenager")\nelse:\n    print("You are a child")\n\n# Ternary operator\nstatus = "adult" if age >= 18 else "minor"\nprint(status)';

      case 'Python Loops':
        return '# For loop\nfor i in range(5):\n    print(f"Number: {i}")\n\n# While loop\ncount = 0\nwhile count < 3:\n    print(f"Count: {count}")\n    count += 1\n\n# Loop with list\nfruits = ["apple", "banana", "cherry"]\nfor fruit in fruits:\n    print(fruit)';

      case 'Python Functions':
        return '# Function definition\ndef greet(name):\n    """This function greets the user"""\n    return f"Hello, {name}!"\n\n# Function call\nmessage = greet("Alice")\nprint(message)\n\n# Function with default parameters\ndef power(base, exponent=2):\n    return base ** exponent\n\nprint(power(3))     # 9\nprint(power(3, 3))  # 27';

      case 'Python Classes':
        return '# Class definition\nclass Person:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n    \n    def greet(self):\n        return f"Hello, I\'m {self.name}"\n\n# Create object\nperson1 = Person("Alice", 25)\nprint(person1.greet())  # Hello, I\'m Alice\n\n# Access attributes\nprint(person1.name)     # Alice\nprint(person1.age)      # 25';

      case 'Python Modules':
        return '# Importing modules\nimport math\nimport datetime\nfrom random import randint\n\n# Using modules\nprint(math.sqrt(16))           # 4.0\nprint(datetime.datetime.now()) # Current date/time\nprint(randint(1, 10))          # Random number\n\n# Creating your own module\n# Save this as my_module.py:\n# def hello():\n#     print("Hello from my module!")\n\n# Then import it:\n# import my_module\n# my_module.hello()';

      default:
        return '# Python example code\nprint("Welcome to Python!")\n\n# Simple calculation\nx = 5\ny = 3\nresult = x + y\nprint(f"{x} + {y} = {result}")';
    }
  }

  void _showQuizDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          title: Row(
            children: const [
              Icon(Icons.quiz, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Quiz Feature',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'Quiz feature coming soon! Practice your coding skills with the interactive practice exercises first.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          widget.moduleTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B263B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
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
            const SizedBox(height: 16),
            const Text(
              'Loading Python Tutorial...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                      const SizedBox(width: 12),
                      Text(
                        widget.moduleTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Learn Python step by step with examples and explanations',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Content Display
            _buildContentSection('Python Tutorial Content', _content),

            // Example Section
            _buildCodeExample(_getExampleCode(widget.moduleTitle)),

            // Practice Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.fitness_center, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Python Practice Exercises',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Test your Python knowledge with interactive coding exercises:',
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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}