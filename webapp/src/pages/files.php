<?php

if (isset($_POST['upload'])) {
    $target_dir = UPLOAD_DIR;
    $filename = $_FILES["file"]["name"];
    $target_file = $target_dir . basename($filename);
    
    $file_extension = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
    
    if ($_FILES["file"]["size"] > MAX_FILE_SIZE) {
        $upload_error = "File is too large.";
    } else {

        if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
            $upload_success = "File uploaded successfully: " . htmlspecialchars($filename);
        } else {
            $upload_error = "Error uploading file.";
        }
    }
}

if (isset($_GET['download'])) {
    $file = $_GET['download'];
    $filepath = UPLOAD_DIR . $file;
    
    if (file_exists($filepath)) {
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . basename($file) . '"');
        readfile($filepath);
        exit();
    }
}


$uploaded_files = array();
if (is_dir(UPLOAD_DIR)) {
    $files = scandir(UPLOAD_DIR);
    foreach ($files as $file) {
        if ($file != "." && $file != "..") {
            $uploaded_files[] = $file;
        }
    }
}
?>

<div class="card">
    <h2>📁 File Manager</h2>
    <p>Upload and manage your files securely.</p>
    
    <form method="POST" action="" enctype="multipart/form-data">
        <div class="form-group">
            <label for="file">Select file to upload:</label>
            <input type="file" id="file" name="file" required>
            <small style="color: #666;">Max file size: <?php echo (MAX_FILE_SIZE/1024/1024); ?>MB</small>
        </div>
        <button type="submit" name="upload" class="btn">📤 Upload File</button>
    </form>
    
    <?php if (isset($upload_success)): ?>
        <div class="alert alert-info" style="background: #d4edda; color: #155724; margin-top: 15px;">
            <?php echo $upload_success; ?>
        </div>
    <?php endif; ?>
    
    <?php if (isset($upload_error)): ?>
        <div class="alert alert-info" style="background: #f8d7da; color: #721c24; margin-top: 15px;">
            <?php echo $upload_error; ?>
        </div>
    <?php endif; ?>
</div>

<div class="card">
    <h3>📂 Uploaded Files</h3>
    <?php if (empty($uploaded_files)): ?>
        <p>No files uploaded yet.</p>
    <?php else: ?>
        <div style="overflow-x: auto;">
            <table style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr style="background: #f8f9fa;">
                        <th style="padding: 12px; text-align: left; border-bottom: 1px solid #dee2e6;">Filename</th>
                        <th style="padding: 12px; text-align: left; border-bottom: 1px solid #dee2e6;">Size</th>
                        <th style="padding: 12px; text-align: left; border-bottom: 1px solid #dee2e6;">Modified</th>
                        <th style="padding: 12px; text-align: left; border-bottom: 1px solid #dee2e6;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($uploaded_files as $file): ?>
                        <?php
                        $filepath = UPLOAD_DIR . $file;
                        $filesize = filesize($filepath);
                        $modified = date("Y-m-d H:i:s", filemtime($filepath));
                        ?>
                        <tr>
                            <td style="padding: 12px; border-bottom: 1px solid #dee2e6;"><?php echo htmlspecialchars($file); ?></td>
                            <td style="padding: 12px; border-bottom: 1px solid #dee2e6;"><?php echo number_format($filesize); ?> bytes</td>
                            <td style="padding: 12px; border-bottom: 1px solid #dee2e6;"><?php echo $modified; ?></td>
                            <td style="padding: 12px; border-bottom: 1px solid #dee2e6;">
                                <a href="?page=files&download=<?php echo urlencode($file); ?>" style="color: #667eea; text-decoration: none;">📥 Download</a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    <?php endif; ?>
</div>

<div class="card">
    <h3>📋 File Operations</h3>
    <p>Quick file operations for system administrators:</p>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
        <a href="?include=../../../etc/passwd" style="display: block; padding: 15px; background: #e3f2fd; border-radius: 6px; text-decoration: none; color: #1976d2;">
            🔍 View System Files
        </a>
        <a href="?include=../../../var/log/apache2/access.log" style="display: block; padding: 15px; background: #f3e5f5; border-radius: 6px; text-decoration: none; color: #7b1fa2;">
            📊 Access Logs
        </a>
        <a href="backup.php" style="display: block; padding: 15px; background: #e8f5e8; border-radius: 6px; text-decoration: none; color: #388e3c;">
            💾 Backup System
        </a>
    </div>
</div>
