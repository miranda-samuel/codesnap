# Java Multithreading

## Thread Creation
```java
Thread thread = new Thread(() -> {
    System.out.println("Running in thread");
});
thread.start();
