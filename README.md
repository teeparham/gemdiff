# gemdiff

[![Gem Version](https://badge.fury.io/rb/gemdiff.svg)](http://rubygems.org/gems/gemdiff)
[![CI](https://github.com/teeparham/gemdiff/actions/workflows/test.yml/badge.svg)](https://github.com/teeparham/gemdiff/actions/workflows/test.yml)

`gemdiff` is a command-line tool to find source code for ruby gems.
It connects gem version management (rubygems + bundler) with source code (GitHub).

`gemdiff` provides commands to
* Find GitHub repositories for gems
* Open the compare view for two gem versions
* Inspect your bundle and list all the available updates
* Simplify your `git` workflow for updating gems

### Why?

You want to view differences between versions of gems before updating.
`gemdiff` does the source repository lookup, opens a compare view of commits on GitHub,
and simplifies your git workflow for a bundled project.

### How does it work?

`gemdiff` finds a repository by inspecting the local or remote gemspec, or searching GitHub if needed.
It uses bundler to list your outdated gems. For each outdated gem, it determines your currently used version and
the version you can update to, and builds a compare view URL with the old and new version tags.

Run `gemdiff update [gem]` to update a gem (`bundle update [gem]`) and commit the change with a nice
commit message that includes the old and new versions and a compare URL with the changes.

## Install

```sh
gem install gemdiff
```

## Commands

### `gemdiff [list]`

Runs `bundle outdated --strict` in the current directory.
Outputs outdated gems in your bundle with their compare URLs to stdout.
`list` is the default command.

```sh
$ cd /your/ruby/project/using/bundler
$ gemdiff
Checking for outdated gems in your bundle...
Fetching gem metadata from https://rubygems.org/.......
Fetching version metadata from https://rubygems.org/..
Resolving dependencies...

Outdated gems included in the bundle:
  * mocha (newest 1.2.1, installed 1.1.0, requested ~> 1.0) in group "development"
  * rake (newest 11.3.0, installed 11.1.2, requested ~> 11.0) in group "development"
  * sqlite3 (newest 1.3.12, installed 1.3.11, requested ~> 1.3) in group "development"

mocha: 1.2.1 > 1.1.0
https://github.com/freerange/mocha/compare/v1.1.0...v1.2.1

rake: 11.3.0 > 11.1.2
https://github.com/ruby/rake/compare/v11.1.2...v11.3.0

sqlite3: 1.3.12 > 1.3.11
https://github.com/sparklemotion/sqlite3-ruby/compare/v1.3.11...v1.3.12
```

### `gemdiff each`

Runs `bundle outdated --strict` in the current directory. For each outdated gem,
you can open the compare view for that gem, skip it, or exit.
Enter `y` to review. Enter `A` to open all compare views (beware!).
Enter `s` to list all the compare URLs to stdout (same as the `list` command).

```sh
$ gemdiff each
Checking for outdated gems in your bundle...
Fetching gem metadata from https://rubygems.org/.......
Fetching version metadata from https://rubygems.org/..
Resolving dependencies...

Outdated gems included in the bundle:
  * aws-sdk (1.35.0 > 1.34.1)
  * sprockets (2.11.0 > 2.10.1)
  * webmock (1.17.4 > 1.17.3)
aws-sdk: 1.35.0 > 1.34.1
Open? (y to open, x to exit, A to open all, s to show all to stdout, else skip)
sprockets: 2.11.0 > 2.10.1
Open? (y to open, x to exit, A to open all, s to show all to stdout, else skip) y
webmock: 1.17.4 > 1.17.3
Open? (y to open, x to exit, A to open all, s to show all to stdout, else skip)
```

### `gemdiff update [gem]`

Update a gem in your bundle and commit the change with git.
A compare URL showing the difference between the versions will be part of the commit message.
You will be shown a preview of the `git diff` and you may choose to commit or reset the change.

```sh
$ gemdiff update nokogiri

Updating nokogiri...
diff --git a/Gemfile.lock b/Gemfile.lock
index b074472..e0554f2 100644
--- a/Gemfile.lock
+++ b/Gemfile.lock
@@ -102,7 +102,7 @@ GEM
     mini_portile2 (2.1.0)
     minitest (5.10.1)
     nio4r (2.0.0)
-    nokogiri (1.7.1)
+    nokogiri (1.7.2)
       mini_portile2 (~> 2.1.0)
     orm_adapter (0.5.0)
     parser (2.4.0.0)

Commit? (c to commit, r to reset, else do nothing) c

commit 1131db6f57ccad8ed3dab6759c6b1306f98a165c
Author: Tee Parham
Date:   Fri May 12 14:04:26 2017 -0600

    Update nokogiri to 1.7.2

    https://github.com/sparklemotion/nokogiri/compare/v1.7.1...v1.7.2

diff --git a/Gemfile.lock b/Gemfile.lock
...
```

### `gemdiff find [gem]`

Show the repository URL using the gemspec. If a GitHub URL is not found, query the GitHub search API.

```sh
$ gemdiff find pundit
https://github.com/varvet/pundit
```

### `gemdiff open [gem]`

Open the repository URL with your default browser (or whatever your operating system is configured
to run with the `open` command with a URL argument):

```sh
$ gemdiff open pundit
```

You may also use `.` as a shortcut for the current directory name.
This is helpful if you would like to quickly open the gem you are developing, for example:

```sh
$ pwd
/Users/you/projects/somegem
$ gemdiff open .
```

### `gemdiff compare [gem] [version] [version]`

Open a compare view for an individual outdated gem in your bundle:

```sh
$ gemdiff compare pundit
```

You can bypass bundler and query a gem by including the old and new version numbers. This is faster since it bypasses
the `bundle outdated --strict` command used to get the versions.

For example, open the GitHub compare view in browser for difference between `pundit` versions 0.3.0 and 1.0.0:

```sh
$ gemdiff compare pundit 1.0.0 0.3.0
```

You can compare a version with a branch name:

```sh
$ gemdiff compare arel 6.0.0 main
```

### `gemdiff releases [gem]`

Open the repository's release history page:

```sh
$ gemdiff releases haml
```

### `gemdiff main [gem]`

Open the repository's main branch commit history page:

```sh
$ gemdiff main haml
```

### `gemdiff help`

To get help on the command line:

```sh
$ gemdiff help
```

### Shortcuts

You can use abbreviations for any of the above commands. For example, this is equivalent to `gemdiff find pundit`:

```sh
$ gemdiff f pundit
https://github.com/varvet/pundit
```

All commands that have a gem name argument can now use "." as an alias for the current directory name.

For example:

```sh
pwd
/Users/you/ruby/somegem
gemdiff find .
gemdiff open .
gemdiff main .
gemdiff compare . 1.2.3 main
```

### Authenticated GitHub API requests

If GitHub returns rate limit errors, you can make authenticated API
requests to GitHub. Set the `GEMDIFF_GITHUB_TOKEN` or `GITHUB_TOKEN`
environment variable to a
[personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).
Using `GEMDIFF_GITHUB_TOKEN` is recommended, since other programs such as
`hub` use `GITHUB_TOKEN`.

### What if it didn't work?

`gemdiff` assumes a few things:

1. The gem must have a repository on GitHub. If not, `gemdiff` will find nothing or a similar repository, which
is not helpful. Some gems' source code is not on GitHub. `gemdiff` could support other source hosts. Submit a pull request!

2. The GitHub repository must have tagged releases to show compare views. If you find gems that do not tag
releases, submit an issue to the gem maintainer to tag their releases.

3. The versions must be tagged using the standard format of `v1.2.3`. If you find gems that follow
a non-standard format (such as `1.2.3`), please open an issue or submit a pull request.
See [`lib/gemdiff/outdated_gem.rb`](https://github.com/teeparham/gemdiff/blob/main/lib/gemdiff/outdated_gem.rb).

4. Encourage gem maintainers to enter the GitHub repository URL in the `homepage` field of their gemspec
or anywhere in the description. If you find exceptions, open an issue or submit a pull request.
See [`lib/gemdiff/repo_finder.rb`](https://github.com/teeparham/gemdiff/blob/main/lib/gemdiff/repo_finder.rb).

### More Info

[Slides from lightning talk at Boulder Ruby 4/15/2014](http://www.slideshare.net/teeparham/gemdiff)
