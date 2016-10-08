# goodguide/newrelic-sysmond

This is a small Docker image which runs the [NewRelic Server](https://docs.newrelic.com/docs/servers/new-relic-servers-linux/getting-started/new-relic-servers-linux) agent.

It's not working entirely; filesystems are not reporting and Docker reporting is only partially reporting.

## Usage

Run it with the following required settings:

```shell
docker run \
    --pid=host \
    --net=host \
    -v /dev:/dev:ro \
    -v /sys:/sys:ro \
    -v /var/lib/docker.sock:/var/lib/docker.sock:ro \
    -e NEWRELIC_LICENSE_KEY='your licence key here' \
    goodguide/newrelic-sysmond
```

## Configuration

The following environment variables are consumed on boot to configure `nrsyslogd`:

- `NEWRELIC_LICENSE_KEY`
- `NEWRELIC_LABELS` - an optional string with the format `Key1:value1;Key2:value2;` (that is, a list of key/value pairs separated by colon `:`, with each pair having a trailing semicolon `;` [including the trailing one]).
- `NEWRELIC_HOSTNAME` - the hostname `nrsyslogd` will report the instance as. If you're running on EC2, you can specify the special value `%ec2-metadata` which will result in the container grabbing the public DNS name of the instance from the EC2 Instance Metadata service.
