# Docker Assignment 2 — Node.js HTTP Server

## Overview

This assignment demonstrates how to create a Docker image using `ubuntu:latest`, install Node.js and npm, install `http-server`, copy a local HTML file into the image, and run the web server inside a container.

## Project Structure

```text
Assignment-2/
├── Dockerfile
└── usr/
    └── apps/
        └── hello-docker/
            └── index.html
```

## Dockerfile

```dockerfile
FROM ubuntu:latest

LABEL maintainer="Rahul Saini"

RUN apt-get update

RUN apt-get install -y nodejs

RUN apt-get install -y npm

# Symlink is already created by the Node.js package in the latest Ubuntu image.
# /usr/bin/nodejs -> /usr/bin/node
# RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install -g http-server

COPY usr/apps/hello-docker/index.html /usr/apps/hello-docker/index.html

WORKDIR /usr/apps/hello-docker/

CMD ["http-server", "-s"]
```

## Important Note About the Symlink

The assignment asks to create:

```bash
ln -s /usr/bin/nodejs /usr/bin/node
```

However, with the current `ubuntu:latest` image, installing the `nodejs` package already provides:

```text
/usr/bin/node      -> actual Node.js executable
/usr/bin/nodejs    -> symlink to /usr/bin/node
```

Therefore, running the assignment's `ln -s` command causes:

```text
ln: failed to create symbolic link '/usr/bin/node': Already exists
```

The command was therefore commented out instead of replacing the existing Node.js executable.

## Build the Docker Image

From the assignment directory:

```bash
docker build -t rahul:docker-web .
```

Verify the image:

```bash
docker images
```

## Run the Container

Jenkins was already using host port `8080`, so host port `8081` was used while keeping the application's container port at `8080`.

```bash
docker run -d --name hello-docker -p 8081:8080 rahul:docker-web
```

Port mapping:

```text
Host:8081  →  Container:8080  →  http-server
```

Check the running container:

```bash
docker ps
```

Expected port mapping:

```text
0.0.0.0:8081->8080/tcp
```

## Access the Webpage

Open:

```text
http://localhost:8081/index.html
```

If accessing the VM from another machine:

```text
http://<VM-IP>:8081/index.html
```

The webpage was successfully accessed during testing.

