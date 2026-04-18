# Backup Automation
                                           
A modular Bash automation suite for reliable backups, validation, and logging.

## Development Roadmap
                                               
 | Phase | Status |
 | :--- | :--- |                                                   
 | 1. Config & Init | Done |
 | 2. Logging Module | Done |
 | 3. Validations| Done |                                      
 | 4. Core Logic | Done |
 | 5. Docs & Tests | Done |
                                          
## Current Capabilities
- Full and incremental backups (tar)
- Integrity verification (`tar tzf`)
- Validation of source/destination directories, permissions, and free space
- Logging to syslog with fallback to local file
- Configurable retention policy (7 days by default)
- Automatic cleanup of old backups

## Tech Stack
                                                           
- Language: Bash 5.2
- Dependencies: coreutils (tar, find, df, logger)
- Editor: Vim

## Configuration

Edit `config/config.conf`
