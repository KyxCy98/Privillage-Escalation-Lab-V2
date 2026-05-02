#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

/* 
 * Vulnerable SUID Binary - Demonstrates common SUID exploitation techniques
 * VULNERABLE TO: PATH injection, Command injection, Buffer overflow
 */

/* VULNERABLE #1: system() with relative path */
void vulnerable_system_relative() {
    printf("[*] Executing backup system...\n");
    system("backup-runner");  /* Vulnerable to PATH injection */
}

/* VULNERABLE #2: system() with user input */
void vulnerable_system_input(char *input) {
    char cmd[512];
    sprintf(cmd, "echo %s | tee /tmp/log.txt", input);  /* Buffer overflow + command injection */
    system(cmd);
}

/* VULNERABLE #3: execvp with relative path */
void vulnerable_execvp() {
    char *args[] = {"check-status", NULL};
    execvp("check-status", args);  /* Vulnerable to PATH injection */
}

/* SAFE VERSION - for comparison */
void safe_execution() {
    printf("[*] Safe: Using full path\n");
    system("/usr/local/bin/backup-runner");  /* Safe - full path */
}

int main(int argc, char *argv[]) {
    printf("[+] SUID Binary Executed (UID: %d, EUID: %d)\n", getuid(), geteuid());
    
    if (argc > 1) {
        if (strcmp(argv[1], "status") == 0) {
            vulnerable_execvp();
        } else {
            vulnerable_system_input(argv[1]);
        }
    } else {
        vulnerable_system_relative();
    }
    
    return 0;
}
