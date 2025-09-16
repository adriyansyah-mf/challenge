<?php
// Debug page with information disclosure vulnerabilities
require_once 'config.php';

// Check if debug mode is enabled (always enabled - vulnerability)
$debug_enabled = true;

if (!$debug_enabled) {
    die("Debug mode is disabled.");
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SecureCorp - Debug Information</title>
    <style>
        body { font-family: monospace; background: #1e1e1e; color: #00ff00; padding: 20px; }
        .debug-section { background: #2d2d2d; padding: 15px; margin: 15px 0; border-radius: 5px; }
        .debug-title { color: #ff6b6b; font-size: 1.2em; margin-bottom: 10px; }
        .debug-content { white-space: pre-wrap; }
        .sensitive { color: #ffd93d; }
        .error { color: #ff4757; }
    </style>
</head>
<body>
    <h1>🐛 SecureCorp Debug Panel</h1>
    <p><a href="index.php" style="color: #00ff00;">← Back to Login</a> | <a href="dashboard.php" style="color: #00ff00;">← Back to Dashboard</a></p>
    
    <div class="debug-section">
        <div class="debug-title">📊 System Information</div>
        <div class="debug-content">
PHP Version: <?php echo phpversion(); ?>

Server Software: <?php echo $_SERVER['SERVER_SOFTWARE']; ?>

Operating System: <?php echo php_uname(); ?>

Document Root: <?php echo $_SERVER['DOCUMENT_ROOT']; ?>

Server IP: <?php echo $_SERVER['SERVER_ADDR']; ?>

Current User: <?php echo get_current_user(); ?>

Current Working Directory: <?php echo getcwd(); ?>
        </div>
    </div>
    
    <div class="debug-section">
        <div class="debug-title">🔑 Database Configuration</div>
        <div class="debug-content sensitive">
Host: <?php echo $db_host; ?>

Username: <?php echo $db_user; ?>

Password: <?php echo $db_pass; ?>

Database: <?php echo $db_name; ?>

Connection Status: <?php echo $connection ? 'Connected' : 'Failed'; ?>
        </div>
    </div>
    
    <div class="debug-section">
        <div class="debug-title">🏗️ Application Constants</div>
        <div class="debug-content sensitive">
SECRET_KEY: <?php echo SECRET_KEY; ?>

API_TOKEN: <?php echo API_TOKEN; ?>

ADMIN_EMAIL: <?php echo ADMIN_EMAIL; ?>

UPLOAD_DIR: <?php echo UPLOAD_DIR; ?>

MAX_FILE_SIZE: <?php echo MAX_FILE_SIZE; ?> bytes

AWS_ACCESS_KEY: <?php echo AWS_ACCESS_KEY; ?>

AWS_SECRET_KEY: <?php echo AWS_SECRET_KEY; ?>
        </div>
    </div>
    
    <div class="debug-section">
        <div class="debug-title">🌍 Environment Variables</div>
        <div class="debug-content">
<?php
foreach ($_ENV as $key => $value) {
    echo htmlspecialchars($key) . ": " . htmlspecialchars($value) . "\n";
}
?>
        </div>
    </div>
    
    <div class="debug-section">
        <div class="debug-title">🔧 PHP Configuration</div>
        <div class="debug-content">
<?php
$important_settings = [
    'display_errors',
    'error_reporting',
    'log_errors',
    'file_uploads',
    'upload_max_filesize',
    'post_max_size',
    'memory_limit',
    'max_execution_time',
    'allow_url_fopen',
    'allow_url_include'
];

foreach ($important_settings as $setting) {
    echo $setting . ": " . ini_get($setting) . "\n";
}
?>
        </div>
    </div>
    
    <div class="debug-section">
        <div class="debug-title">📁 Directory Listing</div>
        <div class="debug-content">
<?php
$dirs_to_check = ['/var/www/html', '/tmp', '/etc'];
foreach ($dirs_to_check as $dir) {
    echo "=== $dir ===\n";
    if (is_readable($dir)) {
        $files = scandir($dir);
        foreach ($files as $file) {
            if ($file != '.' && $file != '..') {
                $filepath = $dir . '/' . $file;
                $perms = substr(sprintf('%o', fileperms($filepath)), -4);
                echo sprintf("%-30s %s\n", $file, $perms);
            }
        }
    } else {
        echo "Directory not readable\n";
    }
    echo "\n";
}
?>
        </div>
    </div>
    
    <div class="debug-section">
        <div class="debug-title">🐳 Docker Information</div>
        <div class="debug-content">
<?php
$docker_commands = [
    'whoami',
    'id',
    'cat /proc/1/cgroup',
    'ls -la /.dockerenv',
    'mount | grep docker',
    'ps aux'
];

foreach ($docker_commands as $cmd) {
    echo "=== $cmd ===\n";
    $output = shell_exec($cmd . ' 2>&1');
    echo htmlspecialchars($output);
    echo "\n";
}
?>
        </div>
    </div>
    
    <div class="debug-section">
        <div class="debug-title">🔍 Process Information</div>
        <div class="debug-content">
<?php
$process_info = shell_exec('ps aux 2>&1');
echo htmlspecialchars($process_info);
?>
        </div>
    </div>
    
    <div class="debug-section">
        <div class="debug-title">💽 Disk Usage</div>
        <div class="debug-content">
<?php
$disk_info = shell_exec('df -h 2>&1');
echo htmlspecialchars($disk_info);
?>
        </div>
    </div>
    
    <div class="debug-section">
        <div class="debug-title">⚠️ Security Notice</div>
        <div class="debug-content error">
WARNING: This debug page exposes sensitive system information.
It should never be accessible in production environments.
Disable debug mode immediately after troubleshooting.

This page reveals:
- Database credentials
- API keys and secrets
- System configuration
- File system structure
- Running processes
- Docker container information
        </div>
    </div>
</body>
</html>
