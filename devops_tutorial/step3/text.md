Now that we have our application, Dockerfile, and Jenkinsfile ready, let's create the Jenkins pipeline to automate the build and push process. Since we don't have access to the Jenkins UI in this environment, we'll create the pipeline using the Jenkins CLI.

**1- Start the Jenkins process:**

`jenkins --httpPort=9090 &>/var/log/jenkins.log &`{{exec}}

We are using a different port (9090) to avoid conflicts with existing port listeners used by the Killercoda platform.

Wait a bit for Jenkins to start, then check the log file to see when it's ready:

`tail -f /var/log/jenkins.log`{{exec}}

You should see a line like this when it's ready:
```plain
INFO: Jenkins is fully up and running
```

**2- Get the CLI jar file:**
`wget http://localhost:9090/jnlpJars/jenkins-cli.jar`{{exec}}

For simplicity you can set an alias for the Jenkins CLI command:
`alias jenkins-cli='java -jar /root/jenkins-cli.jar -s http://localhost:9090/ -http'`{{exec}}
The '-s' flag specifies that Jenkins should wait until the action is complete before exiting, thus allowing us to see the full output of the command and avoid timing issues.

From now on, this tutorial assumes that you have set the alias for the Jenkins CLI command.

**3- Authentication:**
In this step, we should authenticate to Jenkins, using the initial admin password. You can find the password in the log file:
`cat /var/lib/jenkins/secrets/initialAdminPassword`{{exec}}

This password is needed to perform the initial access and setup of Jenkins, in their GUI. However, since we are using the CLI, we cannot use this password directly, therefore, since this is a demo , we will disable the security temporarily to be able to create the pipeline. To do this we can run the following command:

`sudo sed -i 's#<useSecurity>true</useSecurity>#<useSecurity>false</useSecurity>#' /var/lib/jenkins/config.xml`{{exec}}

You can check that the security is disabled by running:
`grep useSecurity /var/lib/jenkins/config.xml`{{exec}}

Now restart the Jenkins service to apply the changes:
`sudo systemctl restart jenkins`{{exec}}

Check that the service is running with:
`sudo systemctl status jenkins`{{exec}}


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