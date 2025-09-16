<?php
session_start();
require_once 'config.php';

// Simple session check (can be bypassed)
if (!isset($_SESSION['logged_in'])) {
    header('Location: index.php');
    exit();
}

$username = $_SESSION['username'];

// XSS vulnerability - no output encoding
if (isset($_GET['message'])) {
    $message = $_GET['message'];
}

// Command injection vulnerability
if (isset($_POST['ping_host'])) {
    $host = $_POST['host'];
    // Vulnerable: No input sanitization
    $output = shell_exec("ping -c 3 $host 2>&1");
}

// File inclusion vulnerability
$page = isset($_GET['page']) ? $_GET['page'] : 'home';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SecureCorp Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background-color: #f5f5f5;
        }
        .header {
            background: #333;
            color: white;
            padding: 1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .nav {
            background: #667eea;
            padding: 0;
        }
        .nav ul {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
        }
        .nav li {
            margin: 0;
        }
        .nav a {
            display: block;
            padding: 15px 20px;
            color: white;
            text-decoration: none;
        }
        .nav a:hover {
            background: rgba(255,255,255,0.1);
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 15px;
        }
        input, textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .btn {
            background: #667eea;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .output {
            background: #f8f8f8;
            padding: 15px;
            border-radius: 4px;
            margin-top: 15px;
            white-space: pre-wrap;
            font-family: monospace;
        }
        .alert {
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
        }
        .alert-info {
            background: #d1ecf1;
            color: #0c5460;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🏢 SecureCorp Dashboard</h1>
        <div>
            Welcome, <?php echo $username; ?> | 
            <a href="logout.php" style="color: #ccc;">Logout</a>
        </div>
    </div>
    
    <nav class="nav">
        <ul>
            <li><a href="?page=home">Home</a></li>
            <li><a href="?page=network">Network Tools</a></li>
            <li><a href="?page=files">File Manager</a></li>
            <li><a href="?page=logs">System Logs</a></li>
            <li><a href="debug.php">Debug</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <?php if (isset($message)): ?>
            <div class="alert alert-info">
                <?php echo $message; // XSS vulnerability ?>
            </div>
        <?php endif; ?>
        
        <?php
        // Local File Inclusion vulnerability
        switch($page) {
            case 'network':
                include 'pages/network.php';
                break;
            case 'files':
                include 'pages/files.php';
                break;
            case 'logs':
                include 'pages/logs.php';
                break;
            default:
                include 'pages/home.php';
                break;
        }
        
        // Even more vulnerable - direct inclusion
        if (isset($_GET['include'])) {
            include $_GET['include'];
        }
        ?>
    </div>
</body>
</html>
