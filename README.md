# gemdiff

`gemdiff` is a command-line utility to find and compare source code repositories
associated with ruby gems. It makes it easy to compare source code differences
between the current version of a gem in your bundle and the latest version of the gem.

## Why?

1. Looking up the github repository for a gem often requires The Google.
2. Many gems do not have the source repository URL in the gemspec.
3. You should Always Be Updating. This makes it easier.

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

You don't need to use bundler or be in a project. You can query a specific gem by
entering explicit version numbers.

For example, open the GitHub compare view in browser for difference between versions 4.0.2 and 5.0.0:

```sh
$ gemdiff compare arel --new=5.0.0 --old=4.0.2
```

### `find`

Lookup the repository URL using the gemspec. If a GitHub URL is not found, hit the GitHub search API.

```sh
$ gemdiff find arel
http://github.com/rails/arel
```

### `open`

Open the repository URL:

```sh
$ gemdiff open arel
```

### `releases`

Open the repository's release history page:

```sh
$ gemdiff releases arel
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
