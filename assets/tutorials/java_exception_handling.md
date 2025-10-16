
---

### **12. java_exception_handling.md**
```markdown
# Java Exception Handling

## Try-Catch Block
```java
try {
    // Code that might throw exception
    int result = 10 / 0;
} catch (ArithmeticException e) {
    System.out.println("Cannot divide by zero: " + e.getMessage());
}