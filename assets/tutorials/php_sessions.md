# PHP Sessions

## Session Start
```php
<?php
session_start();

$_SESSION["username"] = "john_doe";
$_SESSION["email"] = "john@example.com";
$_SESSION["loggedin"] = true;

echo "Session started and variables set";
?>
