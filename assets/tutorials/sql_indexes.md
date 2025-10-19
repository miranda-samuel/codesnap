# SQL Indexes

## Indexes Creation
```sql
CREATE INDEX idx_email ON users(email);
CREATE INDEX idx_last_name ON employees(last_name);
CREATE INDEX idx_category_price ON products(category, price);
