
---

### **11. java_oop.md**
```markdown
# Java Object-Oriented Programming

## Class and Object
```java
// Class definition
public class Car {
    // Fields (attributes)
    String brand;
    String model;
    int year;
    
    // Method
    public void displayInfo() {
        System.out.println(brand + " " + model + " " + year);
    }
}

// Creating objects
Car car1 = new Car();
car1.brand = "Toyota";
car1.model = "Corolla";
car1.year = 2020;
car1.displayInfo();