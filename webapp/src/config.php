<?php
$db_host = getenv('MYSQL_HOST') ?: 'localhost';
$db_user = getenv('MYSQL_USER') ?: 'webapp';
$db_pass = getenv('MYSQL_PASSWORD') ?: 'w3bp@ss123';
$db_name = getenv('MYSQL_DATABASE') ?: 'securecorp';

$connection = mysqli_connect($db_host, $db_user, $db_pass, $db_name);

if (!$connection) {
    die("Connection failed: " . mysqli_connect_error());
}

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
error_reporting(E_ALL);
ini_set('display_errors', 1);

define('SECRET_KEY', 'super_secret_key_123');
define('API_TOKEN', 'sk-1234567890abcdef');
define('ADMIN_EMAIL', 'admin@securecorp.com');

define('AWS_ACCESS_KEY', 'AKIAIOSFODNN7EXAMPLE');
define('AWS_SECRET_KEY', 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY');

define('UPLOAD_DIR', '/var/www/html/uploads/');
define('MAX_FILE_SIZE', 10485760); // 10MB
define('ALLOWED_EXTENSIONS', array('jpg', 'jpeg', 'png', 'gif', 'txt', 'pdf', 'doc', 'docx'));

if (!is_dir(UPLOAD_DIR)) {
    mkdir(UPLOAD_DIR, 0777, true);
}
?>
