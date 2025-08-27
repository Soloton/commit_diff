# commit_diff — CLI tool for generating commit messages

English version README: [EN](./README.md), [RU](./README-ru.md)

A convenient CLI tool that generates a commit message template based on Git changes (or the last commit), using customizable templates. It supports automatic substitution of `{diff}`, `{branch}`, and `{locale}`.

---

## Table of Contents

* [Features](#features)
* [Installation](#installation)
* [Usage](#usage)
* [Placeholders](#placeholders)
* [Examples](#examples)
* [Notes](#notes)
* [License](#license)

---

## Features

* Inserts a short description of changes from `git diff --cached` or the last commit.
* Supports placeholders `{diff}`, `{branch}`, `{locale}` in `*.tpl` templates.
* Automatically selects a template if only one is present.
* Provides detailed errors when multiple templates exist.
* Supports localization (`en` → English, `ru` → Russian).
* Outputs the result to `stdout` (can be redirected or copied).

---

## Installation

Install via `curl` or `wget`:

```sh
curl -fsSL https://raw.githubusercontent.com/Soloton/commit_diff/master/install.sh | bash
```

or

```sh
wget -qO- https://raw.githubusercontent.com/Soloton/commit_diff/master/install.sh | bash
```

After installation:

* The script is available as `commit_diff` (verify with `commit_diff --help`).
* Templates are stored in `/usr/local/share/commit_diff/`. You can add your own `*.tpl` files there.

If `commit_diff` is not found, make sure `/usr/local/bin` is included in your `$PATH`. Usually this is already configured, but if needed, add:

```sh
export PATH="$PATH:/usr/local/bin"
```

to your `~/.bashrc` or `~/.zshrc`.

---

## Usage

```sh
commit_diff [OPTIONS]
```

**Options:**

* `-t`, `--template NAME` — use the specified template `NAME.tpl`.
* `-l`, `--locale LOCALE` — set locale (`en` or `ru`). If not mapped, the value is used as is.
* `-L`, `--list` — list available templates.
* `-a`, `--last-commit` — use the last commit diff instead of staged changes.
* `-h`, `--help` — show help.

If no template is specified and only one `*.tpl` is present, it will be selected automatically.

---

## Placeholders

* `{diff}` — replaced with the output of staged `git diff --cached` (or last commit diff if `-a` is used).
* `{branch}` — replaced with the current Git branch name.
* `{locale}` — replaced with the string corresponding to the locale (`en` → English, `ru` → Russian).

---

## Examples

1. Example of using your own template

1. Prepare your template `my_template.tpl` and place it in `/usr/local/share/commit_diff/`.
2. Inside your project, run:

```sh
git add <files>
commit_diff -t my_template -l ru
```

or:

```sh
commit_diff -t my_template -l ru -a
```

3. Copy the result and paste it into the commit message or PR description.

2. Example of using a template if there is only one template in the shared directory

1. Inside your project, run:

```sh
git add <files>
commit_diff | xclip -sel clip
```

or:

```sh
commit_diff -a | xclip -sel clip
```

2. Copy the result and paste it into your commit message or PR description.

---

## Notes

* Must be run inside a Git repository.
* Template files `*.tpl` are stored in `/usr/local/share/commit_diff/`.
* If multiple templates exist, specify one using `-t`.

---

## License

MIT

Contributions and feedback are welcome!
