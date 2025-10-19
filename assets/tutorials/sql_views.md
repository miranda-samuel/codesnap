# SQL Views

## Views Creation
```sql
CREATE VIEW active_users AS
SELECT id, username, email, created_at
FROM users
WHERE active = 1;

CREATE VIEW high_value_customers AS
SELECT u.id, u.name, u.email, SUM(o.total_amount) as total_spent
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.email
HAVING SUM(o.total_amount) > 1000;
