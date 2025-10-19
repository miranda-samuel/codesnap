# PHP File Handling

## Reading Files
```php
$content = file_get_contents("file.txt");
$lines = file("file.txt");

$file = fopen("file.txt", "r");
while (!feof($file)) {
    echo fgets($file);
}
fclose($file);
