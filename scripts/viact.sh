#!/usr/bin/env bash
# viact.sh -l name=signoz,team=software,project=monitor -i otel -i falco -t aws
usage() {
    echo -e '''Script using for install agent on server and workstation.

Usage:
  viact.sh -l [opentelemetry attribution] -i [agent] -t [config template]

Flags:
  -l\tOpentelemetry attribution (example -l name=backend,team=software,project=dotnet)
  -t\tInstall agent with config template (aws, noaws), default "aws" (example -t aws)
  -i\tAgent want to install (otel, falco)
    \tThis is multiple choice option (example -i otel -i falco)

Example:
  Install opentelemetry with attribution and falco
  viact.sh -l name=signoz,team=software,project=monitor -i otel -i falco

  Install opentelemetry only
  viact.sh -l name=signoz,team=software,project=monitor -i otel

  Install opentelemetry with cofig template for non aws resource
  viact.sh -l name=signoz,team=software,project=monitor -i otel -t noaws

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

    rm -f otelcol-amd64.deb
    trap "rm -f otelcol-amd64.deb" EXIT
    curl -sSLO https://viact-devops.s3.ap-southeast-1.amazonaws.com/deb/otelcol-amd64.deb
    dpkg --install otelcol-amd64.deb

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

otel=false
falco=false
config_template="aws"
otel_attrs=""

while getopts ":l:i:t:" o; do
    case "${o}" in
        l)
            otel_attrs=${OPTARG}
            ;;
        i)
            for app in ${OPTARG[@]}; do
                [[ $app == "otel" ]] && otel=true
                [[ $app == "falco" ]] && falco=true
            done
            ;;
        t)
            [[ -n ${OPTARG} ]] && config_template=${OPTARG}
            ;;
    esac
done

if [[ $otel == "false" ]] && [[ $falco == "false" ]]; then
    usage
fi

if [[ $otel == "true" ]]; then
    install_otel
fi


if [[ $falco == "true" ]]; then
    install_falco
fi
