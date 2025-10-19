# C++ Files Handling

## Reading Files
```cpp
#include <fstream>
ifstream file("file.txt");
string line;

while (getline(file, line)) {
    cout << line << endl;
}
file.close();
