# JupyterContainer
A container for jupyter notebook. This should only be used for local or development purposes. Do not use this in production environments!

The dockerfile builds an image with an encapsulated jupyter notebook that operates independently of the host's environment. This way, the operator does not need to worry about how python, environmental variables, or the OS in general is set up. 

## Instructions
The suggested run command mounts the notebook folder so that any files created will be saved on the host and not be lost when the container closes.
```
docker run -p 127.0.0.1:8888:8888 -v .\notebook:/root/notebook jupyter-container:latest
```
