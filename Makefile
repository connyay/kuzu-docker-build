
build: toolchains-centos7
	docker build --file Dockerfile .

toolchains-centos7:
	docker build --tag toolchains-centos7 --file toolchains-centos7.Dockerfile .
