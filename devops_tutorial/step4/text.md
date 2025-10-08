# Correcting the container

As we saw in the previous point, our application did not pass Chainguard tests.
This is due to the container not being an official Chainguard container that is guaranteed to be the safest version. So if we want to fix this we need to change the container that we are using to an official image from chainguard.
This can be done by configuring the Dockerfile correctly.
For that we do:

`nano Dockerfile`{{exec}}

And change the first line to:
Copy the following contents into the file:
```Dockerfile
FROM cgr.dev/chainguard/node
```
Save the file and exit the text editor (in nano, `CTRL + O` + `ENTER` + `CTRL + X`).
