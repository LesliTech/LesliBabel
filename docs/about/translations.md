# Translation Workflow

LesliBabel organizes translations using the same hierarchy as engine locale files:

```text
locale → engine module → feature bucket → label → value
```

For example:

```yaml
en:
  lesli_support:
    tickets:
      title: "Support tickets"
```

This becomes the `lesli_support` module, the `tickets` bucket, and the `title` label for English.

The authoritative format is [LesliBabel YAML Schema v1](./yaml-structure.md). It defines file naming, the exact hierarchy, naming rules, optional purpose prefixes, scalar values, missing-value markers, and interpolation requirements. Import and deploy behavior must preserve that contract.

## Source and Managed Data

Engine files are the version-controlled source distributed with each gem. LesliBabel imports those files into its database so authorized users can inspect and edit values centrally.

```shell
bin/rails lesli_babel:scan
bin/rails lesli_babel:import
```

`scan` reads the Lesli route matrix and creates missing modules and controller buckets. It also creates a `shared` bucket for each discovered module. `import` reads the namespace matching each engine's snake-case code, such as `lesli_babel`, and stores its labels for every available locale.

The importer expects labels grouped directly below a bucket:

```yaml
locale:
  engine_code:
    bucket:
      label: "Value"
```

Additional nesting below a bucket is not valid in Schema v1. Existing locale files that use deeper legacy trees must be migrated before they can be managed by the strict importer.

## Import Service

`LesliBabel::TranslationImportService` exposes one public entry point for importing a translation file:

```ruby
result = LesliBabel::TranslationImportService.call(
  file_path: "/path/to/config/locales/translations.en.yml",
  platform: "lesli_engine"
)

result[:errors] # structural errors found during the import
```

The result is a plain hash containing structural `errors`. A fresh error collection is returned for every call. Database changes are verified through the persisted modules, buckets, labels, and translations instead of import counters.

The service reads `file_path` directly with `YAML.safe_load_file`. YAML parsing and filesystem errors are not intercepted and propagate to the caller.

The only application-level validation checks the required `locale → module → bucket → label → string` hierarchy. Invalid branches are excluded from the import and their complete paths are returned in `errors`; valid sibling branches are still imported. An invalid root produces no database writes. No naming, filename, prefix, placeholder, or ownership validations are performed.

Keep interpolation tokens such as `%{count}` unchanged across locales.

## Dashboard Statistics

`LesliBabel::TranslationService` is read-only and exists only to build dashboard statistics. It does not export or deploy translations. YAML generation belongs to `TranslationExportService`, and every filesystem write belongs to `TranslationDeployService`.

The dashboard contract contains only actionable information:

- `total_labels`: every registered label.
- `locales`: completed, missing, and coverage percentage for each configured locale.
- `summary`: configured locales, pending translations, and global coverage across every translatable locale value.
- `attention`: global counts for `need_translation`, `need_help`, and `need_context`.

See the [dashboard guide](./dashboard.md) for the exact formulas, empty-catalog behavior, locale ordering, the meaning of every workflow state, and the distinction between pending values and attention states.

## Export and Deploy Contract

Export and deploy are separate operations with different responsibilities.

### Export

Export reads the database and builds the YAML document for every installed package and configured locale. It does not create, truncate, or replace files in an engine's `config/locales` directory.

Each exported document contains the information needed by deploy:

```ruby
{
  file_path: "/path/to/config/locales/translations.en.yml",
  content: "---\nen:\n  lesli_babel:\n    labels: {}\n"
}
```

The YAML content must satisfy Schema v1 and use plain string keys. Export has no filesystem side effects, which allows its complete result to be tested and validated before deployment.

`LesliBabel::TranslationExportService` builds one document at a time:

```ruby
result = LesliBabel::TranslationExportService.call(
  engine: LesliSystem.engine("LesliBabel"),
  platform: "lesli_engine",
  locale: :en
)

result[:file_path] # expected config/locales destination
result[:content]   # serialized YAML with string keys
```

The service looks up exactly one module by the engine `code` and requested `platform`, orders buckets and labels by code, and generates placeholders for blank values. Editorial status does not affect export.

### Deploy

Deploy consumes the documents produced by export and writes each `content` value to its official `file_path`. It does not query labels or rebuild YAML independently. All documents must be generated successfully before deploy starts replacing source files.

Filesystem and serialization failures propagate to the caller. A failed export must produce no source-file changes.

`LesliBabel::TranslationDeployService` discovers installed packages and configured locales, generates every export before touching the filesystem, verifies all destinations, stages temporary files beside their targets, and replaces each destination with an atomic rename:

```ruby
result = LesliBabel::TranslationDeployService.call

result[:files]  # official locale files replaced successfully
result[:errors] # module or locale errors that prevented every write
```

The host application is mapped to `main_app` on `rails_app`, Lesli core to `lesli` on `lesli_core`, and other engines to their catalog code on `lesli_engine`. Filesystem errors are not converted into result errors; they propagate to the caller.

### Locales

The only locales managed by export and deploy are the keys configured in:

```ruby
Lesli.config.babel[:locales]
```

Locale keys are normalized to strings for filenames and YAML roots. `I18n.available_locales` is not used because it can include locales registered by unrelated dependencies.

### Package and Module Ownership

Every generated file contains exactly one owning module:

| Package | Platform | Owning module |
| --- | --- | --- |
| Host application | `rails_app` | Application module such as `main_app` |
| Lesli core | `lesli_core` | `lesli` |
| Lesli engine | `lesli_engine` | Engine code such as `lesli_babel` |

Labels from another module are never copied into the file. This keeps ownership portable and prevents the same translation from being maintained in multiple packages.

### Missing Values

A blank database value is exported using its complete path as a placeholder:

```yaml
message_not_found: ":lesli_babel.labels.message_not_found:"
```

The placeholder exists only in the exported document and is never assigned back to the Active Record label. Existing values are serialized without trimming or transformation, including interpolation tokens such as `%{count}`.

Every label remains exportable regardless of its editorial status. Coverage is calculated separately from status by inspecting the configured locale values directly.

### Shared and Application Buckets

`shared` and `application` are bucket names, not global namespaces. Their owner is determined by their parent module.

- `lesli.shared` and `lesli.application` belong exclusively to Lesli core and are exported only to Lesli core files.
- They are not copied into every engine file because Rails loads the Lesli core locale files alongside installed engines.
- An engine may own its own bucket with the same name, such as `lesli_support.shared`; that bucket is exported only with the owning engine.

## Deploy Operations and Security

The Babel interface and the `lesli_babel:deploy` Rake task can write database values back to each installed engine's `config/locales/translations.<locale>.yml` files. The intended target is a writable, version-controlled source checkout. Do not deploy into immutable installed gems or containers.

Web deploy is authenticated and authorized through the standard Lesli controller stack. It is disabled in production by default. Enable it only for trusted operators and a writable checkout:

```ruby
Lesli.config.babel[:allow_web_deploy] = true
```

When the key is omitted, web deploy is enabled outside production and disabled in production. Explicit `true` or `false` values override that default in every environment. The [dashboard guide](./dashboard.md#allow_web_deploy-configuration) documents the complete configuration matrix and web request flow.

The Rake task is not controlled by `allow_web_deploy`; it is an administrative command for a trusted shell or release workflow. Both entry points expose the real filesystem error when a write fails, so deploy access must not be public.

Every destination is generated and staged before replacement, and each individual rename is atomic. A multi-file deploy is not a single filesystem transaction: if a later rename fails, files renamed earlier remain updated. Keep the checkout recoverable and review the result:

1. Commit or stash unrelated work.
2. Run `bin/rails lesli_babel:export` first when a read-only preview is needed.
3. Deploy the translations from the web interface or trusted Rake command.
4. Review every generated file.
5. Run affected interface tests.
6. Commit the locale changes in their owning engine repositories.

Never treat the production database as the only copy of a translation. Released gems load their versioned locale files.

LesliBabel's own interface labels belong under `lesli_babel`, following the same convention.
