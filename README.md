# CIS Compliance Automation Scripts

## Project Overview

This project provides automated scripts to ensure compliance with the Center for Internet Security (CIS) Benchmarks for both Windows 11 (Basic and Enterprise editions) and Linux systems. These scripts are designed to audit, apply, and verify system configurations based on the CIS v3.0.0 benchmarks, helping organizations maintain a robust cybersecurity posture.

### Supported Operating Systems

- **Windows 11**
  - Basic Edition
  - Enterprise Edition
- **Linux**
  - Red Hat Enterprise Linux 8 and 9
  - Ubuntu Desktop 20.04 LTS, 22.04 LTS
  - Ubuntu Server 12.04 LTS, 14.04 LTS

## Project Structure

```
/project-root
│
├── README.md                # This documentation file
├── scripts/
│   ├── CIS_Windows11_Basic_Audit.ps1         # PowerShell script for Windows 11 Basic
│   ├── CIS_Windows11_Enterprise_Audit.ps1    # PowerShell script for Windows 11 Enterprise
│   ├── CIS_Linux_Audit.sh                    # Bash script for Linux systems
│
└── logs/                                    # Directory where logs are stored
```

## Prerequisites

### Windows

- **PowerShell 5.1 or later**
- Administrator privileges to run the scripts
- `.ps1` scripts must be executed with appropriate execution policy settings. You can set this with:

    ```powershell
    Set-ExecutionPolicy RemoteSigned
    ```

### Linux

- **Bash shell**
- Root or sudo privileges to apply settings
- Ensure the script has execution permissions:

    ```bash
    chmod +x CIS_Linux_Audit.sh
    ```

## How to Use

### Windows Scripts

1. **Download the scripts**: Place the `.ps1` files in a directory on your machine.
2. **Open PowerShell as Administrator**.
3. **Navigate to the script's directory** using the `cd` command.
4. **Run the script**:
   
   - For Windows 11 Basic:

     ```powershell
     .\CIS_Windows11_Basic_Audit.ps1
     ```

   - For Windows 11 Enterprise:

     ```powershell
     .\CIS_Windows11_Enterprise_Audit.ps1
     ```

5. **Review the logs**: Check the `C:\CIS_Audit_Log.txt` or the specified log file location for the results.

### Linux Script

1. **Download the script**: Place the `CIS_Linux_Audit.sh` file in a directory on your machine.
2. **Open a terminal**.
3. **Navigate to the script's directory** using the `cd` command.
4. **Run the script**:

   ```bash
   sudo ./CIS_Linux_Audit.sh
   ```

5. **Review the logs**: Check the output in the terminal or the specified log file location for the results.

## Script Details

### Windows Scripts

- **CIS_Windows11_Basic_Audit.ps1**:
  - This script audits and applies CIS Benchmark settings for Windows 11 Basic edition, ensuring compliance with v3.0.0 standards.
  
- **CIS_Windows11_Enterprise_Audit.ps1**:
  - Tailored for Windows 11 Enterprise edition, this script handles more advanced configurations and enterprise-specific settings as per CIS v3.0.0.

### Linux Script

- **CIS_Linux_Audit.sh**:
  - This Bash script audits and applies settings for Red Hat Enterprise Linux and Ubuntu, aligning system configurations with CIS v3.0.0 benchmarks.

## Error Handling and Logging

- All scripts include comprehensive error handling. If a setting cannot be applied, the script will log the error and continue processing the next item.
- Logs are generated in the specified log files, detailing the checks, applied settings, and any issues encountered.

## Customization

These scripts are modular and can be customized to suit specific organizational needs. If you need to adjust a specific control or add new ones, modify the corresponding functions in the script.

## Disclaimer

These scripts are provided "as is" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability and fitness for a particular purpose. Use them at your own risk, and test thoroughly in a non-production environment before deployment.

## Contributions

Feel free to submit issues, fork the project, and contribute improvements or additional scripts to this repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.