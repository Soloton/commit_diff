# commit\_diff

> Translations: [EN](./README.md), [RU](./README-ru.md)

A handy CLI tool to generate a commit message template based on your staged git changes (or the last commit), using customizable templates.
Supports automatic placeholder replacement for diff, branch, and locale in the output.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Placeholders](#placeholders)
- [Example Workflow](#example-workflow)
- [Notes](#notes)
- [License](#license)

---

## Features

* Insert a summary of your staged git diff or last commit into a template
* Use placeholders (`{diff}`, `{branch}`, `{locale}`) in `.tpl` template files
* Automatically selects template if only one is present
* Helpful error messages if multiple templates are present
* Locale substitution (e.g. `en` → English, `ru` → Russian)
* Outputs formatted result to stdout (can be piped or copied)

---

## Installation

Can be installed using `curl` or `wget`:

```sh
curl -fsSL https://raw.githubusercontent.com/Soloton/commit_diff/master/install.sh | bash
```

or

```sh
wget -qO- https://raw.githubusercontent.com/Soloton/commit_diff/master/install.sh | bash
```

After installation:

- The script is available as `commit_diff` (you can check it with the command `commit_diff --help`).

- The templates are located in the `/usr/local/share/commit_diff/` directory.
You can add your `*.tpl` files there.

If the commit_diff command is not available after installation, make sure that the `/usr/local/bin` directory is in the `PATH` environment variable.
To do this, add the line to `~/.bashrc` or `~/.zshrc`:

``` sh
export PATH=$PATH:/usr/local/bin
```

---

## Usage

```sh
commit_diff [OPTIONS]
```

**Options:**

* `-t`, `--template NAME`
  Use the specified template file (`*.tpl`) from the script directory.
* `-l`, `--locale LOCALE`
  Set the locale (e.g. `en` or `ru`). If not found in map, uses the value as is.
* `-L`, `--list`
  List all available template files.
* `-a`, `--last-commit`
  Use the last commit changes instead of staged changes for `{diff}`.
* `-h`, `--help`
  Show the help message.

If a template is not specified and there is exactly one `.tpl` in the directory, it will be used automatically.

---

## Placeholders

* `{diff}` — replaced by the output of `git diff --cached` (or last commit if `-a` is used)
* `{branch}` — replaced by the current git branch name
* `{locale}` — replaced by the mapped locale string (e.g. `en` → English)

---

## Example Workflow

1. **Prepare a template file**
   Place your `my_template.tpl` in the same directory as `commit_diff.sh`.
   Example template:

   ```
   feat({branch}): commit for {locale}

   - Summary of changes:
   {diff}
   ```

2. **Use in your git project**

   ```sh
   git add <files>
   commit_diff -t my_template -l en
   ```

   or, to use the last commit diff:
00
3. 
   ```sh
   commit_diff -t my_template -l en -a
   ```

3. **Copy or pipe the output as needed for your commit message or PR description.**

---

## Notes

* You must run `commit_diff` from within a git repository.
* Template files must have the `.tpl` extension and reside in the same directory as `commit_diff.sh`.
* If there are multiple templates, specify one using `-t`.

---

## License

MIT

---

*Feel free to suggest improvements or open issues!*
