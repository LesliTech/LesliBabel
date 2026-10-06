# Tasks

Run LesliBabel tasks through the host Rails application.

## Scan Installed Routes

```shell
bin/rails lesli_babel:scan
```

The task reads the Lesli route matrix and creates missing translation modules and buckets. It is safe to rerun: existing records are found instead of duplicated.

| Property | Value |
| --- | --- |
| Environment | Development, test, or controlled application setup |
| Reads | Installed engine routes and resource metadata |
| Writes | LesliBabel modules and buckets |
| Repeatability | Idempotent for the same module and bucket codes |

## Import Locale Files

```shell
bin/rails lesli_babel:import
```

The task reads each installed engine's namespace from the active I18n locales, creates missing labels, and updates locale values in the Babel database.

| Property | Value |
| --- | --- |
| Environment | Writable database with installed engines loaded |
| Reads | `config/locales/translations.<locale>.yml` through I18n |
| Writes | Modules, buckets, labels, and locale values |
| Repeatability | Updates existing labels and creates missing labels |

The standard `bin/rails lesli:db:prepare` task runs `scan` followed by `import` automatically when LesliBabel is installed.

## Unsupported Task Stubs

The repository currently exposes `lesli_babel:clean` and `lesli_babel:export`, but they are not supported operational commands: `clean` still references the retired `CloudBabel` namespace and `export` does not write output. Do not use them in installation, deployment, or release automation until their implementations are completed and tested.
