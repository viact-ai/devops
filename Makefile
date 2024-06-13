.PHONY: scripts deb
scripts:
	aws --profile vi s3 cp scripts/noaws-gpu.otel-config.yaml s3://viact-devops/scripts/viact/noaws-gpu.otel-config.yaml
	aws --profile vi s3 cp scripts/noaws.otel-config.yaml s3://viact-devops/scripts/viact/noaws.otel-config.yaml
	aws --profile vi s3 cp scripts/aws.otel-config.yaml s3://viact-devops/scripts/viact/aws.otel-config.yaml
	aws --profile vi s3 cp scripts/viact.sh s3://viact-devops/scripts/viact/viact.sh

deb:
	dpkg --build deb/dcgm-exporter-amd64
  dpkg --build deb/otelcol-amd64
