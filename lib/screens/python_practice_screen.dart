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
    'description': 'Write your first Python program that prints "Hello, World!"',
    'starterCode': '# Write your first Python program here\nprint("Hello, World!")',
    'solution': 'print("Hello, World!")',
    'testCases': ['Hello, World!'],
    'hint': 'Use the print() function to display text on the screen.'
    },
    {
    'title': 'Basic Arithmetic',
    'description': 'Perform basic arithmetic operations in Python',
    'starterCode': '# Calculate and print the result\nresult = 10 + 5 * 2\nprint("Result:", result)',
    'solution': 'result = 10 + 5 * 2\nprint("Result:", result)',
    'testCases': ['Result: 20'],
    'hint': 'Remember the order of operations: multiplication before addition.'
    },
    {
    'title': 'Comments and Documentation',
    'description': 'Practice writing comments and understanding Python syntax',
    'starterCode': '# This is a single-line comment\n\n"""\nThis is a multi-line comment\nIt can span multiple lines\n"""\n\n# Write a program that calculates area of a rectangle\nlength = 10\nwidth = 5\narea = length * width\nprint("Area:", area)',
    'solution': '# Calculate area of rectangle\nlength = 10\nwidth = 5\narea = length * width\nprint("Area:", area)',
    'testCases': ['Area: 50'],
    'hint': 'Use # for single-line comments and triple quotes for multi-line comments.'
    },
    ];
    break;

    case 'Python Syntax':
    _exercises = [
    {
    'title': 'Variable Declaration',
    'description': 'Practice declaring and using variables in Python',
    'starterCode': '# Declare variables of different types\nname = "Juan"\nage = 25\nheight = 5.8\nis_student = True\n\n# Print all variables\nprint("Name:", name)\nprint("Age:", age)\nprint("Height:", height)\nprint("Is Student:", is_student)',
    'solution': 'name = "Juan"\nage = 25\nheight = 5.8\nis_student = True\n\nprint("Name:", name)\nprint("Age:", age)\nprint("Height:", height)\nprint("Is Student:", is_student)',
    'testCases': ['Name: Juan', 'Age: 25', 'Height: 5.8', 'Is Student: True'],
    'hint': 'Python variables don\'t need type declaration. Use meaningful variable names.'
    },
    {
    'title': 'Multiple Assignment',
    'description': 'Assign multiple variables in a single line',
    'starterCode': '# Assign multiple variables at once\nx, y, z = 10, 20, 30\n\n# Print the values\nprint("x =", x)\nprint("y =", y)\nprint("z =", z)\n\n# Swap values\nx, y = y, x\nprint("After swap - x =", x, "y =", y)',
    'solution': 'x, y, z = 10, 20, 30\n\nprint("x =", x)\nprint("y =", y)\nprint("z =", z)\n\nx, y = y, x\nprint("After swap - x =", x, "y =", y)',
    'testCases': ['x = 10', 'y = 20', 'z = 30', 'After swap - x = 20 y = 10'],
    'hint': 'You can assign multiple variables in one line: a, b, c = 1, 2, 3'
    },
    {
    'title': 'Proper Indentation',
    'description': 'Practice Python\'s indentation rules',
    'starterCode': '# Fix the indentation errors in this code\n\ndef check_number(num):\nif num > 0:\nprint("Positive number")\nelif num == 0:\nprint("Zero")\nelse:\nprint("Negative number")\n\ncheck_number(5)\ncheck_number(-2)\ncheck_number(0)',
    'solution': 'def check_number(num):\n    if num > 0:\n        print("Positive number")\n    elif num == 0:\n        print("Zero")\n    else:\n        print("Negative number")\n\ncheck_number(5)\ncheck_number(-2)\ncheck_number(0)',
    'testCases': ['Positive number', 'Negative number', 'Zero'],
    'hint': 'Python uses 4 spaces for indentation. All code blocks must be properly indented.'
    },
    ];
    break;

    case 'Python Variables':
    _exercises = [
    {
    'title': 'Variable Types and Operations',
    'description': 'Work with different variable types and operations',
    'starterCode': '# Create variables of different types\nname = "Maria"\nage = 30\ntemperature = 36.6\nis_adult = True\n\n# String concatenation\ngreeting = "Hello, " + name + "!"\nprint(greeting)\n\n# Arithmetic with variables\nbirth_year = 2024 - age\nprint("Birth year:", birth_year)\n\n# Type conversion\nage_str = str(age)\nprint("Age as string: " + age_str)',
    'solution': 'name = "Maria"\nage = 30\ntemperature = 36.6\nis_adult = True\n\ngreeting = "Hello, " + name + "!"\nprint(greeting)\n\nbirth_year = 2024 - age\nprint("Birth year:", birth_year)\n\nage_str = str(age)\nprint("Age as string: " + age_str)',
    'testCases': ['Hello, Maria!', 'Birth year: 1994', 'Age as string: 30'],
    'hint': 'Use str() to convert numbers to strings for concatenation.'
    },
    {
    'title': 'Global vs Local Variables',
    'description': 'Understand variable scope in Python',
    'starterCode': '# Global variable\ncounter = 0\n\ndef increment():\n    # Local variable\n    local_count = 1\n    global counter\n    counter += local_count\n    print("Inside function - Local:", local_count, "Global:", counter)\n\nprint("Before function - Global:", counter)\nincrement()\nprint("After function - Global:", counter)',
    'solution': 'counter = 0\n\ndef increment():\n    local_count = 1\n    global counter\n    counter += local_count\n    print("Inside function - Local:", local_count, "Global:", counter)\n\nprint("Before function - Global:", counter)\nincrement()\nprint("After function - Global:", counter)',
    'testCases': ['Before function - Global: 0', 'Inside function - Local: 1 Global: 1', 'After function - Global: 1'],
    'hint': 'Use the global keyword to modify global variables inside functions.'
    },
    ];
    break;

    case 'Python Data Types':
    _exercises = [
    {
    'title': 'Working with Basic Data Types',
    'description': 'Practice using different Python data types',
    'starterCode': '# Different data types\ninteger_num = 42\nfloat_num = 3.14159\nstring_text = "Python Programming"\nboolean_val = False\nmy_list = [1, 2, 3, 4, 5]\nmy_dict = {"name": "Ana", "age": 28}\n\n# Print types and values\nprint("Type of integer_num:", type(integer_num), "Value:", integer_num)\nprint("Type of float_num:", type(float_num), "Value:", float_num)\nprint("Type of string_text:", type(string_text), "Value:", string_text)\nprint("Type of boolean_val:", type(boolean_val), "Value:", boolean_val)\nprint("Type of my_list:", type(my_list), "Value:", my_list)\nprint("Type of my_dict:", type(my_dict), "Value:", my_dict)',
    'solution': 'integer_num = 42\nfloat_num = 3.14159\nstring_text = "Python Programming"\nboolean_val = False\nmy_list = [1, 2, 3, 4, 5]\nmy_dict = {"name": "Ana", "age": 28}\n\nprint("Type of integer_num:", type(integer_num), "Value:", integer_num)\nprint("Type of float_num:", type(float_num), "Value:", float_num)\nprint("Type of string_text:", type(string_text), "Value:", string_text)\nprint("Type of boolean_val:", type(boolean_val), "Value:", boolean_val)\nprint("Type of my_list:", type(my_list), "Value:", my_list)\nprint("Type of my_dict:", type(my_dict), "Value:", my_dict)',
    'testCases': ['Type of integer_num:', 'Type of float_num:', 'Type of string_text:', 'Type of boolean_val:', 'Type of my_list:', 'Type of my_dict:'],
    'hint': 'Use type() function to check the data type of any variable.'
    },
    {
    'title': 'Type Conversion',
    'description': 'Convert between different data types',
    'starterCode': '# Type conversion examples\nnum_str = "123"\nnum_float = 45.67\nnum_int = 100\n\n# Convert string to integer\nstr_to_int = int(num_str)\nprint("String to integer:", str_to_int)\n\n# Convert float to integer\nfloat_to_int = int(num_float)\nprint("Float to integer:", float_to_int)\n\n# Convert integer to string\nint_to_str = str(num_int)\nprint("Integer to string:", "Number: " + int_to_str)\n\n# Convert to boolean\nzero_to_bool = bool(0)\none_to_bool = bool(1)\nprint("Boolean of 0:", zero_to_bool)\nprint("Boolean of 1:", one_to_bool)',
    'solution': 'num_str = "123"\nnum_float = 45.67\nnum_int = 100\n\nstr_to_int = int(num_str)\nprint("String to integer:", str_to_int)\n\nfloat_to_int = int(num_float)\nprint("Float to integer:", float_to_int)\n\nint_to_str = str(num_int)\nprint("Integer to string:", "Number: " + int_to_str)\n\nzero_to_bool = bool(0)\none_to_bool = bool(1)\nprint("Boolean of 0:", zero_to_bool)\nprint("Boolean of 1:", one_to_bool)',
    'testCases': ['String to integer: 123', 'Float to integer: 45', 'Integer to string: Number: 100', 'Boolean of 0: False', 'Boolean of 1: True'],
    'hint': 'Use int(), float(), str(), bool() for type conversion. Note: int() truncates decimals.'
    },
    ];
    break;

    case 'Python Strings':
    _exercises = [
    {
    'title': 'String Methods Practice',
    'description': 'Practice common string methods and operations',
    'starterCode': 'text = "  Hello World Programming  "\n\n# String methods\nprint("Original:", text)\nprint("Upper case:", text.upper())\nprint("Lower case:", text.lower())\nprint("Stripped:", text.strip())\nprint("Replace:", text.replace("World", "Python"))\nprint("Find \'World\':", text.find("World"))\nprint("Starts with Hello:", text.strip().startswith("Hello"))\n\n# String slicing\nprint("First 5 chars:", text.strip()[:5])\nprint("Last 3 chars:", text.strip()[-3:])',
    'solution': 'text = "  Hello World Programming  "\n\nprint("Original:", text)\nprint("Upper case:", text.upper())\nprint("Lower case:", text.lower())\nprint("Stripped:", text.strip())\nprint("Replace:", text.replace("World", "Python"))\nprint("Find \'World\':", text.find("World"))\nprint("Starts with Hello:", text.strip().startswith("Hello"))\n\nprint("First 5 chars:", text.strip()[:5])\nprint("Last 3 chars:", text.strip()[-3:])',
    'testCases': ['Original:   Hello World Programming  ', 'Upper case:   HELLO WORLD PROGRAMMING  ', 'Stripped: Hello World Programming', 'Find \'World\': 7'],
    'hint': 'strip() removes whitespace, find() returns index, replace() substitutes text.'
    },
    {
    'title': 'String Formatting',
    'description': 'Learn different ways to format strings',
    'starterCode': 'name = "Carlos"\nage = 35\nsalary = 50000.50\n\n# Different string formatting methods\n# 1. Using % operator\nprint("Name: %s, Age: %d" % (name, age))\n\n# 2. Using format() method\nprint("Name: {}, Age: {}, Salary: {:.2f}".format(name, age, salary))\n\n# 3. Using f-strings (Python 3.6+)\nprint(f"Name: {name}, Age: {age}, Salary: \${salary:.2f}")\n\n# String operations\nfull_name = name + " Garcia"\nprint("Full name:", full_name)\nprint("Name repeated 3 times:", name * 3)',
    'solution': 'name = "Carlos"\nage = 35\nsalary = 50000.50\n\nprint("Name: %s, Age: %d" % (name, age))\nprint("Name: {}, Age: {}, Salary: {:.2f}".format(name, age, salary))\nprint(f"Name: {name}, Age: {age}, Salary: \${salary:.2f}")\n\nfull_name = name + " Garcia"\nprint("Full name:", full_name)\nprint("Name repeated 3 times:", name * 3)',
    'testCases': ['Name: Carlos, Age: 35', 'Name: Carlos, Age: 35, Salary: 50000.50', 'Full name: Carlos Garcia', 'Name repeated 3 times: CarlosCarlosCarlos'],
    'hint': 'f-strings are the most modern and readable way to format strings in Python.'
    },
    ];
    break;

    case 'Python Operators':
    _exercises = [
    {
    'title': 'Arithmetic Operators',
    'description': 'Practice using arithmetic operators',
    'starterCode': 'a = 15\nb = 4\n\n# Arithmetic operations\nprint("a =", a, "b =", b)\nprint("Addition:", a + b)\nprint("Subtraction:", a - b)\nprint("Multiplication:", a * b)\nprint("Division:", a / b)\nprint("Floor Division:", a // b)\nprint("Modulus:", a % b)\nprint("Exponent:", a ** b)\n\n# Compound assignment\nc = 10\nc += 5  # Same as c = c + 5\nprint("After c += 5:", c)',
    'solution': 'a = 15\nb = 4\n\nprint("a =", a, "b =", b)\nprint("Addition:", a + b)\nprint("Subtraction:", a - b)\nprint("Multiplication:", a * b)\nprint("Division:", a / b)\nprint("Floor Division:", a // b)\nprint("Modulus:", a % b)\nprint("Exponent:", a ** b)\n\nc = 10\nc += 5\nprint("After c += 5:", c)',
    'testCases': ['a = 15 b = 4', 'Addition: 19', 'Division: 3.75', 'Floor Division: 3', 'Modulus: 3', 'After c += 5: 15'],
    'hint': '// gives integer division, % gives remainder, ** is exponentiation.'
    },
    {
    'title': 'Comparison and Logical Operators',
    'description': 'Use comparison and logical operators',
    'starterCode': 'x = 10\ny = 20\nz = 10\n\n# Comparison operators\nprint("x == y:", x == y)\nprint("x == z:", x == z)\nprint("x != y:", x != y)\nprint("x < y:", x < y)\nprint("x >= z:", x >= z)\n\n# Logical operators\nage = 25\nhas_license = True\n\nprint("Can drive:", age >= 18 and has_license)\nprint("Is teenager:", age >= 13 and age <= 19)\nprint("Is child or senior:", age < 13 or age >= 65)\nprint("Cannot drive:", not (age >= 18 and has_license))',
    'solution': 'x = 10\ny = 20\nz = 10\n\nprint("x == y:", x == y)\nprint("x == z:", x == z)\nprint("x != y:", x != y)\nprint("x < y:", x < y)\nprint("x >= z:", x >= z)\n\nage = 25\nhas_license = True\n\nprint("Can drive:", age >= 18 and has_license)\nprint("Is teenager:", age >= 13 and age <= 19)\nprint("Is child or senior:", age < 13 or age >= 65)\nprint("Cannot drive:", not (age >= 18 and has_license))',
    'testCases': ['x == y: False', 'x == z: True', 'x != y: True', 'x < y: True', 'Can drive: True', 'Is teenager: False'],
    'hint': 'and = both conditions True, or = at least one True, not = reverses Boolean.'
    },
    ];
    break;

    case 'Python Lists':
    _exercises = [
    {
    'title': 'List Methods and Operations',
    'description': 'Practice common list operations and methods',
    'starterCode': 'fruits = ["apple", "banana", "orange"]\nnumbers = [3, 1, 4, 1, 5, 9, 2]\n\n# List methods\nprint("Original fruits:", fruits)\nfruits.append("grape")\nprint("After append:", fruits)\n\nprint("Original numbers:", numbers)\nnumbers.sort()\nprint("After sort:", numbers)\n\n# List operations\nmixed_list = fruits + numbers\nprint("Combined list:", mixed_list)\n\n# Slicing\nprint("First two fruits:", fruits[:2])\nprint("Last fruit:", fruits[-1])\n\n# List comprehension\nsquares = [x**2 for x in range(1, 6)]\nprint("Squares:", squares)',
    'solution': 'fruits = ["apple", "banana", "orange"]\nnumbers = [3, 1, 4, 1, 5, 9, 2]\n\nprint("Original fruits:", fruits)\nfruits.append("grape")\nprint("After append:", fruits)\n\nprint("Original numbers:", numbers)\nnumbers.sort()\nprint("After sort:", numbers)\n\nmixed_list = fruits + numbers\nprint("Combined list:", mixed_list)\n\nprint("First two fruits:", fruits[:2])\nprint("Last fruit:", fruits[-1])\n\nsquares = [x**2 for x in range(1, 6)]\nprint("Squares:", squares)',
    'testCases': ['Original fruits: [\'apple\', \'banana\', \'orange\']', 'After append: [\'apple\', \'banana\', \'orange\', \'grape\']', 'After sort: [1, 1, 2, 3, 4, 5, 9]', 'Squares: [1, 4, 9, 16, 25]'],
    'hint': 'append() adds to end, sort() sorts in place, + concatenates lists, [:] slices lists.'
    },
    {
    'title': 'Advanced List Operations',
    'description': 'Work with more complex list operations',
    'starterCode': 'numbers = [10, 20, 30, 40, 50, 60]\n\n# List methods\nprint("Length:", len(numbers))\nprint("Max:", max(numbers))\nprint("Min:", min(numbers))\nprint("Sum:", sum(numbers))\n\n# Insert and remove\nnumbers.insert(2, 25)\nprint("After insert:", numbers)\n\nnumbers.remove(40)\nprint("After remove:", numbers)\n\n# Pop and index\npopped = numbers.pop()\nprint("Popped value:", popped)\nprint("After pop:", numbers)\n\nindex_30 = numbers.index(30)\nprint("Index of 30:", index_30)\n\n# Reverse\nnumbers.reverse()\nprint("Reversed:", numbers)',
    'solution': 'numbers = [10, 20, 30, 40, 50, 60]\n\nprint("Length:", len(numbers))\nprint("Max:", max(numbers))\nprint("Min:", min(numbers))\nprint("Sum:", sum(numbers))\n\nnumbers.insert(2, 25)\nprint("After insert:", numbers)\n\nnumbers.remove(40)\nprint("After remove:", numbers)\n\npopped = numbers.pop()\nprint("Popped value:", popped)\nprint("After pop:", numbers)\n\nindex_30 = numbers.index(30)\nprint("Index of 30:", index_30)\n\nnumbers.reverse()\nprint("Reversed:", numbers)',
    'testCases': ['Length: 6', 'Max: 60', 'Min: 10', 'Sum: 210', 'After insert: [10, 20, 25, 30, 40, 50, 60]', 'Index of 30: 3'],
    'hint': 'insert() adds at specific position, remove() deletes first occurrence, pop() removes and returns last element.'
    },
    ];
    break;

    case 'Python Tuples':
    _exercises = [
    {
    'title': 'Tuple Basics',
    'description': 'Learn tuple creation and basic operations',
    'starterCode': '# Tuple creation\ncolors = ("red", "green", "blue")\ncoordinates = (10, 20)\nmixed_tuple = (1, "hello", 3.14, True)\n\nprint("Colors tuple:", colors)\nprint("Coordinates:", coordinates)\nprint("Mixed tuple:", mixed_tuple)\n\n# Accessing elements\nprint("First color:", colors[0])\nprint("Last color:", colors[-1])\n\n# Tuple unpacking\nx, y = coordinates\nprint("Unpacked - x:", x, "y:", y)\n\n# Tuple operations\ncombined = colors + ("yellow", "purple")\nprint("Combined tuple:", combined)\nprint("Repeated tuple:", colors * 2)',
    'solution': 'colors = ("red", "green", "blue")\ncoordinates = (10, 20)\nmixed_tuple = (1, "hello", 3.14, True)\n\nprint("Colors tuple:", colors)\nprint("Coordinates:", coordinates)\nprint("Mixed tuple:", mixed_tuple)\n\nprint("First color:", colors[0])\nprint("Last color:", colors[-1])\n\nx, y = coordinates\nprint("Unpacked - x:", x, "y:", y)\n\ncombined = colors + ("yellow", "purple")\nprint("Combined tuple:", combined)\nprint("Repeated tuple:", colors * 2)',
    'testCases': ['Colors tuple: (\'red\', \'green\', \'blue\')', 'First color: red', 'Unpacked - x: 10 y: 20', 'Combined tuple: (\'red\', \'green\', \'blue\', \'yellow\', \'purple\')'],
    'hint': 'Tuples are immutable. Use parentheses or just commas to create tuples.'
    },
    {
    'title': 'Tuple Methods',
    'description': 'Practice tuple methods and immutability',
    'starterCode': 'numbers = (5, 2, 8, 2, 1, 2, 9, 2)\n\n# Tuple methods\nprint("Tuple:", numbers)\nprint("Count of 2:", numbers.count(2))\nprint("Index of 8:", numbers.index(8))\n\n# Tuple vs List demonstration\nmy_list = [1, 2, 3]\nmy_tuple = (1, 2, 3)\n\nprint("Original list:", my_list)\nmy_list[0] = 10\nprint("Modified list:", my_list)\n\nprint("Original tuple:", my_tuple)\n# my_tuple[0] = 10  # This would cause an error\n\n# Converting between list and tuple\nlist_from_tuple = list(my_tuple)\ntuple_from_list = tuple(my_list)\nprint("List from tuple:", list_from_tuple)\nprint("Tuple from list:", tuple_from_list)',
    'solution': 'numbers = (5, 2, 8, 2, 1, 2, 9, 2)\n\nprint("Tuple:", numbers)\nprint("Count of 2:", numbers.count(2))\nprint("Index of 8:", numbers.index(8))\n\nmy_list = [1, 2, 3]\nmy_tuple = (1, 2, 3)\n\nprint("Original list:", my_list)\nmy_list[0] = 10\nprint("Modified list:", my_list)\n\nprint("Original tuple:", my_tuple)\n\nlist_from_tuple = list(my_tuple)\ntuple_from_list = tuple(my_list)\nprint("List from tuple:", list_from_tuple)\nprint("Tuple from list:", tuple_from_list)',
    'testCases': ['Tuple: (5, 2, 8, 2, 1, 2, 9, 2)', 'Count of 2: 4', 'Index of 8: 2', 'Modified list: [10, 2, 3]'],
    'hint': 'Tuples have count() and index() methods. They are immutable unlike lists.'
    },
    ];
    break;

    case 'Python Sets':
    _exercises = [
    {
    'title': 'Set Operations',
    'description': 'Learn set creation and basic operations',
    'starterCode': 'set1 = {1, 2, 3, 4, 5}\nset2 = {4, 5, 6, 7, 8}\n\nprint("Set 1:", set1)\nprint("Set 2:", set2)\n\n# Set operations\nprint("Union:", set1 | set2)\nprint("Intersection:", set1 & set2)\nprint("Difference (set1 - set2):", set1 - set2)\nprint("Symmetric Difference:", set1 ^ set2)\n\n# Set methods\nset1.add(6)\nprint("After add 6:", set1)\n\nset1.remove(1)\nprint("After remove 1:", set1)\n\n# Membership test\nprint("Is 3 in set1?", 3 in set1)\nprint("Is 9 in set1?", 9 in set1)',
    'solution': 'set1 = {1, 2, 3, 4, 5}\nset2 = {4, 5, 6, 7, 8}\n\nprint("Set 1:", set1)\nprint("Set 2:", set2)\n\nprint("Union:", set1 | set2)\nprint("Intersection:", set1 & set2)\nprint("Difference (set1 - set2):", set1 - set2)\nprint("Symmetric Difference:", set1 ^ set2)\n\nset1.add(6)\nprint("After add 6:", set1)\n\nset1.remove(1)\nprint("After remove 1:", set1)\n\nprint("Is 3 in set1?", 3 in set1)\nprint("Is 9 in set1?", 9 in set1)',
    'testCases': ['Set 1: {1, 2, 3, 4, 5}', 'Union: {1, 2, 3, 4, 5, 6, 7, 8}', 'Intersection: {4, 5}', 'Is 3 in set1? True'],
    'hint': 'Sets are unordered and contain unique elements. | for union, & for intersection, - for difference.'
    },
    {
    'title': 'Set Methods',
    'description': 'Practice set methods and use cases',
    'starterCode': 'fruits = {"apple", "banana", "orange", "grape"}\ncitrus = {"orange", "lemon", "lime"}\ntropical = {"banana", "mango", "pineapple"}\n\nprint("All fruits:", fruits)\nprint("Citrus fruits:", citrus)\nprint("Tropical fruits:", tropical)\n\n# Set methods\nfruits.add("pear")\nprint("After adding pear:", fruits)\n\nfruits.discard("apple")\nprint("After discarding apple:", fruits)\n\n# Update with another set\nfruits.update(citrus)\nprint("After update with citrus:", fruits)\n\n# Set comparisons\nprint("Is citrus subset of fruits?", citrus.issubset(fruits))\nprint("Do fruits and tropical have intersection?", fruits.isdisjoint(tropical))\n\n# Clear set\ncitrus.clear()\nprint("Citrus after clear:", citrus)',
    'solution': 'fruits = {"apple", "banana", "orange", "grape"}\ncitrus = {"orange", "lemon", "lime"}\ntropical = {"banana", "mango", "pineapple"}\n\nprint("All fruits:", fruits)\nprint("Citrus fruits:", citrus)\nprint("Tropical fruits:", tropical)\n\nfruits.add("pear")\nprint("After adding pear:", fruits)\n\nfruits.discard("apple")\nprint("After discarding apple:", fruits)\n\nfruits.update(citrus)\nprint("After update with citrus:", fruits)\n\nprint("Is citrus subset of fruits?", citrus.issubset(fruits))\nprint("Do fruits and tropical have intersection?", fruits.isdisjoint(tropical))\n\ncitrus.clear()\nprint("Citrus after clear:", citrus)',
    'testCases': ['All fruits: {\'apple\', \'banana\', \'orange\', \'grape\'}', 'After adding pear:', 'After update with citrus:', 'Is citrus subset of fruits? False'],
    'hint': 'discard() removes element safely, update() adds multiple elements, issubset() checks if all elements are in another set.'
    },
    ];
    break;

    case 'Python Dictionaries':
    _exercises = [
    {
    'title': 'Dictionary Basics',
    'description': 'Learn dictionary creation and access',
    'starterCode': 'student = {\n    "name": "Juan",\n    "age": 20,\n    "major": "Computer Science",\n    "gpa": 3.8\n}\n\nprint("Student dictionary:", student)\n\n# Accessing values\nprint("Name:", student["name"])\nprint("Age:", student.get("age"))\n\n# Safe access with get\nprint("Grade:", student.get("grade", "Not assigned"))\n\n# Keys and values\nprint("Keys:", list(student.keys()))\nprint("Values:", list(student.values()))\n\n# Adding and modifying\nstudent["year"] = "Junior"\nstudent["gpa"] = 3.9\nprint("Updated student:", student)',
    'solution': 'student = {\n    "name": "Juan",\n    "age": 20,\n    "major": "Computer Science",\n    "gpa": 3.8\n}\n\nprint("Student dictionary:", student)\n\nprint("Name:", student["name"])\nprint("Age:", student.get("age"))\n\nprint("Grade:", student.get("grade", "Not assigned"))\n\nprint("Keys:", list(student.keys()))\nprint("Values:", list(student.values()))\n\nstudent["year"] = "Junior"\nstudent["gpa"] = 3.9\nprint("Updated student:", student)',
    'testCases': ['Student dictionary:', 'Name: Juan', 'Age: 20', 'Grade: Not assigned', 'Keys: [\'name\', \'age\', \'major\', \'gpa\']'],
    'hint': 'Use [] to access keys, get() for safe access with default value. keys() and values() return view objects.'
    },
    {
    'title': 'Dictionary Methods',
    'description': 'Practice dictionary methods and operations',
    'starterCode': 'inventory = {\n    "apples": 10,\n    "bananas": 15,\n    "oranges": 8,\n    "grapes": 20\n}\n\nprint("Inventory:", inventory)\n\n# Dictionary methods\nprint("Items:", list(inventory.items()))\n\n# Update dictionary\ninventory.update({"apples": 12, "pears": 5})\nprint("After update:", inventory)\n\n# Pop and popitem\nbanana_count = inventory.pop("bananas")\nprint("Removed bananas count:", banana_count)\nprint("After pop:", inventory)\n\nlast_item = inventory.popitem()\nprint("Removed last item:", last_item)\nprint("After popitem:", inventory)\n\n# Dictionary comprehension\nsquared = {x: x**2 for x in range(1, 6)}\nprint("Squared dictionary:", squared)',
    'solution': 'inventory = {\n    "apples": 10,\n    "bananas": 15,\n    "oranges": 8,\n    "grapes": 20\n}\n\nprint("Inventory:", inventory)\n\nprint("Items:", list(inventory.items()))\n\ninventory.update({"apples": 12, "pears": 5})\nprint("After update:", inventory)\n\nbanana_count = inventory.pop("bananas")\nprint("Removed bananas count:", banana_count)\nprint("After pop:", inventory)\n\nlast_item = inventory.popitem()\nprint("Removed last item:", last_item)\nprint("After popitem:", inventory)\n\nsquared = {x: x**2 for x in range(1, 6)}\nprint("Squared dictionary:", squared)',
    'testCases': ['Inventory: {\'apples\': 10, \'bananas\': 15, \'oranges\': 8, \'grapes\': 20}', 'Removed bananas count: 15', 'Squared dictionary: {1: 1, 2: 4, 3: 9, 4: 16, 5: 25}'],
    'hint': 'update() merges dictionaries, pop() removes specific key, popitem() removes last inserted item.'
    },
    ];
    break;

    case 'Python Conditions':
    _exercises = [
    {
    'title': 'If-Else Statements',
    'description': 'Practice conditional statements',
    'starterCode': 'age = 18\ntemperature = 25\nscore = 85\n\n# Basic if-elif-else\nif age >= 18:\n    print("Adult")\nelif age >= 13:\n    print("Teenager")\nelse:\n    print("Child")\n\n# Nested conditions\nif temperature > 30:\n    print("Hot day")\n    if temperature > 40:\n        print("Very hot! Stay indoors")\nelif temperature > 20:\n    print("Pleasant day")\nelse:\n    print("Cold day")\n\n# Multiple conditions\nif score >= 90:\n    grade = "A"\nelif score >= 80:\n    grade = "B"\nelif score >= 70:\n    grade = "C"\nelif score >= 60:\n    grade = "D"\nelse:\n    grade = "F"\n\nprint(f"Score: {score}, Grade: {grade}")',
    'solution': 'age = 18\ntemperature = 25\nscore = 85\n\nif age >= 18:\n    print("Adult")\nelif age >= 13:\n    print("Teenager")\nelse:\n    print("Child")\n\nif temperature > 30:\n    print("Hot day")\n    if temperature > 40:\n        print("Very hot! Stay indoors")\nelif temperature > 20:\n    print("Pleasant day")\nelse:\n    print("Cold day")\n\nif score >= 90:\n    grade = "A"\nelif score >= 80:\n    grade = "B"\nelif score >= 70:\n    grade = "C"\nelif score >= 60:\n    grade = "D"\nelse:\n    grade = "F"\n\nprint(f"Score: {score}, Grade: {grade}")',
    'testCases': ['Adult', 'Pleasant day', 'Score: 85, Grade: B'],
    'hint': 'Use if, elif, else for multiple conditions. Conditions are evaluated in order.'
    },
    {
    'title': 'Complex Conditions',
    'description': 'Work with complex conditional logic',
    'starterCode': 'weather = "sunny"\ntemperature = 28\nis_weekend = True\nhas_umbrella = False\n\n# Complex conditions\nif weather == "rainy" and not has_umbrella:\n    print("Stay indoors")\nelif weather == "sunny" and temperature > 25:\n    print("Perfect beach day!")\n    if is_weekend:\n        print("Even better - it\'s weekend!")\nelse:\n    print("Normal day")\n\n# Ternary operator\nmood = "happy" if is_weekend else "tired"\nprint("Mood:", mood)\n\n# Multiple logical operators\nage = 25\nhas_license = True\nhas_car = False\n\nif (age >= 18 and has_license) or has_car:\n    print("Can drive")\nelse:\n    print("Cannot drive")',
    'solution': 'weather = "sunny"\ntemperature = 28\nis_weekend = True\nhas_umbrella = False\n\nif weather == "rainy" and not has_umbrella:\n    print("Stay indoors")\nelif weather == "sunny" and temperature > 25:\n    print("Perfect beach day!")\n    if is_weekend:\n        print("Even better - it\'s weekend!")\nelse:\n    print("Normal day")\n\nmood = "happy" if is_weekend else "tired"\nprint("Mood:", mood)\n\nage = 25\nhas_license = True\nhas_car = False\n\nif (age >= 18 and has_license) or has_car:\n    print("Can drive")\nelse:\n    print("Cannot drive")',
    'testCases': ['Perfect beach day!', 'Even better - it\'s weekend!', 'Mood: happy', 'Can drive'],
    'hint': 'Use and, or, not for complex conditions. Ternary: value_if_true if condition else value_if_false'
    },
    ];
    break;

    case 'Python Loops':
    _exercises = [
    {
    'title': 'For Loops',
    'description': 'Practice for loops with different iterables',
    'starterCode': 'fruits = ["apple", "banana", "cherry", "date"]\n\n# Basic for loop\nprint("Fruits:")\nfor fruit in fruits:\n    print("-", fruit)\n\n# For loop with range\nprint("\\nNumbers 1 to 5:")\nfor i in range(1, 6):\n    print(i)\n\n# For loop with index\nprint("\\nFruits with index:")\nfor index, fruit in enumerate(fruits):\n    print(f"{index + 1}. {fruit}")\n\n# Nested for loops\nprint("\\nMultiplication table (1-3):")\nfor i in range(1, 4):\n    for j in range(1, 4):\n        print(f"{i} x {j} = {i * j}")',
    'solution': 'fruits = ["apple", "banana", "cherry", "date"]\n\nprint("Fruits:")\nfor fruit in fruits:\n    print("-", fruit)\n\nprint("\\nNumbers 1 to 5:")\nfor i in range(1, 6):\n    print(i)\n\nprint("\\nFruits with index:")\nfor index, fruit in enumerate(fruits):\n    print(f"{index + 1}. {fruit}")\n\nprint("\\nMultiplication table (1-3):")\nfor i in range(1, 4):\n    for j in range(1, 4):\n        print(f"{i} x {j} = {i * j}")',
    'testCases': ['Fruits:', '- apple', '- banana', '- cherry', '- date', 'Numbers 1 to 5:', '1', '2', '3', '4', '5'],
    'hint': 'range(start, stop) generates numbers, enumerate() gives index and value, nested loops work inside each other.'
    },
    {
    'title': 'While Loops and Control Statements',
    'description': 'Practice while loops and loop control statements',
    'starterCode': 'count = 1\n\n# While loop\nprint("Counting 1 to 5:")\nwhile count <= 5:\n    print(count)\n    count += 1\n\n# Break statement\nprint("\\nBreak example:")\nfor i in range(1, 10):\n    if i == 6:\n        break\n    print(i)\n\n# Continue statement\nprint("\\nContinue example (odd numbers):")\nfor i in range(1, 10):\n    if i % 2 == 0:\n        continue\n    print(i)\n\n# While with user input simulation\nprint("\\nGuessing game simulation:")\ntarget = 7\nguess = 0\nattempts = 0\n\nwhile guess != target:\n    attempts += 1\n    guess = attempts  # Simulating user input\n    if guess < target:\n        print(f"Attempt {attempts}: Too low")\n    elif guess > target:\n        print(f"Attempt {attempts}: Too high")\n    else:\n        print(f"Attempt {attempts}: Correct! The number was {target}")',
    'solution': 'count = 1\n\nprint("Counting 1 to 5:")\nwhile count <= 5:\n    print(count)\n    count += 1\n\nprint("\\nBreak example:")\nfor i in range(1, 10):\n    if i == 6:\n        break\n    print(i)\n\nprint("\\nContinue example (odd numbers):")\nfor i in range(1, 10):\n    if i % 2 == 0:\n        continue\n    print(i)\n\nprint("\\nGuessing game simulation:")\ntarget = 7\nguess = 0\nattempts = 0\n\nwhile guess != target:\n    attempts += 1\n    guess = attempts\n    if guess < target:\n        print(f"Attempt {attempts}: Too low")\n    elif guess > target:\n        print(f"Attempt {attempts}: Too high")\n    else:\n        print(f"Attempt {attempts}: Correct! The number was {target}")',
    'testCases': ['Counting 1 to 5:', '1', '2', '3', '4', '5', 'Break example:', '1', '2', '3', '4', '5', 'Continue example (odd numbers):', '1', '3', '5', '7', '9'],
    'hint': 'break exits loop completely, continue skips to next iteration. while loops need condition to become False to stop.'
    },
    ];
    break;

    case 'Python Functions':
    _exercises = [
    {
    'title': 'Function Definition and Parameters',
    'description': 'Learn to define functions with different parameters',
    'starterCode': '# Basic function\ndef greet(name):\n    return f"Hello, {name}!\"\n\n# Function with multiple parameters\ndef add_numbers(a, b):\n    return a + b\n\n# Function with default parameter\ndef introduce(name, age=25):\n    return f"My name is {name} and I am {age} years old.\"\n\n# Calling functions\nprint(greet("Alice"))\nprint("Sum:", add_numbers(5, 3))\nprint(introduce("Bob"))\nprint(introduce("Charlie", 30))\n\n# Function that returns multiple values\ndef calculate_rectangle(length, width):\n    area = length * width\n    perimeter = 2 * (length + width)\n    return area, perimeter\n\narea, perimeter = calculate_rectangle(5, 3)\nprint(f"Rectangle - Area: {area}, Perimeter: {perimeter}")',
    'solution': 'def greet(name):\n    return f"Hello, {name}!\"\n\ndef add_numbers(a, b):\n    return a + b\n\ndef introduce(name, age=25):\n    return f"My name is {name} and I am {age} years old.\"\n\nprint(greet("Alice"))\nprint("Sum:", add_numbers(5, 3))\nprint(introduce("Bob"))\nprint(introduce("Charlie", 30))\n\ndef calculate_rectangle(length, width):\n    area = length * width\n    perimeter = 2 * (length + width)\n    return area, perimeter\n\narea, perimeter = calculate_rectangle(5, 3)\nprint(f"Rectangle - Area: {area}, Perimeter: {perimeter}")',
    'testCases': ['Hello, Alice!', 'Sum: 8', 'My name is Bob and I am 25 years old.', 'My name is Charlie and I am 30 years old.', 'Rectangle - Area: 15, Perimeter: 16'],
    'hint': 'Use def to define functions. Default parameters must come after required parameters. Functions can return multiple values as tuples.'
    },
    {
    'title': 'Advanced Function Concepts',
    'description': 'Practice with variable arguments and scope',
    'starterCode': '# Variable arguments\ndef calculate_average(*numbers):\n    if len(numbers) == 0:\n        return 0\n    return sum(numbers) / len(numbers)\n\n# Keyword arguments\ndef create_profile(name, **details):\n    profile = f"Profile: {name}\"\n    for key, value in details.items():\n        profile += f", {key}: {value}"\n    return profile\n\n# Lambda functions\nsquare = lambda x: x ** 2\nis_even = lambda x: x % 2 == 0\n\n# Using the functions\nprint("Average:", calculate_average(10, 20, 30, 40))\nprint("Average of empty:", calculate_average())\n\nprint(create_profile("Maria", age=28, city="Madrid", occupation="Engineer"))\n\nprint("Square of 5:", square(5))\nprint("Is 4 even?", is_even(4))\nprint("Is 7 even?", is_even(7))\n\n# Using lambda with map and filter\nnumbers = [1, 2, 3, 4, 5, 6]\nsquared_numbers = list(map(lambda x: x**2, numbers))\neven_numbers = list(filter(lambda x: x % 2 == 0, numbers))\n\nprint("Original numbers:", numbers)\nprint("Squared numbers:", squared_numbers)\nprint("Even numbers:", even_numbers)',
    'solution': 'def calculate_average(*numbers):\n    if len(numbers) == 0:\n        return 0\n    return sum(numbers) / len(numbers)\n\ndef create_profile(name, **details):\n    profile = f"Profile: {name}\"\n    for key, value in details.items():\n        profile += f", {key}: {value}"\n    return profile\n\nsquare = lambda x: x ** 2\nis_even = lambda x: x % 2 == 0\n\nprint("Average:", calculate_average(10, 20, 30, 40))\nprint("Average of empty:", calculate_average())\n\nprint(create_profile("Maria", age=28, city="Madrid", occupation="Engineer"))\n\nprint("Square of 5:", square(5))\nprint("Is 4 even?", is_even(4))\nprint("Is 7 even?", is_even(7))\n\nnumbers = [1, 2, 3, 4, 5, 6]\nsquared_numbers = list(map(lambda x: x**2, numbers))\neven_numbers = list(filter(lambda x: x % 2 == 0, numbers))\n\nprint("Original numbers:", numbers)\nprint("Squared numbers:", squared_numbers)\nprint("Even numbers:", even_numbers)',
    'testCases': ['Average: 25.0', 'Average of empty: 0', 'Profile: Maria, age: 28, city: Madrid, occupation: Engineer', 'Square of 5: 25', 'Is 4 even? True', 'Is 7 even? False', 'Squared numbers: [1, 4, 9, 16, 25, 36]', 'Even numbers: [2, 4, 6]'],
    'hint': '*args collects positional arguments, **kwargs collects keyword arguments. Lambda functions are anonymous functions.'
    },
    ];
    break;

    case 'Python Classes':
    _exercises = [
    {
    'title': 'Class Definition and Objects',
    'description': 'Learn to define classes and create objects',
    'starterCode': 'class Person:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n    \n    def greet(self):\n        return f"Hello, I\'m {self.name} and I\'m {self.age} years old.\"\n    \n    def have_birthday(self):\n        self.age += 1\n        return f"Happy birthday! Now I\'m {self.age} years old.\"\n\n# Creating objects\nperson1 = Person("Alice", 25)\nperson2 = Person("Bob", 30)\n\n# Using object methods\nprint(person1.greet())\nprint(person2.greet())\n\nprint(person1.have_birthday())\nprint(person1.greet())\n\n# Accessing attributes\nprint(f"{person2.name} is {person2.age} years old")',
    'solution': 'class Person:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n    \n    def greet(self):\n        return f"Hello, I\'m {self.name} and I\'m {self.age} years old.\"\n    \n    def have_birthday(self):\n        self.age += 1\n        return f"Happy birthday! Now I\'m {self.age} years old.\"\n\nperson1 = Person("Alice", 25)\nperson2 = Person("Bob", 30)\n\nprint(person1.greet())\nprint(person2.greet())\n\nprint(person1.have_birthday())\nprint(person1.greet())\n\nprint(f"{person2.name} is {person2.age} years old")',
    'testCases': ['Hello, I\'m Alice and I\'m 25 years old.', 'Hello, I\'m Bob and I\'m 30 years old.', 'Happy birthday! Now I\'m 26 years old.', 'Hello, I\'m Alice and I\'m 26 years old.', 'Bob is 30 years old'],
    'hint': '__init__ is the constructor. self refers to the instance. Methods are functions defined inside classes.'
    },
    {
    'title': 'Inheritance and Special Methods',
    'description': 'Practice class inheritance and special methods',
    'starterCode': 'class Animal:\n    def __init__(self, name, species):\n        self.name = name\n        self.species = species\n    \n    def speak(self):\n        return "Some generic animal sound"\n    \n    def __str__(self):\n        return f"{self.name} the {self.species}"\n\nclass Dog(Animal):\n    def __init__(self, name, breed):\n        super().__init__(name, "Dog")\n        self.breed = breed\n    \n    def speak(self):\n        return "Woof!"\n    \n    def __str__(self):\n        return f"{self.name} the {self.breed} {self.species}"\n\nclass Cat(Animal):\n    def __init__(self, name, color):\n        super().__init__(name, "Cat")\n        self.color = color\n    \n    def speak(self):\n        return "Meow!"\n\n# Using the classes\ndog = Dog("Buddy", "Golden Retriever")\ncat = Cat("Whiskers", "Orange")\n\nprint(dog)\nprint(cat)\n\nprint(f"{dog.name} says: {dog.speak()}")\nprint(f"{cat.name} says: {cat.speak()}")\n\n# Polymorphism\nanimals = [dog, cat]\nfor animal in animals:\n    print(f"{animal.name} makes sound: {animal.speak()}")',
    'solution': 'class Animal:\n    def __init__(self, name, species):\n        self.name = name\n        self.species = species\n    \n    def speak(self):\n        return "Some generic animal sound"\n    \n    def __str__(self):\n        return f"{self.name} the {self.species}"\n\nclass Dog(Animal):\n    def __init__(self, name, breed):\n        super().__init__(name, "Dog")\n        self.breed = breed\n    \n    def speak(self):\n        return "Woof!"\n    \n    def __str__(self):\n        return f"{self.name} the {self.breed} {self.species}"\n\nclass Cat(Animal):\n    def __init__(self, name, color):\n        super().__init__(name, "Cat")\n        self.color = color\n    \n    def speak(self):\n        return "Meow!"\n\ndog = Dog("Buddy", "Golden Retriever")\ncat = Cat("Whiskers", "Orange")\n\nprint(dog)\nprint(cat)\n\nprint(f"{dog.name} says: {dog.speak()}")\nprint(f"{cat.name} says: {cat.speak()}")\n\nanimals = [dog, cat]\nfor animal in animals:\n    print(f"{animal.name} makes sound: {animal.speak()}")',
    'testCases': ['Buddy the Golden Retriever Dog', 'Whiskers the Cat', 'Buddy says: Woof!', 'Whiskers says: Meow!', 'Buddy makes sound: Woof!', 'Whiskers makes sound: Meow!'],
    'hint': 'Use super() to call parent class methods. __str__ defines string representation. Inheritance allows method overriding.'
    },
    ];
    break;

    case 'Python Modules':
    _exercises = [
    {
    'title': 'Importing and Using Modules',
    'description': 'Practice importing and using Python modules',
    'starterCode': '# Math module\nimport math\n\nprint("Math functions:")\nprint("Square root of 16:", math.sqrt(16))\nprint("Pi:", math.pi)\nprint("Cosine of 60 degrees:", math.cos(math.radians(60)))\nprint("Factorial of 5:", math.factorial(5))\n\n# Random module\nimport random\n\nprint("\\nRandom numbers:")\nprint("Random float between 0-1:", random.random())\nprint("Random integer 1-10:", random.randint(1, 10))\nprint("Random choice from list:", random.choice(["apple", "banana", "cherry"]))\n\n# Datetime module\nfrom datetime import datetime, date\n\nprint("\\nDate and time:")\ncurrent_time = datetime.now()\nprint("Current datetime:", current_time)\nprint("Formatted date:", current_time.strftime("%Y-%m-%d"))\nprint("Day of week:", current_time.strftime("%A"))\n\ntoday = date.today()\nprint("Today\'s date:", today)',
    'solution': 'import math\n\nprint("Math functions:")\nprint("Square root of 16:", math.sqrt(16))\nprint("Pi:", math.pi)\nprint("Cosine of 60 degrees:", math.cos(math.radians(60)))\nprint("Factorial of 5:", math.factorial(5))\n\nimport random\n\nprint("\\nRandom numbers:")\nprint("Random float between 0-1:", random.random())\nprint("Random integer 1-10:", random.randint(1, 10))\nprint("Random choice from list:", random.choice(["apple", "banana", "cherry"]))\n\nfrom datetime import datetime, date\n\nprint("\\nDate and time:")\ncurrent_time = datetime.now()\nprint("Current datetime:", current_time)\nprint("Formatted date:", current_time.strftime("%Y-%m-%d"))\nprint("Day of week:", current_time.strftime("%A"))\n\ntoday = date.today()\nprint("Today\'s date:", today)',
    'testCases': ['Math functions:', 'Square root of 16: 4.0', 'Pi: 3.141592653589793', 'Factorial of 5: 120', 'Random numbers:', 'Date and time:'],
    'hint': 'Use import module or from module import function. math for math operations, random for randomness, datetime for dates.'
    },
    {
    'title': 'Creating and Using Custom Modules',
    'description': 'Practice creating and using your own modules',
    'starterCode': '# In a real scenario, this would be in a separate file\n# For this exercise, we\'ll define the functions here\n\ndef calculate_circle_area(radius):\n    \"\"\"Calculate area of a circle\"\"\"\n    import math\n    return math.pi * radius ** 2\n\ndef calculate_circle_circumference(radius):\n    \"\"\"Calculate circumference of a circle\"\"\"\n    import math\n    return 2 * math.pi * radius\n\ndef is_prime(number):\n    \"\"\"Check if a number is prime\"\"\"\n    if number < 2:\n        return False\n    for i in range(2, int(number ** 0.5) + 1):\n        if number % i == 0:\n            return False\n    return True\n\n# Using our "module" functions\nprint("Circle calculations:")\nradius = 5\nprint(f"Radius: {radius}")\nprint(f"Area: {calculate_circle_area(radius):.2f}")\nprint(f"Circumference: {calculate_circle_circumference(radius):.2f}")\n\nprint("\\nPrime number check:")\nnumbers = [2, 3, 4, 5, 17, 18, 19]\nfor num in numbers:\n    prime_status = "prime" if is_prime(num) else "not prime"\n    print(f"{num} is {prime_status}")',
    'solution': 'def calculate_circle_area(radius):\n    import math\n    return math.pi * radius ** 2\n\ndef calculate_circle_circumference(radius):\n    import math\n    return 2 * math.pi * radius\n\ndef is_prime(number):\n    if number < 2:\n        return False\n    for i in range(2, int(number ** 0.5) + 1):\n        if number % i == 0:\n            return False\n    return True\n\nprint("Circle calculations:")\nradius = 5\nprint(f"Radius: {radius}")\nprint(f"Area: {calculate_circle_area(radius):.2f}")\nprint(f"Circumference: {calculate_circle_circumference(radius):.2f}")\n\nprint("\\nPrime number check:")\nnumbers = [2, 3, 4, 5, 17, 18, 19]\nfor num in numbers:\n    prime_status = "prime" if is_prime(num) else "not prime"\n    print(f"{num} is {prime_status}")',
    'testCases': ['Circle calculations:', 'Radius: 5', 'Area: 78.54', 'Circumference: 31.42', 'Prime number check:', '2 is prime', '3 is prime', '4 is not prime', '5 is prime', '17 is prime', '18 is not prime', '19 is prime'],
    'hint': 'In real projects, put related functions in separate .py files and import them. Use docstrings to document functions.'
    },
    ];
    break;

    default:
    _exercises = [
    {
    'title': 'Basic Python Exercise',
    'description': 'A simple Python exercise to get started',
    'starterCode': '# Welcome to Python Practice!\n# Write a program that calculates the area of a rectangle\n\nlength = 10\nwidth = 5\n\n# Calculate area\narea = length * width\n\n# Print the result\nprint("The area is:", area)',
    'solution': 'length = 10\nwidth = 5\narea = length * width\nprint("The area is:", area)',
    'testCases': ['The area is: 50'],
    'hint': 'Area of rectangle = length × width'
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

    if (allTestsPassed) {
      _output += '\n🎉 All tests passed! Excellent work!';
    } else {
      _output += '\n❌ Some tests failed. Expected to see:';
      for (String testCase in testCases) {
        _output += '\n• $testCase';
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