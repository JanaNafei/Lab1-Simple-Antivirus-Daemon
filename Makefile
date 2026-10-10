prepare:
	mkdir -p dir
	mkdir -p malicious_dir
antivirus: prepare
	./antivirusd.sh dir malicious_dir 10
restore: prepare
	./restore.sh dir malicious_dir