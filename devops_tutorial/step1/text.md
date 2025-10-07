## Docker
```bash
# Add Docker's official GPG key:
`sudo apt-get update`{{exec}}
`sudo apt-get install ca-certificates curl`{{exec}}
`sudo install -m 0755 -d /etc/apt/keyrings`{{exec}}
`sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc`{{exec}}
`sudo chmod a+r /etc/apt/keyrings/docker.asc`{{exec}}

# Add the repository to Apt sources:
`echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null`{{exec}}
`sudo apt-get update`{{exec}}

Install the latest version:
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

If you get the following error:
```bash
Configuration file '/etc/containerd/config.toml'
 ==> File on system created by you or by a script.
 ==> File also in package provided by package maintainer.
 ```
Then type the 'Y' key and press enter to accept the package maintainer's version. Then wait a bit and check the status of the docker service with:

```bash
sudo systemctl status docker
```

Note: If the status command shows that the service is not running, you can start it with:
```bash
sudo systemctl start docker
```

## Jenkins
To install Jenkins we first need to install Java. That can be done with the following commands:
```bash
sudo apt update
sudo apt install fontconfig openjdk-21-jre
java -version
```
Once you have Java installed, you can install the Long Term Service release of Jenkins with the following commands:
```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins
```