# PHP Oop

## Object Creation
```php
<?php
$car1 = new Car("Toyota", "Camry", 2022);
$car2 = new Car("Honda", "Civic", 2023);

echo $car1->getInfo(); // Toyota Camry (2022)
echo $car1->startEngine(); // Engine started!
?>
