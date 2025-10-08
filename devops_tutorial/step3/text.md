Now that we have our application, Dockerfile, and Jenkinsfile ready, let's create the Jenkins pipeline to automate the build and push process. Since we don't have access to the Jenkins UI in this environment, we'll create the pipeline using the Jenkins CLI.

**1- Start the Jenkins process:**
To check that Jenkins is running, you can use the following command:
`sudo systemctl status jenkins`{{exec}}

You should see a line like this when it's ready:
```plain
INFO: Jenkins is fully up and running
```

**2- Get the CLI jar file:**
`wget http://localhost:8080/jnlpJars/jenkins-cli.jar`{{exec}}

For simplicity you can set an alias for the Jenkins CLI command:
`alias jenkins-cli='java -jar /root/jenkins-cli.jar -s http://localhost:8080/ -http'`{{exec}}
The '-s' flag specifies that Jenkins should wait until the action is complete before exiting, thus allowing us to see the full output of the command and avoid timing issues.

From now on, this tutorial assumes that you have set the alias for the Jenkins CLI command.

**2.5- Disable authentication:**

According to documentation, to disable the authentication we must edit the config.xml file located in /var/lib/jenkins/config.xml. First, we need to stop the Jenkins service with:
`sudo systemctl stop jenkins`{{exec}}

Create a init script for Jenkins to create a user to use for authentication in the CLI:
```bash
sudo mkdir -p /var/lib/jenkins/init.groovy.d
sudo tee /var/lib/jenkins/init.groovy.d/create_admin.groovy > /dev/null <<'EOF'
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
EOF
```

And now let's manually run Jenkins to avoid getting the configuration overwritten when restarting the service:
`java -jar /usr/share/java/jenkins.war --httpPort=8080 &`{{exec}}

This command will start Jenkins in the background and you should see the logs in the terminal. Wait until you see the line that says "Jenkins is fully up and running".

Now we need to disable the CSRF protection to be able to use the CLI without issues. To do this, we can run the following commands:
```bash
sudo tee /var/lib/jenkins/init.groovy.d/disable_crumbs.groovy > /dev/null <<'EOF'
import jenkins.model.*
import hudson.security.csrf.*

def instance = Jenkins.getInstance()
instance.setCrumbIssuer(null)
instance.save()
println "CSRF protection disabled for automation."
EOF
```
And restart Jenkins manually again to apply the changes:
`pkill -f jenkins.war && java -jar /usr/share/java/jenkins.war --httpPort=8080 &`{{exec}}

Now let's get the API Token for the admin user we just created, create a script file with:
`nano get_api_token.sh`{{exec}}
And copy the following contents into the file:
```bash
JENKINS_URL=http://localhost:8080
ADMIN_USER=admin
ADMIN_PASS=admin

curl -s -u $ADMIN_USER:$ADMIN_PASS \
  -X POST \
  -d "newTokenName=killercoda-token" \
  $JENKINS_URL/user/$ADMIN_USER/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken

```

Now give execution permissions to the script and run it:
`chmod +x get_api_token.sh`{{exec}}

`./get_api_token.sh`{{exec}}

This will output a JSON object containing the token. Look for the "tokenValue" field in the output, which contains the API token. Copy this token and use it in the next command to set up the CLI authentication.
Now set the JENKINS_USER and JENKINS_API_TOKEN environment variables with the following commands (replace <your_token> with the token you just copied):
`export JENKINS_USER=admin`{{exec}}
`export JENKINS_API_TOKEN=<your_token>`

**4- Create the pipeline:**
First, create a new pipeline job named 'secure-base-image-pipeline' with the following command:
`jenkins-cli -auth $JENKINS_USER:$JENKINS_API_TOKEN create-job secure-base-image-pipeline < Jenkinsfile`{{exec}}
This command creates a new Jenkins job using the configuration defined in the Jenkinsfile.

**5- Run the pipeline:**
Now that we have created the pipeline job, we can run it and test our Dockerfile with the command below:
`jenkins-cli -auth $JENKINS_USER:$JENKINS_API_TOKEN build secure-base-image-pipeline -f`{{exec}}
This command triggers the execution of the pipeline job we just created. The `-f` follows the live build of the pipeline, thus allowing us to see at which step the pipeline is in every moment.

You should see that the pipeline fails to run, since we are using an insecure base image. The pipeline should fail at the step where it checks for secure base images. We will fix this in the next step.

**6- Check the logs after the execution: (optional)**
In case you want to check the logs of the pipeline execution, you can do so with the following command:
`jenkins-cli console secure-base-image-pipeline`{{exec}}

Documentation for the Jenkins CLI can be found [here](https://www.jenkins.io/doc/book/managing/cli/).