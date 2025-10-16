
---

### **15. java_multithreading.md**
```markdown
# Java Multithreading

## Thread Creation by Extending Thread Class
```java
class MyThread extends Thread {
    public void run() {
        System.out.println("Thread is running: " + Thread.currentThread().getName());
    }
}

// Usage
MyThread thread1 = new MyThread();
thread1.start();