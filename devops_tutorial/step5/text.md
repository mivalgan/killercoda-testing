## Verify that the application runs
After changing this the Chainguard check should be correct and our app should be able to run.

We can verify this by doing

`jenkins-cli build secure-base-image-pipeline -f`{{exec}}

And we verify that the app runs smoothly.

To be sure that the container is running we could access the website URL, but since we do not have acces to a GUI we can see the running processes instead.

`ps aux | grep docker`{{exec}}

`docker ps`{{exec}}