
---

### **14. cpp_exceptions.md**
```markdown
# C++ Exceptions

## Basic Exception Handling
```cpp
try {
    // Code that might throw an exception
    if (errorCondition) {
        throw runtime_error("Error message");
    }
} catch (const exception& e) {
    cout << "Exception caught: " << e.what() << endl;
}