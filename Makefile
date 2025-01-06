out: out/libkuzu-linux-x86_64.tar.gz out/libkuzu-linux-aarch64.tar.gz

out/libkuzu-linux-x86_64.tar.gz:
	docker run --platform linux/x86_64 -v $(PWD)/out:/out built-kuzu-x86_64

built-kuzu-x86_64:
	docker build --platform linux/x86_64 --tag built-kuzu-x86_64 --file Dockerfile .

out/libkuzu-linux-aarch64.tar.gz: built-kuzu-aarch64
	docker run --platform linux/aarch64 -v $(PWD)/out:/out built-kuzu-aarch64

built-kuzu-aarch64:
	docker build --platform linux/aarch64 --tag built-kuzu-aarch64 --file Dockerfile .
