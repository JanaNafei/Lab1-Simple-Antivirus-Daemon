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
