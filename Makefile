.PHONY: scripts
scripts:
	aws --profile vi s3 cp scripts/noaws-gpu.otel-config.yaml s3://viact-devops/scripts/viact/noaws-gpu.otel-config.yaml
	aws --profile vi s3 cp scripts/noaws.otel-config.yaml s3://viact-devops/scripts/viact/noaws.otel-config.yaml
	aws --profile vi s3 cp scripts/aws.otel-config.yaml s3://viact-devops/scripts/viact/aws.otel-config.yaml
	aws --profile vi s3 cp scripts/viact.sh s3://viact-devops/scripts/viact/viact.sh

.PHONY: deb deb-build
deb-build:
	@echo dpkg --build deb/otelcol-amd64
	@echo dpkg --build deb/dcgm-exorter-amd64

deb: deb-build
	@echo aws --profile vi s3 cp otelcol-amd64.deb s3://viact-devops/deb/
	@echo aws --profile vi s3 cp dcgm-exorter-amd64.deb s3://viact-devops/deb/
