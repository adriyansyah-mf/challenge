<?php
$log_file = '/var/log/apache2/access.log';
$log_content = '';

if (isset($_POST['view_log'])) {
    $selected_log = $_POST['log_file'];
    
    $command = "tail -50 $selected_log";
    $log_content = shell_exec($command . " 2>&1");
}

if (isset($_POST['search_logs'])) {
    $search_term = $_POST['search_term'];
    $log_to_search = $_POST['log_to_search'];
    
    $command = "grep '$search_term' $log_to_search";
    $log_content = shell_exec($command . " 2>&1");
}
?>

<div class="card">
    <h2>📋 System Logs Viewer</h2>
    <p>View and search system logs for troubleshooting and monitoring.</p>
    
    <form method="POST" action="">
        <div class="form-group">
            <label for="log_file">Select log file:</label>
            <select id="log_file" name="log_file" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                <option value="/var/log/apache2/access.log">Apache Access Log</option>
                <option value="/var/log/apache2/error.log">Apache Error Log</option>
                <option value="/var/log/syslog">System Log</option>
                <option value="/var/log/auth.log">Authentication Log</option>
                <option value="/etc/passwd">System Users</option>
                <option value="/proc/version">System Version</option>
            </select>
        </div>
        <button type="submit" name="view_log" class="btn">📖 View Log (Last 50 lines)</button>
    </form>
</div>

<div class="card">
    <h3>🔍 Search Logs</h3>
    <form method="POST" action="">
        <div class="form-group">
            <label for="search_term">Search term:</label>
            <input type="text" id="search_term" name="search_term" placeholder="Enter search term..." value="<?php echo isset($_POST['search_term']) ? htmlspecialchars($_POST['search_term']) : ''; ?>">
        </div>
        <div class="form-group">
            <label for="log_to_search">Log file to search:</label>
            <input type="text" id="log_to_search" name="log_to_search" placeholder="/var/log/apache2/access.log" value="<?php echo isset($_POST['log_to_search']) ? htmlspecialchars($_POST['log_to_search']) : '/var/log/apache2/access.log'; ?>">
        </div>
        <button type="submit" name="search_logs" class="btn">🔍 Search Logs</button>
    </form>
</div>

<?php if (!empty($log_content)): ?>
<div class="card">
    <h3>📄 Log Output</h3>
    <div class="output"><?php echo htmlspecialchars($log_content); ?></div>
</div>
<?php endif; ?>

<div class="card">
    <h3>⚙️ Log Management</h3>
    <p>Quick log management operations:</p>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
        <div style="padding: 15px; background: #e3f2fd; border-radius: 6px;">
            <strong>Log Rotation</strong><br>
            <small>Automatic daily rotation enabled</small>
        </div>
        <div style="padding: 15px; background: #f3e5f5; border-radius: 6px;">
            <strong>Retention Policy</strong><br>
            <small>30 days retention</small>
        </div>
        <div style="padding: 15px; background: #e8f5e8; border-radius: 6px;">
            <strong>Compression</strong><br>
            <small>Logs compressed after 7 days</small>
        </div>
    </div>
</div>

<div class="card">
    <h3>🚨 Recent Security Events</h3>
    <div style="background: #fff3cd; padding: 15px; border-radius: 4px; border-left: 4px solid #ffc107;">
        <ul style="margin: 0; padding-left: 20px;">
            <li>Failed login attempt from 192.168.1.100 - <em>2 minutes ago</em></li>
            <li>Successful admin login - <em>15 minutes ago</em></li>
            <li>File upload: suspicious.php - <em>1 hour ago</em></li>
            <li>Multiple 404 errors from scanner - <em>2 hours ago</em></li>
        </ul>
    </div>
</div>
