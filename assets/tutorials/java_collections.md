---

### **13. java_collections.md**
```markdown
# Java Collections

## ArrayList
```java
import java.util.ArrayList;

ArrayList<String> cars = new ArrayList<>();
cars.add("Volvo");
cars.add("BMW");
cars.add("Ford");

// Access elements
String firstCar = cars.get(0);

// Remove elements
cars.remove(1);

// Size
int size = cars.size();

// Iteration
for (String car : cars) {
System.out.println(car);
}