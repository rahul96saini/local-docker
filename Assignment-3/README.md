# Docker Assignment 3 — Hello Node.js

## Objective

Build a Docker image using Alpine Linux, install Node.js, and run a small Node.js application inside a container.

## Project Files

```text
Assignment-3/
├── Dockerfile
├── index.js
└── README.md
```

## 1. Application: `index.js`

```javascript
var os = require("os");
var hostname = os.hostname();
console.log("hello from " + hostname);
```

This application gets the hostname of the machine where it runs and prints a greeting. When run inside Docker, the hostname is the container's hostname.

## 2. Dockerfile

```dockerfile
FROM alpine:latest

LABEL maintainer="Your Name"

RUN apk update && apk add --no-cache nodejs

COPY . /app

WORKDIR /app

CMD ["node", "index.js"]
```

Replace `Your Name` with your name in the `LABEL` instruction if you have not already done so.

### Dockerfile Instructions

- `FROM alpine:latest`: Uses Alpine Linux as the base image.
- `LABEL maintainer="Your Name"`: Adds maintainer information to the image.
- `RUN apk update && apk add --no-cache nodejs`: Updates Alpine's package index and installs Node.js.
- `COPY . /app`: Copies the project files into `/app` inside the image.
- `WORKDIR /app`: Sets `/app` as the working directory.
- `CMD ["node", "index.js"]`: Runs the Node.js application when a container starts.

## 3. Build the Docker Image

Run this command from the project directory:

```bash
docker build -t hello:v0.1 .
```

- `-t hello:v0.1` names and tags the image.
- `.` specifies the current directory as the build context.

## 4. Verify the Image

```bash
docker images
```

Confirm that `hello` appears in the repository column and `v0.1` appears in the tag column.

## 5. Run the Container

```bash
docker run hello:v0.1
```

Example output:

```text
hello from 1871198096f8
```

The hostname will differ each time or on another system.

## 6. Verify the Container Status

```bash
docker ps
docker ps -a
```

- `docker ps` lists running containers. It may show no containers because this application exits after printing its message.
- `docker ps -a` lists all containers, including stopped ones. The container should show `Exited (0)`, indicating successful execution.

## Result

The Docker image `hello:v0.1` was built successfully, and the Node.js application ran inside a container and printed its hostname.

## Cleanup (Optional)

Remove the stopped container using its container ID or name:

```bash
docker rm <container-id-or-name>
```

Remove the image only if you no longer need it:

```bash
docker rmi hello:v0.1
```
