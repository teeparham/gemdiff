# gemdiff

[![Gem Version](http://img.shields.io/gem/v/gemdiff.svg)](http://rubygems.org/gems/gemdiff)
[![Build Status](http://img.shields.io/travis/teeparham/gemdiff.svg)](https://travis-ci.org/teeparham/gemdiff)

`gemdiff` is a command-line utility to find and compare source code repositories
associated with ruby gems. It makes it easy to compare source code differences
between the current version of a gem in your bundle and the latest version of the gem.
`gemdiff` helps connect gem version management (rubygems + bundler) with source code (github).

#### Why?

You want to view the source code differences between versions of gems when your dependencies are updated. 
`gemdiff` hides the complexity of the source repository lookup, provides commands to open common github
pages, and provides efficient workflow commands that work with a bundled project (see `outdated`, `update`).

#### How?

`gemdiff` finds a repository by inspecting the local (or remote) gemspec, then searching github if needed. 
It uses bundler to list your outdated gems. For each outdated gem, it determines your currently used version and 
the version you can update to, and builds a compare view URL with the old and new version tags. 
It also provides `update` for a simple `bundle update <gem>` and commit workflow.

## Install

```sh
gem install gemdiff
```

## Commands

### `outdated`

Runs `bundle outdated --strict` in the current directory.
For each outdated gem, it prompts you if you would like to open the compare view for that gem. 
Enter `y` to review.

`outdated` is the default task, so `gemdiff` with no arguments is the same as `gemdiff outdated`.

```sh
$ cd /your/ruby/project/using/bundler
$ gemdiff
Checking for outdated gems in your bundle...
Fetching gem metadata from https://rubygems.org/.......
Fetching additional metadata from https://rubygems.org/..
Resolving dependencies...

Outdated gems included in the bundle:
  * aws-sdk (1.35.0 > 1.34.1)
  * sprockets (2.11.0 > 2.10.1)
  * webmock (1.17.4 > 1.17.3)
aws-sdk: 1.35.0 > 1.34.1
Open? (y to open, else skip)
sprockets: 2.11.0 > 2.10.1
Open? (y to open, else skip) y
webmock: 1.17.4 > 1.17.3
Open? (y to open, else skip)
```

### `compare`

Open a compare view for an individual outdated gem in your bundle:

```sh
$ gemdiff compare haml
```

You can bypass bundler and query a gem by including the old and new version numbers. This is faster since
the `bundle` command to check the versions is skipped.

For example, open the GitHub compare view in browser for difference between `haml` versions 4.0.4 and 4.0.5:

```sh
$ gemdiff compare haml 4.0.4 4.0.5
```

You can compare a version with a branch name:

```sh
$ gemdiff compare arel 4.0.2 master
```

### `find`

Lookup the repository URL using the gemspec. If a GitHub URL is not found, query the GitHub search API.

```sh
$ gemdiff find haml
http://github.com/haml/haml
```

### `open`

Open the repository URL:

```sh
$ gemdiff open haml
```

### `releases`

Open the repository's release history page:

```sh
$ gemdiff releases haml
```

### `commits`

Open the repository's master branch commit history page:

```sh
$ gemdiff commits haml
```

### `update`

`gemdiff` can simplify your git workflow around updating gems. Use `update` to update a gem in your
bundle and commit the change to your repository. You will be shown a preview of the `git diff` and
you may choose to commit or reset the change.

```sh
$ gemdiff update haml

Updating haml...
diff --git a/Gemfile.lock b/Gemfile.lock
index d5544ef..2d5def8 100644
--- a/Gemfile.lock
+++ b/Gemfile.lock
@@ -38,7 +38,7 @@ GEM
     dalli (2.7.0)
     debugger-linecache (1.2.0)
     erubis (2.7.0)
-    haml (4.0.4)
+    haml (4.0.5)
       tilt
     hike (1.2.3)
     i18n (0.6.9)

Commit? (c to commit, r to reset, else do nothing) c

commit ebcc13f4c9a43f2e844d9d185e527652021c6a8f
Author: Tee Parham
Date:   Mon Mar 3 16:38:32 2014 -0700

    Update haml to 4.0.5

diff --git a/Gemfile.lock
```

### `help`

You can use abbreviations for any of the above commands. For example, this is equivalent to `gemdiff find haml`:

```sh
$ gemdiff f haml
http://github.com/haml/haml
```

To get help on the command line:

```sh
$ gemdiff help
```

### It didn't work

`gemdiff` operates on a few assumptions:

1. The gem must have a repository on GitHub. If not, `gemdiff` will find nothing or a similar repository, which
is not helpful.

2. The GitHub repository must have tagged releases to show compare views.

3. The versions must be tagged using the standard name format of v1.2.3. If you find gems that follow
a non-standard format (such as 1.2.3), please open an issue or submit a pull request. 
See [`lib/gemdiff/outdated_gem.rb`](https://github.com/teeparham/gemdiff/blob/master/lib/gemdiff/outdated_gem.rb).

4. Encourage gem maintainers to either enter the GitHub repository URL in the `homepage` field of their gemspec,
or anywhere in the description. `gemdiff` is much faster if so, and if not, it guesses the best match using
the GitHub search API. If you find exceptions, open an issue or submit a pull request.
See [`lib/gemdiff/repo_finder.rb`](https://github.com/teeparham/gemdiff/blob/master/lib/gemdiff/repo_finder.rb).

5. Some gems' source code is not on GitHub (gasp!). `gemdiff` could support other source hosts. Submit a pull request!
