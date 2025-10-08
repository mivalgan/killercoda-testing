# Correcting the container

As we saw in the previous point, our application did not pass Chainguard tests.
This is due to the container not being an official Chainguard container that is guaranteed to be the safest version. So if we want to fix this we need to change the container that we are using to an official image from chainguard.
This can be done by configuring the Dockerfile correctly.
For that we do:

`nano Dockerfile`{{exec}}

And replace the contents of the Dockerfile to the following ones:
```Dockerfile
FROM cgr.dev/chainguard/node:latest
USER root
WORKDIR /usr/src/app
COPY demo/package*.json ./
RUN npm install axios express ejs
COPY ./demo .
CMD ["node", "server.js"]

```
Save the file and exit the text editor (in nano, `CTRL + O` + `ENTER` + `CTRL + X`).

We also need to copy the Dockerfile to the corresponding directory, so that Jenkins can access it. We can do this with the following command:
`cp Dockerfile /var/lib/jenkins/workspace/secure-base-image-pipeline/Dockerfile`{{exec}}