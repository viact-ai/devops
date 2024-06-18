#!/usr/bin/env bash
# viact.sh -l name=signoz,team=software,project=monitor -i otel -i falco -t aws -a amd64
usage() {
    echo -e '''Script using for install agent on server and workstation.

Usage:
  viact.sh -l [opentelemetry attribution] -i [agent] -t [config template] -a [cpu arch]

Flags:
  -l\tOpentelemetry attribution (example -l name=backend,team=software,project=dotnet)
  -t\tInstall agent with config template (aws, noaws, noaws-gpu), default "aws" (example -t aws)
  -a\tInstall agent running on specific CPU architect (amd64, arm64, armhv7), default "amd64" (example -a amd64)
  -i\tAgent want to install (otel, falco, dcgm_exporter)
    \tThis is multiple choice option (example -i otel -i falco -i dcgm_exporter)

Example:
  Install opentelemetry with attribution and falco
  viact.sh -l name=signoz,team=software,project=monitor -i otel -i falco

  Install opentelemetry only
  viact.sh -l name=signoz,team=software,project=monitor -i otel

  Install opentelemetry with config template for non aws resource
  viact.sh -l name=signoz,team=software,project=monitor -i otel -t noaws

  Install opentelemetry and dcgm exporter with config template for noaws to monitor workstation with GPU
  viact.sh -l name=signoz,team=software,project=monitor -i otel -i dcgm_exporter -t noaws-gpu

  Install opentelemetry with config template for noaws to monitor workstation with GPU, dcgm-exporter is pre-installed
  viact.sh -l name=signoz,team=software,project=monitor -i otel -t noaws-gpu

  Install falco only
  viact.sh -i falco'''
}

install_otel() {
    [[ -z $otel_attrs ]] && echo "Skipped, opentelemetry not have any attribution" && return
    echo "Installing opentelemetry agent"
    IFS=',' read -ra attrs <<< "$otel_attrs"

    attrs_yaml=""
    for attr in ${attrs[@]}; do
        echo $attr | grep -e ".=." > /dev/null
        [[ $? != "0" ]] && echo "Skipped, attribution $attr is not valid" && return
        key=`echo $attr | cut -d "=" -f1`
        value=`echo $attr | cut -d "=" -f2`
        attrs_yaml="${attrs_yaml}      - key: $key\n        value: $value\n        action: insert\n"
    done

    rm -f otelcol-${arch}.deb
    trap "rm -f otelcol-${arch}.deb" EXIT
    curl -sSLO https://viact-devops.s3.ap-southeast-1.amazonaws.com/deb/otelcol-${arch}.deb
    dpkg --install otelcol-${arch}.deb

    config=`curl -sSL https://viact-devops.s3.ap-southeast-1.amazonaws.com/scripts/viact/${config_template}.otel-config.yaml`
    # echo "$config" | sed 's|{{ OTEL_ATTR }}|'"$attrs_yaml"'|g' | \
        #     sed 's|{{ OTEL_USERNAME }}|'"$OTEL_USERNAME"'|g' | \
        #     sed 's|{{ OTEL_PASSWORD }}|'"$OTEL_PASSWORD"'|g'
    echo "$config" | sed 's|{{ OTEL_ATTR }}|'"$attrs_yaml"'|g' | \
        sed 's|{{ OTEL_USERNAME }}|'"$OTEL_USERNAME"'|g' | \
        sed 's|{{ OTEL_PASSWORD }}|'"$OTEL_PASSWORD"'|g' > /etc/otelcol/config.yaml

    systemctl restart otelcol

    echo "Install opentelemetry done"
}

install_falco() {
    echo "Installing falco agent"
    echo "Install falco done"
}


install_dcgm() {
    echo "Installing dcgm exporter agent"

    rm -f dcgm-exporter-${arch}.deb
    trap "rm -f dcgm-exporter-${arch}.deb" EXIT
    curl -sSLO https://viact-devops.s3.ap-southeast-1.amazonaws.com/deb/dcgm-exporter-${arch}.deb
    dpkg --install dcgm-exporter-${arch}.deb

    systemctl restart dcgm-exporter

    echo "Install dcgm exporter done"
}

otel=false
falco=false
dcgm_exporter=false
config_template="aws"
arch="amd64"
otel_attrs=""

while getopts ":l:i:t::a:" o; do
    case "${o}" in
        l)
            otel_attrs=${OPTARG}
            ;;
        i)
            for app in ${OPTARG[@]}; do
                [[ $app == "otel" ]] && otel=true
                [[ $app == "falco" ]] && falco=true
                [[ $app == "dcgm_exporter" ]] && dcgm_exporter=true
            done
            ;;
        t)
            [[ -n ${OPTARG} ]] && config_template=${OPTARG}
            ;;
        a)
            [[ -n ${OPTARG} ]] && arch=${OPTARG}
            ;;
    esac
done

if [[ $otel == "false" ]] && [[ $falco == "false" ]] && [[ $dcgm_exporter == "false" ]]; then
    usage
    exit 0
fi


if [[ $otel == "true" ]]; then
    install_otel
fi
if [[ $falco == "true" ]]; then
    install_falco
fi
if [[ $dcgm_exporter == "true" ]]; then
    install_dcgm
fi
