# 1.Project overview
In this lab i built a simplified antivirus daemon: a shell script that periodically checks a directory for changes, and
when a change is detected, scans the directory for files it considers malicious. Malicious files are flagged, printed to the terminal, quarantined into a separate directory, and removed from the original location. I also built a restore tool
that lets a user pick quarantined files from a list, one at a time, and decide whether each was falsely flagged or genuinely malicious. I assumed dir contains only files, directly inside it — no subdirectories at all. 
The project also includes a Makefile to simplify execution and a cron-based script for scheduled scanning.

# 2.Main features
1.Periodically monitor a directory for changes

2.Detect malicious files based on thier extensions or contents

3.Move detected files to quarantine directory

4.Review,restore,or permenantly delete quarantined files

5.Maintain a whitelist to avoid flagging restored (falsely flagged)files (Bonus-2)

6.Run scans automatically using cron (Bonus-1)

7.Use Makefile to simplify Project execution and pre-steps for it.

# 3.Project structure
Lab2-Simple-Antivirus-Daemon/
├── antivirusd.sh
├── antivirus-cron.sh
├── restore.sh
├── Makefile
├── README.md
├── whitelist.txt
├── whitelist.last
├── directory-info.last
└── directory-info.new

* But, both the source directory and the whitelist snapshots are created automatically if not found.

# 4.File descriptions
1.antivirusd.sh : Continuously monitors the source directory and quarantines malicious files.

2.antivirus-cron.sh : Scans the source directory when executed by a scheduled cron job.

3.restore.sh : Allows the user to restore or permanently delete quarantined files.

4.Makefile : Provides targets for preparing directories and running the scripts.

5.whitelist.txt : Stores filenames marked as safe after restoration.

6.whitelist.last : Stores the previous whitelist snapshot for change detection.

7.directory-info.last : Stores the previous source-directory snapshot.

8..directory-info.new : Stores the latest source-directory snapshot.

# 5.Prerequisites
* idid not install any prerequisites as these utilities are normally available on Ubuntu (my version is 26.04).

1.Bash shell.

2.GNU Make to execute the Makefile.

3.Cron for the scheduled-scanning bonus.

# 6.Configuration
The project uses two directories:

dir/ — the directory containing the files being monitored.

malicious_dir/ — the quarantine directory where detected files are stored.

The Makefile's prepare target creates both directories if they do not already exist.

The source directory should contain files directly inside it, without nested subdirectories, as specified in the lab instructions.
* File Detection Rules

The antivirus classifies a file as malicious if it matches at least one of the following rules, unless the filename is present in the whitelist.

** Flagged extensions
The extension list is defined in the case statement inside the scan_file() function in antivirusd.sh and antivirus-cron.sh.

The required extensions are:
.exe, .bat, .vbs, .scr, .ps1

The scripts compare the extension without the leading dot, so the corresponding case patterns are: exe, bat, vbs, scr, and ps1.

** Flagged content keywords

The keyword list is defined in the grep -Eqi command inside the scan_file() function in both scanning scripts.

The required keywords are: virus, trojan, malware, worm, ransomware

The search is case-insensitive, so uppercase and lowercase variations are detected.

** Action on detection

When a file is identified as malicious, the daemon:

Prints a message indicating that the file is malicious and will be deleted from the source directory.

Copies the file to malicious_dir/.

Removes the original file from dir/.

