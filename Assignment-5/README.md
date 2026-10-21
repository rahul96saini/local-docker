# Assignment 5 -- OT-Microservices Pods

## Objective

Create Kubernetes Pods for the OT-Microservices application and validate
each component according to the Assignment 5 steps.

## Prerequisites

-   Minikube is running.
-   The required OT-Microservices images are available in Minikube.
-   Run the commands below from the `Assignment-5` directory unless
    stated otherwise.

Check the cluster:

``` bash
kubectl get nodes
kubectl get pods
```

------------------------------------------------------------------------

## Step 1: Attendance Setup

### Option 1: MySQL and Attendance in Separate Pods

This assignment uses Option 1: MySQL runs in one Pod and Attendance runs
in another.

Resources: - MySQL Pod: `empms-db` - MySQL Service: `empms-db` on port
`3306` - Attendance Pod: `empms-attendance` - Attendance Service:
`empms-attendance` on port `8081`

Apply the manifests:

``` bash
kubectl apply -f mysql/mysql.yaml
kubectl apply -f attendance/attendance.yaml
```

Check the Pods and logs:

``` bash
kubectl get pods
kubectl logs empms-db
kubectl logs empms-attendance
```

Check Attendance-to-MySQL TCP connectivity:

``` bash
kubectl exec empms-attendance -- python -c "import socket; s=socket.create_connection(('empms-db', 3306), timeout=5); print('MySQL connection successful'); s.close()"
```

**Observed result:** Both Pods were running, MySQL logs showed it was
ready for connections, and the TCP connectivity test succeeded.

**Validation note:** The TCP test confirms that Attendance can reach
MySQL on port 3306. It does not independently prove SQL authentication
or successful application-level database operations.

------------------------------------------------------------------------

## Step 2: Elasticsearch, Salary, and Employee

### 2.1 Run Elasticsearch Pod

Resources: - Elasticsearch Pod: `empms-es` - Elasticsearch Service:
`empms-es` on ports `9200` and `9300` - Cluster name: `ot-microservices`

Apply and check:

``` bash
kubectl apply -f elasticsearch/elasticsearch.yaml
kubectl get pods
kubectl logs empms-es
```

Validate the Elasticsearch API with authentication:

``` bash
kubectl exec empms-es -- curl -s -u elastic:elastic http://localhost:9200
```

**Observed result:** Elasticsearch returned JSON identifying cluster
`ot-microservices` and version `8.4.3`.

### 2.2 Run Salary Pod

Salary configuration: - ConfigMap: `salary-config` - Configuration file:
`salary-config.yaml` - Elasticsearch URL: `http://empms-es:9200` -
Salary container port: `8080`

Create the ConfigMap and apply the manifest:

``` bash
kubectl create configmap salary-config --from-file=config.yaml=salary-config.yaml
kubectl apply -f salary.yaml
```

Check status and logs:

``` bash
kubectl get pods
kubectl logs empms-salary
```

**Observed result:** The Salary Pod was `1/1 Running`. Its logs
confirmed that the Spring Boot application started on port `8080`.

### 2.3 Run Employee Pod

Employee configuration: - ConfigMap: `employee-config` - Source
configuration:
`../Assignment-4/OT-Deployment/config/employee-config.yaml` -
Elasticsearch URL: `http://empms-es:9200` - Employee API port: `8083`

Create the ConfigMap and apply the manifest:

``` bash
kubectl create configmap employee-config --from-file=config.yaml=../Assignment-4/OT-Deployment/config/employee-config.yaml
kubectl apply -f employee.yaml
```

Check status and logs:

``` bash
kubectl get pods
kubectl logs empms-employee
```

**Observed result:** The Employee Pod was `1/1 Running`. Its logs
confirmed that the application was listening on port `8083`.

### 2.4 Validate Salary and Employee Connectivity to Elasticsearch

The following checks were run:

``` bash
kubectl exec empms-employee -- wget -qO- http://empms-es:9200
kubectl exec empms-salary -- wget -qO- http://empms-es:9200
```

Both requests returned `HTTP/1.1 401 Unauthorized`.

**What this proves:** Both Pods can reach Elasticsearch over the
network, and Elasticsearch is responding with an authentication
requirement.

**What this does not prove:** These unauthenticated checks do not verify
that Salary and Employee successfully authenticate or complete
application-level Elasticsearch operations.

------------------------------------------------------------------------

## Step 3: Frontend and Webserver

### 3.1 Run Frontend Pod

Resources: - Frontend Pod: `empms-frontend` - Frontend Service:
`empms-frontend` on port `3000` - Container image:
`ot-microservices-empms-frontend:latest`

Apply and validate:

``` bash
kubectl apply -f frontend.yaml
kubectl get pods
kubectl logs empms-frontend
```

**Observed result:** The Frontend Pod was `1/1 Running`. Its logs
reported that it was accepting connections on port `3000`.

### 3.2 Run Webserver Pod

Resources: - Webserver Pod: `empms-webserver` - Webserver Service:
`empms-webserver` on port `80` - Container image: `nginx:latest`

Apply and validate:

``` bash
kubectl apply -f webserver.yaml
kubectl get pods
kubectl logs empms-webserver
```

Test Nginx from inside the Pod:

``` bash
kubectl exec empms-webserver -- curl -I http://localhost
```

**Observed result:** Nginx returned `HTTP/1.1 200 OK`.

**Validation note:** This confirms that Nginx is responding. The current
Webserver Pod uses the default Nginx configuration; it has not been
configured to serve or proxy the Frontend application. The Frontend and
Webserver Pods were validated separately.

------------------------------------------------------------------------

## Final Status Check

Check all Pods and Services:

``` bash
kubectl get pods
kubectl get services
```

The following seven Pods were observed in the `Running` state:

-   `empms-db`
-   `empms-attendance`
-   `empms-es`
-   `empms-salary`
-   `empms-employee`
-   `empms-frontend`
-   `empms-webserver`

## Cleanup

To remove the Kubernetes resources created for this assignment, run
these commands from the `Assignment-5` directory:

``` bash
kubectl delete -f webserver.yaml
kubectl delete -f frontend.yaml
kubectl delete -f employee.yaml
kubectl delete -f salary.yaml
kubectl delete -f elasticsearch/elasticsearch.yaml
kubectl delete -f attendance/attendance.yaml
kubectl delete -f mysql/mysql.yaml
kubectl delete configmap elasticsearch-config employee-config salary-config
```

If any file or ConfigMap has a different name, adjust the command
accordingly. Check current resources before deleting:

``` bash
kubectl get pods,services,configmaps
```

These commands remove Kubernetes resources; they do not delete the local
Docker images.

## Summary

Assignment 5's seven component Pods were deployed and observed running.
The Elasticsearch API returned a successful authenticated response,
Attendance-to-MySQL TCP connectivity succeeded, and Nginx returned HTTP
200. Salary and Employee could reach Elasticsearch, but their
unauthenticated checks returned `401 Unauthorized`; successful
authenticated application-level operations were not independently
verified. Frontend and Webserver startup were verified separately, but
their integration was not configured or tested.
