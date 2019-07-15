default: secret-key.txt client-id.txt client-secret.txt admin-password.txt

secret-key.txt:
	dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=100 count=1 2>/dev/null | tr -d '\n' > secret-key.txt
	
client-id.txt:
	dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=25 count=1 2>/dev/null | tr -d '\n' > client-id.txt

client-secret.txt:
	dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=25 count=1 2>/dev/null | tr -d '\n' > client-secret.txt

admin-password.txt:
	dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=13 count=1 2>/dev/null | tr -d '\n' > admin-password.txt




