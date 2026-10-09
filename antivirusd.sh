if [ $# -ne 3 ]; then
echo "Use: ./ antivirusd.sh <dir> <malicious_dir> <interval-secs>"
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
if ! [[  "$3" =~ ^[0-9]+$ ]]; then
echo "Error: interval-secs must be a positive integer"
exit 1
fi
if [ "$3" -eq 0 ]; then
echo "Error: interval-secs must be greater than 0"
exit 1
fi
echo "main_dir: $1"
echo "quarantine_dir: $2"
echo "interval-secs: $3"
