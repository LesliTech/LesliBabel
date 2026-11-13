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

## Deploy Changes

The Babel interface can deploy database values back to each installed engine's `config/locales/translations.<locale>.yml` files. Deployment rewrites those files, so use it only in a writable development checkout:

1. Commit or stash unrelated work.
2. Deploy the selected translations.
3. Review every generated file.
4. Run affected interface tests.
5. Commit the locale changes in their owning engine repositories.

Never treat the production database as the only copy of a translation. Released gems load their versioned locale files.

LesliBabel's own interface labels belong under `lesli_babel`, following the same convention.
