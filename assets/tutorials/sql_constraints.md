# SQL Constraints

## Common Constraints
```sql
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    salary DECIMAL(10,2) CHECK (salary > 0),
    dept_id INT FOREIGN KEY REFERENCES departments(id)
);

-- Add constraints later
ALTER TABLE employees 
ADD CONSTRAINT chk_salary CHECK (salary > 0);
