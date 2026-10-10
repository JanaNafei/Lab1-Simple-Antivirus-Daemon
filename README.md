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

Print to the terminal: ""filename" is malicious and it is DELETED"

2.Copy the file into malicious_dir, keeping its original filename

3.Delete the original file from dir

# 7.antivirusd.sh (Antivirus-Daemon)
* Option 1: Using the Makefile

From the project directory, we can run:

make antivirus

The current Makefile runs:

./antivirusd.sh dir malicious_dir 10

* Option 2: Running the script directly

we can run:

./antivirusd.sh dir malicious_dir 10

we can replace 10 with another positive integer to change the monitoring interval.

* How the daemon works

Validates the supplied arguments and directories.

Performs an initial scan immediately.

Creates a snapshot of the source directory using ls -l.

Waits for the configured interval.

Creates a new snapshot and compares it with the previous snapshot using diff.

Scans the directory if a change is detected.

Updates the saved snapshot and repeats the process.

The daemon also compares the whitelist against its previous snapshot so that changes to the whitelist can trigger another scan.

# 8.restore.sh (Restore tool)

The restore tool allows users to review quarantined files and decide what to do with each one.

* 2 Options to run the script:

1.Run using the Makefile:

make restore

2.Run directly:

./restore.sh dir malicious_dir

* Available options

When the quarantine directory contains files, the script displays a numbered list. Select a file by entering its number.

The script then presents three options:

Option 1 — Restore the file:

Moves the selected file back to the source directory, prints a restoration message, and adds its filename to whitelist.txt so that future scans can skip it.

Option 2 — Permanently delete the file:

Removes the selected file from the quarantine directory and prints a deletion message.

Option 3 — Return to the list:

Leaves the file unchanged and displays the list again.

If the quarantine directory is empty when the tool starts, it prints:

No malicious files to review.

The antivirus daemon and restore tool should not be run simultaneously.

# 9.Scheduled scanning with Cron

The antivirus-cron.sh script implements the scanning and quarantine behavior without continuously running a daemon. Cron can execute it automatically according to a schedule.

From the project directory,we can run:

./antivirus-cron.sh dir malicious_dir

Confirm that the script scans the source directory and moves detected files to the quarantine directory.

then

we run:

pwd

then we use the full path returned by this command in our cron entry. Cron jobs should not depend on the terminal's current working directory.

Then we should open the crontab editor:

crontab -e

Add an entry using the absolute path to the script and the two directories:

* * * * * /absolute/path/to/antivirus-cron.sh /absolute/path/to/dir /absolute/path/to/malicious_dir

This executes the script once every minute.

Important: Standard cron schedules jobs by minute, not by second. Therefore, standard cron cannot guarantee execution at second 23 of every minute. The entry above runs at the start of each scheduled minute, subject to system scheduling delays.

then we should save and verify:

Save the crontab and list the installed entries:

crontab -l

To stop scheduled execution, edit the crontab again and remove the corresponding entry(i just add a hashtag to consider it as a comment).

* Cron expression for the third Friday of each month at 12:31 AM

31 0 15-21 * 5

This expression runs on Fridays falling between the 15th and 21st of the month, which identifies the third Friday.

# 10.Whitelist

The whitelist prevents a restored file from being flagged repeatedly when it still matches a detection rule.

* How a file is added:

When the user selects option 1 in restore.sh:

The file is moved from malicious_dir/ back to dir/.

Its filename is appended to whitelist.txt.

The daemon checks the whitelist before checking the file's extension or contents.

How the daemon checks the whitelist

Inside scan_file() in antivirusd.sh, the script uses:

grep -Fxq "$filename" whitelist.txt

If the filename is already present in the whitelist, the script skips that file.

-F treats the filename as a literal string.

-x requires an exact match for the whole line.

-q suppresses normal search output.

Because the whitelist is stored in a file, its entries persist when the daemon stops and starts again.

The daemon also maintains whitelist.last to detect changes to the whitelist between scans.

# 11.Makefile targets
The Makefile currently provides the following targets:

prepare : Creates dir/ and malicious_dir/ if they do not exist. (Pre-step)

antivirus : Runs the antivirus daemon with a 10-second interval.

restore : Runs the interactive restore tool.

The antivirus and restore targets depend on prepare, ensuring the required directories are created before execution.


