JENKINS_URL=http://$1/ # localhost or jenkins elb url
if [ -f /etc/redhat-release ]; then
  AUTHFILE=/home/$SSH_USER/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/home/$SSH_USER/jenkins-cli.jar
elif [ -f /etc/lsb-release ]; then
  AUTHFILE=/root/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/root/jenkins-cli.jar
fi

echo "$0 $1 $2 "
cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.13">
  <scope>GLOBAL</scope>
  <description></description>
  <username>ec2-user</username>
  <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource">
	<privateKey>-----BEGIN RSA PRIVATE KEY-----MIIEogIBAAKCAQEA2iZ9wOu02qnBY1u2AzvVsMF8J4pzOLZrp0UX0jRmr91NM9DIrqJMXpPKw5S4CkikiMikCBEnGuz46tRaBqIr/+M5LAX5CKNStyO8p08IwTRH65LsFbGZkbDaHDRUZVJHMiWlpmr/fU7BiVejaTPGFruJzmbSkyGDYlGlY8qjaVl7b7OaxaObMUPtkawvsV+gOt5mnzhXPksligTEwzzpqgnMC3VkXs6GFXhTyCaVzvl4E0kC910FkPu3sBkr7yfW+LLJshhnjoql1Is11+tXzLtbdwHfvC9YQhdZiSHiJvqzjSsqUevkgYy/QGv3sOO5v6Mg4jW8FHEFjeW8KANg0wIDAQABAoIBAQCS51rF4LSgj7JYW3kdglyrtBAMfJKM/WNPeBrLhlgkU+3aV93cpBSzl+jyfiLVYgfSyPKVMB/aZPxW/vtE/k6M+hIVEEycwYdBJwKy1Gk72h4YiI8NKNUWpDasyZyPwrGJFosPn3w/gRqZh3fWr3PU+SOa5+kkBWx5eCvdIKecl9Rco7uSBBD5MBXdfITEA/H8LAci6Ok8p0QaImj3Z+UXVvywCsOnaT3kgu8nnomAEWVHA3EgkagaLMQ+kEB5LkwDW+o+31+d6Ryl7iSP0jhC7o9GvKMk94DXcISoagpgRlrcFkgCKRX8mDTtAcNry2IVcWC8ABUJhoOFw2FNshrxAoGBAOzY+rW5ow7qK4Jo/x/YSg15T6opm6ZzhWja1kzQlwjP8o2DVu32D2SNAeU4BQg7osUkXTwPLF5FyEVMiUzTrFOpXt64HH4brmpViLq+BLP6ObcS8VezU265YpMdVsMwIjkaLcoNXDh/dE+97K2DEbWpAlYp7QzDmq/lYL9b+Ny5AoGBAOvKdSpF9WG7+mTljHdzRGVmb2M+7di7aMzsfcwxFMWxIcisieRt1ZnXBZUMDtJxcLZ+FSb1uWZeOlRrvO/AsSr01o57CIONhwYAl3HHnTzw7RGmcR/c8cIzPMDY13FX3O60BR6ONiTTcJFPE4dU/MvkiW0DlUywi3QpizqFc1vrAn9JFqxHaAHpmFnU5JHWQeiYP9dVq4Fc3ElPEjkPe08gaQtwoBczV7toTBtJoP/sinqwW4hqAESw0tf6iqPUEX4cUyfzkt04DVLFfZ+0AO9ymsU0uaPAbJZSlOLWgzdDBJeLB4kZ0QWkabB66yEealQMuxr9e/Kq/bG+lgpFAxzJAoGAOa8ZBNOCmXtkYYSq3ZosdGYf//aoN2p51BBTIj4rp8WSz0Yuodyg8fbhnboKcj9gZLTptdNNnRaWTIri+QB6F1k4mDjPN2fLTZOdeS9tbzg9tyCx8iqaVnk0drVV15u4KAmQaw49frrfgh0HWQdYpQTu/eVvhAh4xV1Ye2OkeisCgYEAzdAYqHNpfCRjoAGMrzyZJgNfL6R3835hpRlt3PX9MwuV+Gp/951bKqsdOIyNPP3CYG/F4i2eNEXYK8ZpdSBSPJ+mHyVQw3EHQHWMnTjO76vX2zGfeMK3oBF18X0x+oCG22qqZ8G7bn6egien38zCkwIXFyppg8dGbTYa2mwbQSc=-----END RSA PRIVATE KEY-----</privateKey>
  </privateKeySource>
</com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF
