#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ $# -ne 2 ]; then
echo "Use: ./antivirus-cron.sh <dir> <malicious_dir> "
exit 1
fi
if [ ! -d "$1" ]; then
echo "Error: main(source) directory does not exist"
exit 1
fi
if [ ! -d "$2" ]; then
echo "Error: quarantine directory does not exist"
exit 1
fi

echo "main_dir: $1"
echo "quarantine_dir: $2"

scan_file() {
shopt -s nullglob
for file in "$1"/*
do
flag=0
filename=$(basename "$file")
if grep -Fxq "$filename" "$SCRIPT_DIR/whitelist.txt"; then
continue
fi 
extension=${filename##*.}
case  "$extension" in 
exe|vbs|bat|scr|ps1)
flag=1
;;
esac
if grep -Eqi "virus|trojan|malware|worm|ransomware" "$file"; then
flag=1
fi
if [ $flag -eq 1 ]; then
cp -- "$file" "$2" && rm -- "$file" && echo " $filename is malicious and it is DELETED "
fi
done
}

if [ ! -f "$SCRIPT_DIR/whitelist.txt" ]; then
touch "$SCRIPT_DIR/whitelist.txt"
fi
scan_file "$1" "$2"

