# Day 38 – YAML Basics

## Task Overview

Before writing CI/CD pipelines, it is important to understand **YAML** because most DevOps tools use it for configuration.

This day focused on:

* Understanding YAML syntax and rules
* Writing YAML files by hand
* Validating YAML
* Learning common mistakes and best practices

---

## YAML Files Created

### 1. person.yaml

```yaml id="person-yaml"
name: DevOps Learner
role: DevOps Engineer
experience_years: 1
learning: true

tools:
  - Docker
  - Kubernetes
  - Git
  - Jenkins
  - Linux

hobbies: [reading, learning, scripting]
```

**Notes:**

* Key-value pairs: `key: value`
* Lists can be written in two ways:

  * **Block style:** using `-`
  * **Inline style:** using `[item1, item2]`

---

### 2. server.yaml

```yaml id="server-yaml"
server:
  name: nginx-server
  ip: 192.168.1.10
  port: 80

database:
  host: localhost
  name: app_db
  credentials:
    user: admin
    password: secret123

startup_script_literal: |
  #!/bin/bash
  echo "check the server is running or not"
  sudo systemctl status nginx
  echo "if server is not running then run it"
  sudo systemctl start nginx
  echo "nginx server is running"

startup_script_folded: >
  #!/bin/bash
  echo "check the server is running"
  sudo systemctl status nginx
  echo "if server is not running"
  sudo systemctl start nginx
  echo "nginx server is running"
```

**Notes:**

* `|` preserves newlines → best for scripts and configs
* `>` folds multiple lines into a single line → not good for scripts

**Debug hidden issues (tabs, trailing spaces, line endings):**

```bash id="hidden-chars"
sed -n '25,40l' server.yml
```

* Trailing spaces → `$`
* Tabs → `\t`
* Line endings

---

## Task 6 – Spot the Difference

### Block 1 (Correct)

```yaml id="block1"
name: devops
tools:
  - docker
  - kubernetes
```

**Why it is correct:**

* `tools` is a list → use `-`
* Both list items have same indentation
* Structure is clear and valid

---

### Block 2 (Broken)

```yaml id="block2"
name: devops
tools:
- docker
  - kubernetes
```

**What is wrong:**

* List items do not have same indentation
* YAML uses indentation for structure
* Causes parsing/validation error

---

## What I Learned (3 Key Points)

1. **Indentation is everything in YAML**

   * Same indentation → siblings
   * More indentation → child
   * Tabs must never be used

2. **Use correct symbols:**

   * `:` → single values or objects
   * `-` → lists
   * `|` → scripts and configs
   * `>` → long text, not scripts

3. **Read YAML like English:**

   * Hyphen `-` = one item
   * Indentation shows ownership
   * Clear structure prevents errors

---

**Result:**
After Day 38, I can write **valid YAML**, understand **lists, objects, scripts**, and debug hidden errors like tabs or trailing spaces.
