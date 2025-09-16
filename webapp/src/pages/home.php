<div class="card">
    <h2>🏠 Welcome to SecureCorp Employee Portal</h2>
    <p>Hello <?php echo $_SESSION['username']; ?>! This is your secure employee dashboard.</p>
    <p>Use the navigation menu above to access different features:</p>
    <ul>
        <li><strong>Network Tools</strong> - Test network connectivity</li>
        <li><strong>File Manager</strong> - Upload and manage files</li>
        <li><strong>System Logs</strong> - View application logs</li>
    </ul>
</div>

<div class="card">
    <h3>📊 Quick Stats</h3>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px;">
        <div style="text-align: center; padding: 20px; background: #e3f2fd; border-radius: 8px;">
            <h4>Active Users</h4>
            <p style="font-size: 2em; margin: 10px 0; color: #1976d2;">42</p>
        </div>
        <div style="text-align: center; padding: 20px; background: #f3e5f5; border-radius: 8px;">
            <h4>System Uptime</h4>
            <p style="font-size: 2em; margin: 10px 0; color: #7b1fa2;">99.9%</p>
        </div>
        <div style="text-align: center; padding: 20px; background: #e8f5e8; border-radius: 8px;">
            <h4>Security Score</h4>
            <p style="font-size: 2em; margin: 10px 0; color: #388e3c;">A+</p>
        </div>
    </div>
</div>

<div class="card">
    <h3>📢 Recent Announcements</h3>
    <ul>
        <li><strong>System Maintenance</strong> - Scheduled for next weekend</li>
        <li><strong>Security Update</strong> - New firewall rules implemented</li>
        <li><strong>New Feature</strong> - File upload limit increased to 10MB</li>
    </ul>
</div>
