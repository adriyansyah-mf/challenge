#!/bin/bash

# Create a vulnerable SUID binary for privilege escalation
cat > /tmp/vuln_binary.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        return 1;
    }
    
    // Vulnerable: No input validation, allows path traversal
    char command[256];
    snprintf(command, sizeof(command), "cat %s", argv[1]);
    
    // Set effective UID to root (since this is SUID)
    setuid(0);
    
    // Execute command (vulnerable to command injection)
    system(command);
    
    return 0;
}
EOF

# Compile and set SUID
gcc /tmp/vuln_binary.c -o /usr/local/bin/file_reader
chmod 4755 /usr/local/bin/file_reader
chown root:root /usr/local/bin/file_reader

# Create another vulnerable binary for docker escape
cat > /tmp/docker_helper.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    // This binary is designed to help with docker escape
    // It has elevated privileges and can access docker socket
    setuid(0);
    system("docker ps");
    return 0;
}
EOF

gcc /tmp/docker_helper.c -o /usr/local/bin/docker_helper
chmod 4755 /usr/local/bin/docker_helper
chown root:root /usr/local/bin/docker_helper

# Clean up
rm /tmp/vuln_binary.c /tmp/docker_helper.c

echo "Privilege escalation setup completed"
