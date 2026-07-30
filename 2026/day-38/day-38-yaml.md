# Day 38 - YAML Basics

## Objective

- Understand YAML syntax and rules
- Write YAML files by hand
- Validate YAML files using `yamllint`

---

# What is YAML?

**YAML** stands for **YAML Ain't Markup Language**.

It is a **human-readable data serialization language** used to store configuration files and exchange data between applications.

Unlike programming languages, YAML is **not used to write logic or algorithms**. Instead, it stores information in a structured format.

Example:

```yaml
name: Alan
role: DevOps Engineer
learning: true
```

---

# Why do we use YAML?

YAML is widely used because it is:

- Easy for humans to read and write
- Uses simple indentation instead of brackets or tags
- Supported by many DevOps tools
- Easy for applications to parse

### Popular DevOps tools that use YAML

- Kubernetes
- Docker Compose
- GitHub Actions
- Ansible
- Azure DevOps Pipelines
- GitLab CI/CD

---

# YAML Rules

- Use **spaces**, never **tabs**
- Write data using `key: value`
- Keep indentation consistent
- Use `-` for lists
- Use `:` to separate keys and values

---

# Task 1: Key-Value Pairs

## Objective

Create a `person.yaml` file describing yourself.

### person.yaml

```yaml
# My personal information

---

name: alan
role: DevOps
experience_years: fresher
learning: true

```

### Verification

```bash
cat person.yaml
```

Verify:

- No tabs
- Proper indentation
- Correct key-value syntax

---

# Task 2: Lists

## Objective

Add:

- tools (Block Style List)
- hobbies (Flow Style / Inline List)

### Block Style List

```yaml
tools:
  - Linux
  - Networking
  - GitandGithub
  - Docker
  - CI/CD(githubactions)
```

### Flow Style (Inline List)

```yaml
hobbies: [cricket, cooking]
```

### Two ways to write Lists in YAML

### 1. Block Style List

```yaml
tools:
  - Docker
  - Kubernetes
  - Git
```

### 2. Flow Style (Inline List)

```yaml
tools: [Docker, Kubernetes, Git]
```

---

# Task 3: Nested Objects

## Objective

Create a `server.yaml` using nested objects.

### server.yaml

```yaml
---

server:
  name: linux_server
  ip: 192.1.1.0
  port:
    - 80

database:
  host: mysql
  name: mysql_data
  credential:
    user: suraj
    password: suraj@123
```

### Verification

Replace spaces with a **Tab** and validate.

```bash
yamllint server.yaml
```

Example error:

```
found character '\t' that cannot start any token
```

This happens because YAML only allows **spaces** for indentation.

---

# Task 4: Multi-line Strings

## Objective

Use both YAML block styles.

### Literal Style (`|`)

```yaml
startup_script1: |
  echo "Hi everyone"
  echo "Hostname $HOSTNAME"
  echo "OS Version: $(cat /etc/os-release)"
```

### Folded Style (`>`)

```yaml
startup_script2: >
  This yaml file tells
  server information,
  database details,
  and startup requirements.
```

### When to use `|`

Use when line breaks must be preserved.

Examples:

- Bash scripts
- Python scripts
- SQL queries
- Certificates
- Configuration files

### When to use `>`

Use when writing:

- Documentation
- Paragraphs
- Long descriptions
- Notes

---

# Task 5: Validate Your YAML

## Install yamllint

Ubuntu/Debian

```bash
sudo apt update
sudo apt install yamllint
```

Verify installation

```bash
yamllint --version
```

Validate files

```bash
yamllint person.yaml
yamllint server.yaml
```

Validate all YAML files

```bash
yamllint .
```

### Example Errors

Missing space after colon

```yaml
name:alan
```

Output

```
syntax error
```

Trailing spaces

```
error trailing spaces
```

Wrong indentation

```
mapping values are not allowed here
```

Fix the errors and run `yamllint` again until no errors remain.

---

# Task 6: Spot the Difference

## Block 1 (Correct)

```yaml
name: devops
tools:
  - docker
  - kubernetes
```

## Block 2 (Broken)

```yaml
name: devops
tools:
- docker
  - kubernetes
```

### What is wrong?

The second list item is indented differently from the first.

YAML expects all items in the same list to start at the same indentation level.

Correct version:

```yaml
name: devops
tools:
  - docker
  - kubernetes
```

---

# Commands Used

Display YAML file

```bash
cat person.yaml
cat server.yaml
```

Validate YAML

```bash
yamllint person.yaml
yamllint server.yaml
```

Validate all YAML files

```bash
yamllint .
```

Check line numbers

```bash
cat -n server.yaml
```

Display only a specific line

```bash
sed -n '7p' server.yaml
```

---

# What I Learned

- What YAML is and why it is used
- How to write key-value pairs
- Difference between Block Style and Flow Style lists
- How nested objects work
- Difference between `|` and `>`
- How to validate YAML using `yamllint`
- Common YAML errors and how to fix them
- Importance of spaces and indentation in YAML

---

# Conclusion

Today I learned the fundamentals of YAML, including key-value pairs, lists, nested objects, multi-line strings, and validation using `yamllint`. YAML is one of the most important configuration languages in DevOps because tools like Kubernetes, Docker Compose, Ansible, and GitHub Actions rely heavily on it. Mastering these basics will make it much easier to work with modern DevOps tools and CI/CD pipelines.
