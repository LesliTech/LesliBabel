# Tasks

Run LesliBabel tasks through the host Rails application.

## Scan Installed Routes

```shell
bin/rails lesli_babel:scan
```

The task reads the Lesli route matrix and creates missing translation modules and buckets. It is safe to rerun: existing records are found instead of duplicated.

The `rails_app` resource namespace is registered as the `main_app` module on the `rails_app` platform. Lesli core is registered as `lesli` on `lesli_core`; every other engine uses `lesli_engine`.

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

The task discovers each installed engine's `config/locales/translations.*.yml` files and imports them through `LesliBabel::TranslationImportService`. The host application uses the `rails_app` platform, Lesli core uses `lesli_core`, and all other engines use `lesli_engine`. It creates missing records and completes only locale columns that are empty in the database.

Invalid branches are reported with Termline while valid translations continue importing. After all files have been processed, the task exits with an error when any entries were rejected. YAML parser, filesystem, and database errors still stop the task immediately.

| Property | Value |
| --- | --- |
| Environment | Writable database with installed engines loaded |
| Reads | `config/locales/translations.<locale>.yml` directly |
| Writes | Modules, buckets, labels, and locale values |
| Repeatability | Preserves existing translations and creates or completes missing values |

Termline reports each processed engine and translation file. Structural errors are printed below the affected file and cause the task to finish with an error after all importable files have been processed.

The standard `bin/rails lesli:db:prepare` task runs `scan` followed by `import` automatically when LesliBabel is installed.

## Export Locale Files

Export translations to a temporary directory:

```shell
bin/rails lesli_babel:export
```

Or provide an explicit output directory:

```shell
bin/rails "lesli_babel:export[/path/to/output]"
```

The task generates every document through `LesliBabel::TranslationExportService` before writing. Exported files are grouped by engine code inside the output directory, and Termline reports the engine and filename. Official files inside installed engines are never modified.

## Deploy Locale Files

```shell
bin/rails lesli_babel:deploy
```

The task invokes `LesliBabel::TranslationDeployService` to replace the official locale files safely. Termline reports the engine and filename for every updated file without printing counters or aggregate statistics.

All documents are generated and staged before deployment. Generation errors make the task fail without writing files, while filesystem errors propagate immediately. Repeated deploys from unchanged database translations produce identical YAML content.

Deploy is also available from the LesliBabel web interface. Web deploy is enabled outside production by default and can be controlled explicitly with:

```ruby
Lesli.config.babel[:allow_web_deploy] = true
```

The setting restricts only the web endpoint. The Rake task remains available for controlled deployment and release workflows.

## Unsupported Task Stubs

The repository currently exposes `lesli_babel:clean`, but it is not a supported operational command because it still references the retired `CloudBabel` namespace. Do not use it in installation, deployment, or release automation until its implementation is replaced and tested.
