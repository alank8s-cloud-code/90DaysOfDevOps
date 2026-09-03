# Day 45 – Docker Build & Push in GitHub Actions

## Task

Build a **complete CI/CD pipeline** using GitHub Actions that automatically builds a Docker image and pushes it to Docker Hub whenever code is pushed to the `main` branch.

---

## Task 1: Prepare

### What

Prepare your project for Docker image building in GitHub Actions.

### Why

GitHub Actions needs a Dockerfile to build the application into a Docker image. Docker Hub credentials are also required to push the image.

### Steps

1. Use the application Dockerized on Day 36 or any simple Dockerfile.
2. Add the `Dockerfile` to the `github-actions-practice` repository.
3. Make sure these GitHub Secrets are configured:

   * `DOCKER_USERNAME`
   * `DOCKER_TOKEN`

---

## Task 2: Build the Docker Image in CI

### What

Create:

```text
.github/workflows/docker-publish.yml
```

The workflow should:

1. Trigger when code is pushed to `main`.
2. Check out the repository code.
3. Build the Docker image.
4. Tag the Docker image.

### Why

This removes the need to manually build Docker images on your local machine. Every push to GitHub can automatically create a new Docker image.

### Verify

Check the GitHub Actions build logs and confirm that the Docker image builds successfully.

---

## Task 3: Push to Docker Hub

### What

Configure GitHub Actions to:

1. Log in to Docker Hub using GitHub Secrets.
2. Tag the image as:

```text
username/repo:latest
```

3. Tag the image using the commit hash:

```text
username/repo:sha-<short-commit-hash>
```

4. Push both tags to Docker Hub.

### Why

Docker Hub stores the built image so it can be pulled and run from another machine, server, or cloud environment.

### Verify

Open your Docker Hub repository and confirm that both `latest` and `sha-<short-commit-hash>` tags are available.

---

## Task 4: Only Push on Main

### What

Configure the workflow so the Docker image is pushed to Docker Hub **only when the workflow runs on the `main` branch**.

The image can be built on other branches, but it should not be pushed.

### Why

This prevents unfinished feature-branch code from being published as a Docker image.

### Verify

Push code to a feature branch and confirm:

* Docker image builds successfully.
* Docker image is **not** pushed to Docker Hub.

---

## Task 5: Add a Status Badge

### What

Add the status badge for the `docker-publish` GitHub Actions workflow to `README.md`.

### Why

The badge shows the current CI/CD workflow status directly in the repository README.

### Verify

Push the changes and confirm that the workflow badge appears **green** when the workflow succeeds.

---

## Task 6: Pull and Run the Docker Image

### What

Pull the Docker image from Docker Hub and run it on your local machine or a cloud server.

### Why

Building and pushing the image is only part of the CI/CD process. The final goal is to make the application available as a running container.

### Steps

1. Pull the image from Docker Hub.
2. Run the image as a container.
3. Confirm that the application works.

### Notes

The complete journey is:

```text
git push
    ↓
GitHub Actions
    ↓
Checkout Code
    ↓
Docker Build
    ↓
Docker Image
    ↓
Docker Hub Login
    ↓
Tag Image
    ↓
Push Image
    ↓
Pull Image
    ↓
Run Container
```
## What I Learned Today

* Learned how to create a **complete Docker CI/CD pipeline** using GitHub Actions.
* Learned how GitHub Actions can automatically **build Docker images** after a `git push`.
* Learned how to **authenticate GitHub Actions with Docker Hub** using GitHub Secrets.
* Learned how to use `DOCKER_USERNAME` and `DOCKER_TOKEN` securely.
* Learned how to **tag Docker images** with `latest` and commit SHA tags.
* Learned how to **push Docker images automatically to Docker Hub**.
* Learned how to restrict Docker image publishing to the **`main` branch**.
* Learned how to add a **GitHub Actions status badge** to a README.
* Learned the complete CI/CD flow from **`git push` → GitHub Actions → Docker Build → Docker Hub → Running Container**.
* Learned how to **pull and run a Docker image** published by GitHub Actions.
