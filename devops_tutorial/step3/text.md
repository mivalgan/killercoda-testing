Now that we have our application, Dockerfile, and Jenkinsfile ready, let's create the Jenkins pipeline to automate the build and push process. Since we don't have access to the Jenkins UI in this environment, we'll create the pipeline using the Jenkins CLI.

**1- Start the Jenkins process:**

`jenkins &>/var/log/jenkins.log &`{{exec}}

Wait a bit for Jenkins to start, then check the log file to see when it's ready:

`tail -f /var/log/jenkins.log`{{exec}}

You should see a line like this when it's ready:
```plain
INFO: Jenkins is fully up and running
```

**2- Get the CLI jar file:**
`wget http://localhost:8080/jnlpJars/jenkins-cli.jar`{{exec}}

**3- Get the initial admin token:**
`cat /var/lib/jenkins/users/admin_*/config.xml`{{exec}}

Look for the line that contains `<passwordHash>`, it should look something like this:
```plain
<passwordHash>#jbcrypt:$2a$10$...</passwordHash>
```

Copy the entire hash (the part after `#jbcrypt:`) as you'll need it to authenticate with the Jenkins CLI.

Run the following commands to set up the environment variables for the Jenkins CLI:
`export JENKINS_USER=admin`{{exec}}
`export JENKINS_TOKEN=<your_password_hash_here>`{{exec}}

For simplicity you can set an alias for the Jenkins CLI command:
`alias jenkins-cli='java -jar /root/jenkins-cli.jar -s http://localhost:8080/'`{{exec}}
The '-s' flag specifies that Jenkins should wait until the action is complete before exiting, thus allowing us to see the full output of the command and avoid timing issues.

From now on, this tutorial assumes that you have set the alias for the Jenkins CLI command.

**4- Create the pipeline:**
First, create a new pipeline job named 'secure-base-image-pipeline' with the following command:
`jenkins-cli create-job secure-base-image-pipeline < Jenkinsfile`{{exec}}
This command creates a new Jenkins job using the configuration defined in the Jenkinsfile.

**5- Run the pipeline:**
Now that we have created the pipeline job, we can run it and test our Dockerfile with the command below:
`jenkins-cli build secure-base-image-pipeline -f`{{exec}}
This command triggers the execution of the pipeline job we just created. The `-f` follows the live build of the pipeline, thus allowing us to see at which step the pipeline is in every moment.

You should see that the pipeline fails to run, since we are using an insecure base image. The pipeline should fail at the step where it checks for secure base images. We will fix this in the next step.

**6- Check the logs after the execution: (optional)**
In case you want to check the logs of the pipeline execution, you can do so with the following command:
`jenkins-cli console secure-base-image-pipeline`{{exec}}

Documentation for the Jenkins CLI can be found [here](https://www.jenkins.io/doc/book/managing/cli/).