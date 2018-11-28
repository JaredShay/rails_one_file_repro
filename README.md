# One file repro templates for Rails.

Couple of templates that can be used to repro or debug active record issues.
You'll need to install any gems first as this isn't using bundler, and this may
not work across all rails versions. The general idea will work though, you may
just have to figure out what needs changing between versions.

In addition to helping debug issues this is useful for submitting issues as you
can have repro steps contained in a single file. Often this is nicer than
submitting a stack trace with version numbers as it gives maintainers something
they can run.

Running the file with `--debug` will set the active record logger to STDOUT and
also attempt to output a relevant calling line.
