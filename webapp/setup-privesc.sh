#!/bin/bash


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
    
    char command[256];
    snprintf(command, sizeof(command), "cat %s", argv[1]);
    
    setuid(0);
    
    system(command);
    
    return 0;
}
EOF

gcc /tmp/vuln_binary.c -o /usr/local/bin/file_reader
chmod 4755 /usr/local/bin/file_reader
chown root:root /usr/local/bin/file_reader

cat > /tmp/docker_helper.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    setuid(0);
    system("docker ps");
    return 0;
}
EOF

gcc /tmp/docker_helper.c -o /usr/local/bin/docker_helper
chmod 4755 /usr/local/bin/docker_helper
chown root:root /usr/local/bin/docker_helper


rm /tmp/vuln_binary.c /tmp/docker_helper.c

echo "Privilege escalation setup completed"
