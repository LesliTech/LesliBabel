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

Keep interpolation tokens such as `%{count}` unchanged across locales. Values wrapped as unresolved template markers, for example `:lesli_support.tickets.title:`, are not imported as completed translations.

## Deploy Changes

The Babel interface can deploy database values back to each installed engine's `config/locales/translations.<locale>.yml` files. Deployment rewrites those files, so use it only in a writable development checkout:

1. Commit or stash unrelated work.
2. Deploy the selected translations.
3. Review every generated file.
4. Run affected interface tests.
5. Commit the locale changes in their owning engine repositories.

Never treat the production database as the only copy of a translation. Released gems load their versioned locale files.

LesliBabel's own interface labels belong under `lesli_babel`, following the same convention.
