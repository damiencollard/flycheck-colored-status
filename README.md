# Flycheck colored status

This minor mode replaces the default Flycheck mode line status indicators with more colorful and (to me at least) more noticeable indicators for the error, warning and info levels. It mimicks the indicators I saw somewhere...

![Screenshot](screenshot.png?raw=true "Flycheck colored status")

## Installation

Copy `flycheck-colored-status.el` into a directory that appears in your Emacs' `load-path`.

## Usage

Simply add the following line to your emacs configuration:
```lisp
(require 'flycheck-colored-status)
```

## Customization

The symbol used (a dot by default) and the colors can be customized:

```plain
M-x customize-group
flycheck-colored-status
```

## Limitations

**Bug**: Currently the Flycheck menu isn't displayed when the colored dots are clicked.
