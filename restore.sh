#!/bin/bash
if [ $# -ne 2 ]; then
echo "Use: ./restore.sh <dir> <malicious_dir> "
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

while true; do
shopt -s nullglob
files=("$2"/*)
if [ ${#files[@]} -eq 0 ]; then
echo "No malicious files to review."
exit 0
fi

i=1
echo "Choose a file: "
for file in "${files[@]}";
do
echo ""$i": $(basename "$file")"
i=$((i+1))
done

echo "Enter the file number: "
read -r choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#files[@]}" ]; then
echo "Invalid choice."
exit 1
fi
file="${files[$((choice-1))]}"
echo "Selected file: $(basename "$file")"
echo "1. Restore the file"
echo "2. Permanently delete the file"
echo "3. Go back"
echo "Enter your choice: "
read -r choice2
if ! [[ "$choice2" =~ ^[0-9]+$ ]] || [ "$choice2" -lt 1 ] || [ "$choice2" -gt 3 ]; then
echo "Invalid choice."
exit 1
fi

if [ "$choice2" -eq 1 ]; then
mv -- "$file" "$1" && echo "Restored $(basename "$file") to $1"
echo "$(basename "$file")" >> whitelist.txt
elif [ "$choice2" -eq 2 ]; then
rm -- "$file" && echo "$(basename "$file") is permanently deleted."
else
continue
fi
done
