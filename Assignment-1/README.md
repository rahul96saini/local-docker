# Docker Assignment 1

This assignment contains two Docker tasks:

- **Part 1:** Host a static website using Docker with a time-based response.
- **Part 2:** Create a directory structure in a Docker container and configure Linux permissions.

---

# Part 1 — Static Website with Time-Based Response

## Objective

Create a Docker container that hosts a static website and displays a different message depending on the current time.

### Requirements

- Team name: **DevOps Daredevils**
- Name: **Rahul**
- Buddy name: **Aryan**
- Local domain used for testing: `rahul.devopsdaredevils.com`
- First 2 minutes: `Hello from Rahul`
- Next 2 minutes: `Hello from Aryan`
- The 4-minute cycle repeats continuously.

### Time Logic

```text
Minute 0–1  → Hello from Rahul
Minute 2–3  → Hello from Aryan
Minute 4–5  → Hello from Rahul
Minute 6–7  → Hello from Aryan
...
```

## Project Structure

```text
docker-part1/
├── Dockerfile
└── app.sh
```

## app.sh

```bash
#!/bin/sh

while true
do
    MINUTE=$(date +%M)
    MINUTE=$((10#$MINUTE))

    REMAINDER=$((MINUTE % 4))

    if [ "$REMAINDER" -lt 2 ]; then
        MESSAGE="Hello from Rahul"
    else
        MESSAGE="Hello from Aryan"
    fi

    cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>DevOps Daredevils</title>
</head>
<body>
    <h1>$MESSAGE</h1>
</body>
</html>
EOF

    sleep 10
done
```

## Dockerfile

```dockerfile
FROM nginx:alpine

COPY app.sh /app.sh

RUN chmod +x /app.sh

CMD /app.sh & nginx -g "daemon off;"
```

## Build the Docker Image

```bash
chmod +x app.sh
docker build -t rahul-static-site .
```

## Run the Container

Port `8080` was already being used by Jenkins, so Docker port `8081` was used:

```bash
docker run -d --name rahul-static-site -p 8081:80 rahul-static-site
```

Check the container:

```bash
docker ps
```

## Test Using curl

```bash
curl http://localhost:8081
```

Expected response:

```text
Hello from Rahul
```

or:

```text
Hello from Aryan
```

depending on the current 4-minute cycle.

## Configure the Local Domain

Because this assignment was tested locally, `/etc/hosts` was used instead of a public DNS record.

Edit:

```bash
sudo nano /etc/hosts
```

Add:

```text
127.0.0.1    rahul.devopsdaredevils.com
```

Test:

```bash
curl http://rahul.devopsdaredevils.com:8081
```

The website can also be opened in a browser:

```text
http://rahul.devopsdaredevils.com:8081
```

### Part 1 Result

The static website was successfully hosted in Docker and verified through the browser and curl.

---

# Part 2 — Docker Directory Permissions

## Objective

Create the following directory structure inside a Docker container:

```text
Data/
└── Ninjas/
    ├── Mohan/
    ├── Uma/
    ├── Shikha/
    └── Mayank/
```

The container runs as **Mohan**.

Mohan must have:

```text
Mohan directory → Read + Write
Other directories → Read only
```

## Project Structure

```text
docker-part2/
└── Dockerfile
```

## Dockerfile

```dockerfile
FROM ubuntu:24.04

# Create users
RUN useradd -m Mohan && \
    useradd -m Uma && \
    useradd -m Shikha && \
    useradd -m Mayank

# Create directory structure
RUN mkdir -p /Data/Ninjas/Mohan \
             /Data/Ninjas/Uma \
             /Data/Ninjas/Shikha \
             /Data/Ninjas/Mayank

# Set ownership
RUN chown Mohan:Mohan /Data/Ninjas/Mohan && \
    chown Uma:Uma /Data/Ninjas/Uma && \
    chown Shikha:Shikha /Data/Ninjas/Shikha && \
    chown Mayank:Mayank /Data/Ninjas/Mayank

# Set permissions
RUN chmod 755 /Data/Ninjas/Mohan && \
    chmod 755 /Data/Ninjas/Uma && \
    chmod 755 /Data/Ninjas/Shikha && \
    chmod 755 /Data/Ninjas/Mayank

# Run the container as Mohan
USER Mohan

CMD ["bash"]
```

## Build the Docker Image

```bash
docker build -t ninjas-permission .
```

## Run the Container

```bash
docker run -it --name ninjas-container ninjas-permission
```

The container starts as:

```text
Mohan@<container-id>:/$
```

Verify the user:

```bash
whoami
```

Expected:

```text
Mohan
```

## Check Directory Permissions

```bash
ls -ld /Data/Ninjas/*
```

The directories are owned by their respective users and use `755` permissions.

Conceptually:

```text
Directory       Mohan Access
----------------------------
Mohan/          Read + Write
Uma/            Read only
Shikha/         Read only
Mayank/         Read only
```

### Why `755`?

For a directory:

```text
r = read/list contents
w = create/delete files
x = enter/access directory
```

`755` means:

```text
Owner  → rwx
Others → r-x
```

Therefore, Mohan can write to his own directory because he owns it. For the other directories, Mohan is not the owner, so he gets read/execute access but not write access.

### Part 2 Result

The Docker container was successfully configured to run as Mohan with the required directory permissions.

---

# Docker Commands Used

## View running containers

```bash
docker ps
```

## View all containers

```bash
docker ps -a
```

## View images

```bash
docker images
```

## Stop a container

```bash
docker stop <container-name>
```

## Remove a container

```bash
docker rm <container-name>
```

## Remove an image

```bash
docker rmi <image-name>
```

---

# Final Assignment Result

```text
Assignment 1
│
├── Part 1
│   ├── Docker static website
│   ├── Nginx
│   ├── Time-based Rahul/Aryan response
│   └── Local domain
│
└── Part 2
    ├── Ubuntu Docker container
    ├── Users: Mohan, Uma, Shikha, Mayank
    ├── Data/Ninjas directory structure
    └── Linux directory permissions
```

Both parts were completed and tested locally using Docker.
