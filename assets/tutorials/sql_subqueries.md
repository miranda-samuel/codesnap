# SQL Subqueries

## Subquery Types
```sql
-- Subquery in WHERE clause
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Subquery in FROM clause
SELECT dept_name, avg_salary
FROM (SELECT d.name as dept_name, AVG(e.salary) as avg_salary
      FROM employees e 
      JOIN departments d ON e.dept_id = d.id
      GROUP BY d.name) as dept_stats;

-- Correlated subquery
SELECT name, salary
FROM employees e1
WHERE salary > (SELECT AVG(salary) 
                FROM employees e2 
                WHERE e2.dept_id = e1.dept_id);
