# gemdiff

`gemdiff` is a command-line utility to find and compare source code repositories
associated with ruby gems. It makes it easy to compare source code differences
between the current version of a gem in your bundle and the latest version of the gem.

## Install

```sh
gem install gemdiff
```

## Find

```sh
$ gemdiff find arel
http://github.com/rails/arel

```

## Open
```sh
$ gemdiff open arel

# opens arel project url in browser

```

## Compare
```sh
$ gemdiff compare arel --new=5.0.0 --old=4.0.2

# opens GitHub compare view in browser for difference between versions 4.0.2 and 5.0.0

```

## Outdated

The holy grail:

```sh
$ cd /your/ruby/project/using/bundler
$ gemdiff

```
