# OT-Microservices --- Docker Compose Assignment 4

## Assignment overview

Repository: https://github.com/opstree/OT-Microservices

**Status summary:** Step 1 and Step 2 were completed and verified
locally. Step 3's image bundle and deployment folder were prepared for
transfer, but a successful run on the buddy's computer has not been
confirmed. Step 4 replicas were started and basic stop/restart tests
were performed; full backend health/high availability is not yet proven
because Employee API requests were observed returning HTTP 500. Step 5
(bonus) has not yet been demonstrated.

------------------------------------------------------------------------

## Step 1 --- Clone, build, and run the application

### What was done

-   Cloned the OT-Microservices repository.
-   Built six custom images: `ot-microservices-empms-es`,
    `ot-microservices-empms-db`, `ot-microservices-empms-attendance`,
    `ot-microservices-empms-salary`, `ot-microservices-empms-employee`,
    and `ot-microservices-empms-frontend`.
-   Started all eight services: those six services plus Kibana and
    Traefik.
-   Verified the frontend returned `HTTP 200 OK` through Traefik and
    loaded in the browser.

### File changes made

  ----------------------------------------------------------------------------------------------------------------------------------------------
  File                                                                                                       Change
  ---------------------------------------------------------------------------------------------------------- -----------------------------------
  `frontend/Dockerfile`                                                                                      Updated the frontend build/run
                                                                                                             steps for the legacy Node project:
                                                                                                             used
                                                                                                             `npm install --legacy-peer-deps`,
                                                                                                             installed `serve`, built the
                                                                                                             frontend, exposed port `3000`, and
                                                                                                             served the build on port `3000`.

  `attendance/config.yaml`                                                                                   Changed the MySQL host from a
                                                                                                             hard-coded container IP to the
                                                                                                             Compose service name `empms-db`, so
                                                                                                             Docker Compose DNS can resolve it.

  `salary/Dockerfile`                                                                                        Changed the builder image from
                                                                                                             `maven:latest` to
                                                                                                             `maven:3.9-eclipse-temurin-17` to
                                                                                                             build with the Java 17 toolchain.

  `salary/src/main/java/com/opstree/microservice/salary/service/SpringDataSalaryServiceImpl.java`            Replaced reliance on a
                                                                                                             Lombok-generated required-arguments
                                                                                                             constructor with an explicit
                                                                                                             constructor for `SalaryRepository`,
                                                                                                             resolving a compilation problem.

  `salary/src/main/java/com/opstree/microservice/salary/service/ElasticsearchRestTemplateServiceImpl.java`   Replaced reliance on a
                                                                                                             Lombok-generated constructor with
                                                                                                             an explicit constructor for
                                                                                                             `ElasticsearchRestTemplate`;
                                                                                                             removed unused imports while
                                                                                                             retaining the salary search method.

  `docker-compose.yaml`                                                                                      Changed Traefik from `traefik:v2.9`
                                                                                                             to `traefik:v3.6` after v2.9 logged
                                                                                                             that its Docker API client was too
                                                                                                             old. Changed host mappings to
                                                                                                             `8081:80` and `8082:8080` because
                                                                                                             host Nginx uses port 80 and Jenkins
                                                                                                             uses 8080.
  ----------------------------------------------------------------------------------------------------------------------------------------------

### Commands

``` bash
docker compose build
docker compose up -d
docker compose ps
```

The warning that `version: '3.2'` is obsolete is informational; Compose
ignores that attribute.

### Hostname routing

Traefik routes using `ot-microservices.opstree.com`. This entry was
added to the development machine's `/etc/hosts`:

``` text
127.0.0.1 ot-microservices.opstree.com
```

The frontend was verified at `http://ot-microservices.opstree.com:8081`.
Frontend loading alone does not prove all backend APIs are healthy.

------------------------------------------------------------------------

## Step 2 --- Run without the source-code folder

### What was done

Created a deployment directory outside the repository:

``` text
OT-Deployment/
├── docker-compose.yaml
└── config/
    ├── elasticsearch.yml
    ├── attendance-config.yaml
    └── employee-config.yaml
```

The deployment Compose file uses existing image names rather than
`build:` contexts. Bind mounts point to the copied configuration files.
Attendance and Employee configurations were saved under separate names
because both original files were named `config.yaml`.

The deployment uses Traefik `traefik:v3.6`, host ports `8081` and
`8082`, and named volumes for Elasticsearch and MySQL data.

### Validate and run

``` bash
cd ~/Music/mg/docker/Assignment-4/OT-Deployment
docker compose config -q
docker compose up -d
docker compose ps
```

The first deployment attempt failed because the original project already
occupied host port `3306`. The original stack was stopped with
`docker compose down` from its original directory, then the deployment
stack started successfully.

The frontend loaded from `OT-Deployment`. The original
`OT-Microservices` source folder was subsequently deleted, and the app
continued to load from `OT-Deployment`.

**Important:** Avoid `docker compose down -v` unless you intend to
remove named data volumes.

------------------------------------------------------------------------

## Step 3 --- Let a buddy run it without cloning

### What was prepared

Created `ot-microservices-images.tar`, containing the eight images used
by the deployment. The archive was approximately 2.3 GB and saved at:
`~/Music/mg/docker/Assignment-4/ot-microservices-images.tar`

Transfer both items to the buddy: 1. `ot-microservices-images.tar` 2.
The complete `OT-Deployment/` directory

The buddy needs Docker Engine and the Docker Compose plugin, and the
required host ports must be available.

### Commands for the buddy

After copying the archive and folder:

``` bash
docker load -i ot-microservices-images.tar
cd OT-Deployment
docker compose up -d
docker compose ps
```

The buddy must also make the hostname resolve to their own computer by
adding this to `/etc/hosts`:

``` text
127.0.0.1 ot-microservices.opstree.com
```

Then open `http://ot-microservices.opstree.com:8081`.

**Status:** The archive and deployment folder are prepared. A successful
run on the buddy's own computer still needs to be confirmed.

------------------------------------------------------------------------

## Step 4 --- Scale Employee, Salary, and Attendance

### Scaling command

From `OT-Deployment`:

``` bash
docker compose up -d \
  --scale empms-employee=2 \
  --scale empms-salary=2 \
  --scale empms-attendance=2
```

The intended replica count is:

  Service                Replicas
  -------------------- ----------
  `empms-employee`              2
  `empms-salary`                2
  `empms-attendance`            2

Inspect the containers with:

``` bash
docker compose ps
```

### Basic stop/restart tests

-   Stopped `ot-deployment-empms-employee-2`; Employee replica 1
    remained running. The second replica was restarted afterward.
-   Stopped `ot-deployment-empms-salary-2`; Salary replica 1 remained
    running. The second replica was restarted afterward.
-   Attendance replica 2 was stopped as part of the test and then
    restored.

To ensure the intended replicas are running again:

``` bash
docker compose up -d \
  --scale empms-employee=2 \
  --scale empms-salary=2 \
  --scale empms-attendance=2
```

### Important limitation

Two containers per service demonstrate scaling, but do not alone
guarantee production-grade high availability. The frontend remained
accessible during the Employee replica stop test, but that does not
prove the Employee API was healthy. Logs showed HTTP 500 responses for
routes such as `/employee/search/all`, `/employee/search/status`, and
`/employee/search/location`. A request to `/employee/` returned 404,
which may simply be an undefined route.

Investigate and resolve the Employee API 500 errors and verify Traefik
routing to healthy replicas before claiming full end-to-end high
availability. Standalone Docker Compose also does not automatically
provide all the orchestration/failover guarantees of a multi-node
orchestrator.

------------------------------------------------------------------------

## Step 5 --- Bonus: Run only Attendance and MySQL

This bonus has **not yet been demonstrated**.

From `OT-Deployment`, run:

``` bash
docker compose up -d empms-db empms-attendance
```

Attendance declares `empms-db` as a dependency, so Compose will start
MySQL as well. Verify with:

``` bash
docker compose ps
```

If the goal is to have *only* these two containers running, stop the
other services first or use a separate Compose configuration/profile for
the demonstration. The current full-stack Compose file also defines
Traefik and other services.

------------------------------------------------------------------------

## Ports used

  Component                   Host port   Container port
  ------------------------- ----------- ----------------
  Traefik web                    `8081`             `80`
  Traefik dashboard/API          `8082`           `8080`
  MySQL                          `3306`           `3306`
  Kibana                         `5601`           `5601`
  Elasticsearch HTTP             `9200`           `9200`
  Elasticsearch transport        `9300`           `9300`

Ensure these host ports are available on any machine running the
deployment. Host port `8080` was avoided because Jenkins uses it, and
host port `80` was avoided because Nginx uses it.

------------------------------------------------------------------------

## Final checklist

-   [x] Step 1: Build and run the app from the cloned repository;
    frontend verified.
-   [x] Step 2: Prepare `OT-Deployment`, run from prebuilt images,
    remove the source repository, and verify the frontend still loads.
-   [ ] Step 3: Buddy successfully loads the archive and runs the app
    without cloning.
-   [x] Step 4: Scale Employee, Salary, and Attendance to two replicas
    and perform basic stop/restart tests.
-   [ ] Step 4 follow-up: Investigate Employee API HTTP 500 errors and
    verify backend routing/failover before claiming full high
    availability.
-   [ ] Step 5 (bonus): Demonstrate running only Attendance and MySQL.
