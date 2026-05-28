Since you're new, think of this in a very practical way.

Your terminal (Bash/Zsh) loads a configuration file every time you open a new terminal window.
That file is used to:

* create shortcuts (aliases)
* create variables
* customize terminal behavior
* store reusable commands

On Mac:

* Older Macs mostly use **Bash** → `~/.bash_profile`
* Newer Macs mostly use **Zsh** → `~/.zshrc`

You can check yours:

```bash id="7f7m1z"
echo $SHELL
```

If output is:

```bash id="mpg0wf"
/bin/zsh
```

then use `.zshrc`

If output is:

```bash id="a5q0eq"
/bin/bash
```

then use `.bash_profile`

---

# PART 1 — Understanding Alias

An alias is simply a shortcut command.

Example:

Normally:

```bash id="opb5b9"
kubectl get pods
```

This is long.

So we create:

```bash id="p0zywq"
alias kgp='kubectl get pods'
```

Now you only type:

```bash id="pjh70f"
kgp
```

and terminal automatically runs:

```bash id="xq4b9u"
kubectl get pods
```

---

# PART 2 — Open Your Profile File

Since most Macs use Zsh now:

```bash id="qf3w3d"
nano ~/.zshrc
```

(If Bash → use `~/.bash_profile`)

---

# PART 3 — Add Kubernetes Aliases

Go to bottom and add:

```bash id="cr2z34"
# Kubernetes Aliases

alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
```

Here:

| Alias | Real Command     |
| ----- | ---------------- |
| k     | kubectl          |
| kgp   | kubectl get pods |
| kgs   | kubectl get svc  |
| kaf   | kubectl apply -f |

---

# PART 4 — Save File

In nano editor:

### Save

Press:

```text
CTRL + O
```

Then press:

```text
ENTER
```

### Exit

Press:

```text
CTRL + X
```

---

# PART 5 — Reload Configuration

Very important.

Terminal already loaded old settings.
Reload new settings using:

```bash id="lk4kxn"
source ~/.zshrc
```

(Bash users use `source ~/.bash_profile`)

---

# PART 6 — Test Alias

Now try:

```bash id="knq5qo"
k get nodes
```

or

```bash id="e4dg1r"
kgp
```

---

# PART 7 — Understanding Environment Variables

Environment variables store reusable values.

Think of them like containers storing information.

Example:

```bash id="8h7b9v"
export NAME="Munmun"
```

Now terminal remembers:

```bash id="4j9gqv"
echo $NAME
```

Output:

```text
Munmun
```

---

# PART 8 — Kubernetes Environment Variables

Very useful example:

## KUBECONFIG Variable

Kubernetes stores cluster config in a file.

Default:

```bash id="m2g58l"
~/.kube/config
```

You can create variable:

```bash id="r1m9za"
export KUBECONFIG=~/.kube/config
```

Now Kubernetes commands use that config automatically.

---

# PART 9 — Add Environment Variable Permanently

Open again:

```bash id="hf7c4y"
nano ~/.zshrc
```

Add:

```bash id="y4m2vx"
# Kubernetes Environment Variable

export KUBECONFIG=~/.kube/config
```

Save and reload:

```bash id="8x5yjp"
source ~/.zshrc
```

Check:

```bash id="m6r2nh"
echo $KUBECONFIG
```

---

# PART 10 — Real Beginner Understanding

Think of terminal startup like this:

```text
Open Terminal
      ↓
Reads ~/.zshrc
      ↓
Loads aliases
Loads variables
Loads custom settings
      ↓
Your shortcuts work
```

---

# PART 11 — Common Kubernetes Aliases

You’ll use these daily:

```bash id="j5t8qk"
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kl='kubectl logs'
alias kctx='kubectl config current-context'
```

Example:

```bash id="fd7b2k"
kgn
```

instead of:

```bash id="h6n4bp"
kubectl get nodes
```

That’s why DevOps/Kubernetes engineers heavily use aliases.
