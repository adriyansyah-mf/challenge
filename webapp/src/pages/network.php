<div class="card">
    <h2>🌐 Network Connectivity Tools</h2>
    <p>Test network connectivity to internal and external hosts.</p>
    
    <form method="POST" action="">
        <div class="form-group">
            <label for="host">Host to ping:</label>
            <input type="text" id="host" name="host" placeholder="e.g., google.com or 192.168.1.1" value="<?php echo isset($_POST['host']) ? htmlspecialchars($_POST['host']) : ''; ?>">
        </div>
        <button type="submit" name="ping_host" class="btn">🔍 Ping Host</button>
    </form>
    
    <?php if (isset($output)): ?>
        <h3>Ping Results:</h3>
        <div class="output"><?php echo htmlspecialchars($output); ?></div>
    <?php endif; ?>
</div>

<div class="card">
    <h3>📊 Network Status</h3>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px;">
        <div style="padding: 15px; background: #e8f5e8; border-radius: 6px;">
            <strong>Database Server</strong><br>
            <span style="color: green;">🟢 Online</span> - mysql:3306
        </div>
        <div style="padding: 15px; background: #e8f5e8; border-radius: 6px;">
            <strong>Web Server</strong><br>
            <span style="color: green;">🟢 Online</span> - apache:80
        </div>
        <div style="padding: 15px; background: #e8f5e8; border-radius: 6px;">
            <strong>Elasticsearch</strong><br>
            <span style="color: green;">🟢 Online</span> - elasticsearch:9200
        </div>
        <div style="padding: 15px; background: #fff3e0; border-radius: 6px;">
            <strong>External API</strong><br>
            <span style="color: orange;">🟡 Slow</span> - api.example.com
        </div>
    </div>
</div>

<div class="card">
    <h3>⚠️ Security Notice</h3>
    <p style="background: #fff3cd; padding: 10px; border-radius: 4px; border-left: 4px solid #ffc107;">
        <strong>Note:</strong> This tool is for authorized network diagnostics only. 
        Unauthorized access or misuse may result in security violations.
    </p>
</div>
