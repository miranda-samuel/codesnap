
---

### **12. cpp_pointers.md**
```markdown
# C++ Pointers

## Pointer Basics
```cpp
int var = 5;
int* ptr = &var;  // ptr stores address of var

cout << var << endl;   // Value of var (5)
cout << &var << endl;  // Address of var
cout << ptr << endl;   // Address stored in ptr
cout << *ptr << endl;  // Value at address (5)