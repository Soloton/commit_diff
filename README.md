# commit\_diff

A handy CLI tool to generate a commit message template based on your staged git changes (or the last commit), using customizable templates.
Supports automatic placeholder replacement for diff, branch, and locale in the output.

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

1. Clone or copy this repository to any location, e.g. `~/code/commit_diff`.
2. Make the script executable:

   ```sh
   chmod +x ~/code/commit_diff/commit_diff.sh
   ```
3. Create a symlink to `/usr/local/bin` for easy access:

   ```sh
   sudo ln -s <full-path>/commit_diff.sh /usr/local/bin/commit_diff
   ```

   Replace `<full-path>` with the absolute path to your `commit_diff.sh`.

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
