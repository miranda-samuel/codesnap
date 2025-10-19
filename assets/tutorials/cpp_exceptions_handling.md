# C++ Exceptions Handling

## Try-Catch
```cpp
try {
    if (x == 0) throw runtime_error("Division by zero");
    int result = 10 / x;
} catch (const exception& e) {
    cout << "Error: " << e.what();
}
