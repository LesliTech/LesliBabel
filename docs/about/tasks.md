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

The task discovers each installed engine's `config/locales/translations.*.yml` files and imports them through `LesliBabel::TranslationImportService`. It creates missing records and completes only locale columns that are empty in the database.

Invalid branches are reported with Termline while valid translations continue importing. After all files have been processed, the task exits with an error when any entries were rejected. YAML parser, filesystem, and database errors still stop the task immediately.

To test a single file and platform during development:

```shell
bin/rails "lesli_babel:import[/absolute/path/translations.en.yml,lesli_engine]"
```

| Property | Value |
| --- | --- |
| Environment | Writable database with installed engines loaded |
| Reads | `config/locales/translations.<locale>.yml` directly |
| Writes | Modules, buckets, labels, and locale values |
| Repeatability | Preserves existing translations and creates or completes missing values |

The standard `bin/rails lesli:db:prepare` task runs `scan` followed by `import` automatically when LesliBabel is installed.

## Unsupported Task Stubs

The repository currently exposes `lesli_babel:clean` and `lesli_babel:export`, but they are not supported operational commands: `clean` still references the retired `CloudBabel` namespace and `export` does not write output. Do not use them in installation, deployment, or release automation until their implementations are completed and tested.
