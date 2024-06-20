.PHONY: scripts
scripts:
	aws --profile vi s3 cp scripts/noaws-gpu.otel-config.yaml s3://viact-devops/scripts/viact/noaws-gpu.otel-config.yaml
	aws --profile vi s3 cp scripts/noaws.otel-config.yaml s3://viact-devops/scripts/viact/noaws.otel-config.yaml
	aws --profile vi s3 cp scripts/aws.otel-config.yaml s3://viact-devops/scripts/viact/aws.otel-config.yaml
	aws --profile vi s3 cp scripts/viact.sh s3://viact-devops/scripts/viact/viact.sh

.PHONY: deb deb-otel deb-otel-amd64 deb-otel-arm64 deb-dcgm
deb-otel: deb-otel-amd64 deb-otel-arm64 deb-otel-armhfv7
deb-otel-amd64:
	@echo dpkg --build deb/otelcol-amd64
	@echo aws --profile vi s3 cp deb/otelcol-amd64.deb s3://viact-devops/deb/
deb-otel-arm64:
	@echo dpkg --build deb/otelcol-arm64
	@echo aws --profile vi s3 cp deb/otelcol-arm64.deb s3://viact-devops/deb/
deb-otel-armhfv7:
	@echo dpkg --build deb/otelcol-armhfv7
	@echo aws --profile vi s3 cp deb/otelcol-armhfv7.deb s3://viact-devops/deb/

deb-dcgm:
	@echo dpkg --build deb/dcgm-exorter-amd64
	@echo aws --profile vi s3 cp deb/dcgm-exorter-amd64.deb s3://viact-devops/deb/

deb: deb-otel deb-dcgm
