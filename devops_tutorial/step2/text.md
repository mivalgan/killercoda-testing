Now that we have Docker and Jenkins installed, we can create a Jenkins pipeline that will build a Docker image and check that it uses secure base images. To create the pipeline, we can use a Jenkinsfile, which is a text file that contains all the steps of the pipeline. But first, let's download a sample application that we will use during this tutorial.

## Download Node.js app
First, clone the repository that contains the sample Node.js application with the following command:

`git clone https://github.com/Ferran32/executable-tutorial.git /root/demo`{{exec}}

This application is a simple web server that fetches random jokes from an external API and displays them on a web page. The application listens on port 3000.


Then, navigate to the demo directory:

`cd /root/demo`{{exec}}

Now we also need to install Node.js and npm to be able to run the application. We can do this with the following commands:

**Download and install nvm:**

`curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash`{{exec}}

**in lieu of restarting the shell:**

`\. "$HOME/.nvm/nvm.sh"`{{exec}}

**Download and install Node.js:**

`nvm install 22`{{exec}}

**Verify the Node.js version:**

`node -v`{{exec}}

**Verify npm version:**

`npm -v`{{exec}}


Now we can install the dependencies of the application with:

`npm install express axios ejs`{{exec}}

Now, before jumping to creating the Jenkinsfile, let's create a simple Dockerfile that will be used to build the Docker image of the application. Move to the parent directory:

`cd ..`{{exec}}


## Create the Dockerfile
Now that we have the Jenkinsfile, we also need a Dockerfile to build the Docker image. Create a file named 'Dockerfile' with the following command:

`touch Dockerfile`{{exec}}


Then, open the file with a text editor, such as 'nano':

`nano Dockerfile`{{exec}}


Copy the following contents into the file:
```Dockerfile
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first (for better caching)
COPY demo/package*.json ./

# Install dependencies (axios, express, ejs)
RUN npm install axios express ejs

# Copy the rest of the app source code
COPY ./demo .

# Expose the app port
EXPOSE 3000

# Define the default command to run the app
CMD ["node", "server.js"]
```
Save the file and exit the text editor (in nano, `CTRL + O` + `ENTER` + `CTRL + X`).

## Jenkinsfile
Create a file named 'Jenkinsfile' with the following command:

`touch Jenkinsfile`{{exec}}


Then, open the file with a text editor, such as 'nano':

`nano Jenkinsfile`{{exec}}


Copy the following contents into the file:
```groovy
pipeline {
    agent any

    environment {
        APP_NAME = "jokes-app"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Check Base Image') {
            steps {
                script {
                    echo "Checking Dockerfile for secure base images"
                    def dockerfile = readFile('Dockerfile')
                    def fromLines = dockerfile.readLines().find { it.trim().startsWith('FROM') } // Get the used images

                    if (fromLines == null) {
                        error("Error: No Docker Images found in the Dockerfile.")
                    }

                    def invalidImages = []

                    formLines.each { line ->
                        def image = line.tokenize(' ')[1]
                        echo "Detected base image: ${image}"

                        if (!image.startsWith('cgr.dev/chainguard')) {
                            invalidImages.add(image)
                        }

                    }
                    if (invalidImages != []) {
                        error("Error: Insecure base images detected: ${invalidImages.join(', ')}. Please use Chainguard base images.")
                    }

                    echo "Dockerfile validated: using secure Chainguard base images"
                }
            }
        }

        stage('Build Container') {
            steps {
                script {
                    echo "Building Docker image ${APP_NAME}:${IMAGE_TAG}"
                    sh "docker build -t ${APP_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Replace Running Container') {
            steps {
                script {
                    echo "Replacing existing container with newer version"
                    // Stop and remove old container if exists
                    sh """
                    if [ \$(docker ps -q -f name=${APP_NAME}) ]; then
                        docker stop ${APP_NAME}
                        docker rm ${APP_NAME}
                    fi
                    """
                    // Start new container
                    sh "docker run -d --name ${APP_NAME} -p 3000:3000 ${APP_NAME}:${IMAGE_TAG}"
                    echo "Deployment successful: ${APP_NAME}:${IMAGE_TAG} is running."
                }
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed: App deployment stoped."
        }
        success {
            echo "Pipeline completed successfully: Container has been deployed."
        }
    }
}
```

Save the file and exit the text editor (in nano, `CTRL + O` + `ENTER` + `CTRL + X`).

This Jenkinsfile defines a pipeline with three stages:
1. **Check Base Image**: This stage reads the Dockerfile and checks if the base images used are from Chainguard. If any insecure images are found, the pipeline fails with an error message.
2. **Build Container**: This stage builds the Docker image using the Dockerfile in the current directory.
3. **Replace Running Container**: This stage stops and removes any existing container with the same name and starts a new container with the newly built image.

You can modify the `APP_NAME` and `IMAGE_TAG` environment variables to customize the name and tag of the Docker image.
