#!/bin/bash

set -euo pipefail

# lookup metric from metadata API (taken from the /opt/aws/bin/ec2-metadata in an Amazon Linux AMI)
ec2_metadata_lookup() {
	local metric_path=$1; shift
	local response="$(curl -fsq http://169.254.169.254/latest/${metric_path}/)"
	if [[ $? == 0 ]]; then
		echo "$response"
	else
		return $?
	fi
}

configure() {
	file="$1"; shift

	cat <<-EOF > "$file"
		license_key=${NEWRELIC_LICENSE_KEY}
		#host_root=/host
		loglevel=debug
		logfile=/dev/stdout
		hostname="${NEWRELIC_HOSTNAME:-${HOSTNAME:-unknown}}"
	EOF

	if [[ ${NEWRELIC_LABELS:-} ]]; then
		cat <<-EOF >> "$file"
			labels=${NEWRELIC_LABELS}
		EOF
	fi

	echo "NewRelic config file:"
	cat -n "$file"
	echo
}

main() {
	local config_file="${NEWRELIC_CONFIG_FILE:-/etc/newrelic/nrsysmond.cfg}"

	# In our case, we're running this in Amazon ECS, and environment variables are set at the service-level, thus cannot be as dynamic as needed to accurately set the hostname before starting the container. To work around this, the follwing value for NEWRELIC_HOSTNAME is special -- if given, we'll pull in the instance's EC2 "public hostname" from the metadata API
	if [[ ${NEWRELIC_HOSTNAME:-} = '%ec2-metadata' ]]; then
		NEWRELIC_HOSTNAME="$(ec2_metadata_lookup 'meta-data/public-hostname')"
	fi

	configure "$config_file"

	local params=(
		-F
		-c "${config_file}"
		"$@"
	)

	echo "exec nrsysmond ${params[@]}"
	exec nrsysmond "${params[@]}"
}

main "$@"
