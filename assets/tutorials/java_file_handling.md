# Java File Handling

## Reading Files
```java
File file = new File("file.txt");
Scanner scanner = new Scanner(file);

while (scanner.hasNextLine()) {
    String data = scanner.nextLine();
}

boolean exists = file.exists();
boolean isFile = file.isFile();
boolean isDirectory = file.isDirectory();
long fileSize = file.length();
