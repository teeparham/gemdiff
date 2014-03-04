# gemdiff

`gemdiff` is a command-line utility to find and compare source code repositories
associated with ruby gems. It makes it easy to compare source code differences
between the current version of a gem in your bundle and the latest version of the gem.

## Why?

1. Looking up the github repository for a gem often requires The Google.
2. Many gems do not have the source repository URL in the gemspec.
3. You should Always Be Updating. This makes it easier to understand what changed.

## Install

```sh
gem install gemdiff
```

## Commands

### `outdated`

Runs `bundle outdated --strict` on the project in the current directory.
For each outdated gem, it prompts you if you would like to open the compare view
for that gem. Enter 'y' to review or enter to skip.

This is the default task so you can just run `gemdiff`.

```sh
$ cd /your/ruby/project/using/bundler
$ gemdiff
Checking for outdated gems in your bundle...
aws-sdk: 1.35.0 > 1.34.1
Open? (y to open, else skip)
webmock: 1.17.4 > 1.17.3
Open? (y to open, else skip) y
sprockets: 2.11.0 > 2.10.1
Open? (y to open, else skip)
```

### `compare`

You can use `gemdiff` bypassing bundler and query a gem by entering explicit version numbers.

For example, open the GitHub compare view in browser for difference between `haml` versions 4.0.4 and 4.0.5:

```sh
$ gemdiff compare haml --new=4.0.5 --old=4.0.4
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

### `find`

Lookup the repository URL using the gemspec. If a GitHub URL is not found, hit the GitHub search API.

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

### `help`

```sh
$ gemdiff help
```

## It didn't work

`gemdiff` operates on a few assumptions:

1. The gem must have a repository on GitHub. If not, `gemdiff` will find nothing or a similar repository, which
is not helpful.

2. The GitHub repository must have tagged releases to show compare views.

3. The versions must be tagged using the standard name format of v1.2.3. If you find exceptions that follow
a non-standard pattern, please submit a pull request. See `lib/gemdiff/outdated_gem.rb`.

4. Encourage gem maintainers to either enter the GitHub repository URL in the `homepage` field of their gemspec,
or anywhere in the description. `gemdiff` is much faster if so, and if not, it guesses the best match using
the GitHub search API.
