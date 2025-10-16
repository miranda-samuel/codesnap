
---

### **14. java_file_handling.md**
```markdown
# Java File Handling

## File Class
```java
import java.io.File;

File file = new File("filename.txt");

// Check file properties
boolean exists = file.exists();
boolean isFile = file.isFile();
boolean isDirectory = file.isDirectory();
long fileSize = file.length();