# Official YAML Structure

LesliBabel YAML Schema v1 defines the only translation structure managed by the engine. Its purpose is to keep translation keys predictable and portable across Lesli applications and engines.

## Canonical Structure

Every translation file follows exactly this hierarchy:

```text
locale → module → bucket → label → value
```

```yaml
---
en:
  lesli_babel:
    labels:
      navigation_translations: "Translations"
      button_create: "Create label"
      message_empty: "No labels were found"
```

Each level maps directly to LesliBabel's database:

| YAML level | Database representation | Example |
| --- | --- | --- |
| Locale | Locale column in `lesli_babel_labels` | `en` |
| Module | `lesli_babel_modules.code` | `lesli_babel` |
| Bucket | `lesli_babel_buckets.code` | `labels` |
| Label | `lesli_babel_labels.text` | `button_create` |
| Value | Value stored in the locale column | `Create label` |

The complete translation path is:

```text
lesli_babel.labels.button_create
```

## Translation Files

Translation files belong in the owning package's `config/locales` directory and use the locale in their filename:

```text
config/locales/translations.en.yml
config/locales/translations.es.yml
```

The filename locale and root YAML locale must match:

```yaml
# translations.es.yml
---
es:
  lesli_babel:
    labels:
      button_create: "Crear etiqueta"
```

A file must use:

- UTF-8 encoding.
- One locale root.
- Plain locale keys such as `en`, not Ruby-specific symbol keys such as `:en`.
- The module owned by the package.
- Scalar string translation values.

Third-party namespaces such as Devise do not belong in a managed translation file. Keep them in a separate package file such as `devise.en.yml`; LesliBabel discovers only `translations.<locale>.yml` files.

Rails-native translations follow the same separation. Keep model attribute names
in `activerecord.<locale>.yml`, preserving the hierarchy Rails expects:

```yaml
# activerecord.en.yml — loaded by Rails, not managed by Babel
en:
  activerecord:
    attributes:
      lesli_bell/announcement:
        name: "Name"
```

Do not flatten these Rails keys. For application labels inside managed files,
flatten extra groups into the label name instead: use
`lesli_bell.announcements.categories_info`, not
`lesli_bell.announcements.categories.info`. Update every I18n lookup when
renaming a label, including dynamically interpolated keys.

## Module Codes

The module identifies the application or engine that owns the translation. It must match the registered `LesliBabel::Module#code` exactly.

Examples:

```text
lesli
lesli_babel
lesli_support
main_app
```

Lesli engine module codes use lowercase `snake_case`. A translation file must not create an alternative spelling or alias for an existing module.

## Bucket Codes

A bucket groups labels belonging to the same feature, resource, or shared interface area.

Examples:

```text
application
dashboard
labels
shared
tickets
```

Bucket codes use lowercase `snake_case`. A bucket is unique inside its module and forms the second segment of the translation path.

Bucket names do not change module ownership. In particular, `lesli.shared` and `lesli.application` belong to the `lesli` module and its core package. They must not be copied into other engine files. An engine-specific bucket such as `lesli_support.shared` remains owned by `lesli_support`.

## Label Codes

A label is the immutable final segment of a translation path. It uses lowercase `snake_case` and must not contain spaces, hyphens, or dots.

Valid labels:

```text
title
button_save
column_status
message_not_found
navigation_settings
```

Invalid labels:

```text
ButtonSave
button-save
button.save
button save
```

After a label is created, its module, bucket, and label code do not change. A new semantic meaning requires a new label.

## Optional Purpose Prefixes

Prefixes are optional. When selected, the prefix is joined to the label before it is stored and becomes part of the immutable label code.

```text
prefix: button
label: save
stored label: button_save
```

The official prefixes are defined by `LesliBabel::Label.prefixes`:

| Prefix | Purpose | Example |
| --- | --- | --- |
| `column` | Database or table columns | `column_status` |
| `navigation` | Navigation items | `navigation_settings` |
| `button` | Buttons and actions | `button_save` |
| `chart` | Charts and data visualization | `chart_activity` |
| `tab` | Tab labels | `tab_details` |
| `table` | Table-level interface text | `table_empty` |
| `toolbar` | Toolbar controls | `toolbar_search` |
| `view` | Page and view text | `view_title` |
| `message` | Messages and notifications | `message_not_found` |

Labels without a prefix remain valid when no official prefix describes their purpose. Applications must not invent new prefixes locally; additions belong in `LesliBabel::Label.prefixes` so the vocabulary remains shared.

## Translation Values

A completed translation is a non-empty YAML string:

```yaml
button_save: "Save"
```

Always quote values that contain punctuation, interpolation tokens, YAML keywords, leading or trailing whitespace, or characters such as `:`, `#`, `%`, `{`, and `}`.

The following value types are not part of Schema v1:

- Nested hashes.
- Arrays.
- Numbers.
- Booleans.
- YAML `null` values.
- YAML anchors and aliases.

## Missing Translations

LesliBabel represents an unresolved value with its complete path wrapped in colons:

```yaml
message_not_found: ":lesli_babel.labels.message_not_found:"
```

The marker path must match the module, bucket, and label containing it. A marker is not a completed translation and must not replace an existing translated value during import.

Empty strings are also considered untranslated, but generated files should use the explicit path marker so missing values are visible during development.

## Interpolation Tokens

Rails interpolation tokens are supported inside scalar values:

```yaml
message_welcome: "Welcome, %{name}"
message_results: "%{count} results found"
```

Every locale for the same label must preserve the same named tokens. Translators may change their order but must not translate, add, or remove token names.

```yaml
# Valid
en:
  lesli_babel:
    labels:
      message_welcome: "Welcome, %{name}"

es:
  lesli_babel:
    labels:
      message_welcome: "Bienvenido, %{name}"
```

## Nesting Is Not Allowed Below a Bucket

A bucket contains labels directly. Additional grouping levels are invalid:

```yaml
# Invalid
en:
  lesli_babel:
    labels:
      forms:
        button_save: "Save"
```

The standard representation moves the grouping responsibility to the bucket or label:

```yaml
# Valid: dedicated bucket
en:
  lesli_babel:
    label_forms:
      button_save: "Save"
```

or:

```yaml
# Valid: grouping included in the immutable label
en:
  lesli_babel:
    labels:
      button_form_save: "Save"
```

## Pluralization

Schema v1 stores one scalar value per label and locale. Rails pluralization hashes such as `one` and `other` introduce an additional nesting level and are therefore not part of Schema v1.

When an interface requires two forms under Schema v1, store each form as an explicit label and select the label in application code:

```yaml
message_results_one: "%{count} result"
message_results_other: "%{count} results"
```

Do not add pluralization hashes to managed translation files until LesliBabel defines a controlled pluralization extension. Existing legacy pluralization structures require migration or an explicit future schema version.

## Deterministic Output

Files generated by LesliBabel use stable ordering:

1. Locale.
2. Module code.
3. Bucket code.
4. Label code.

Stable ordering makes generated changes easy to review and prevents unrelated YAML diffs.

## Invalid Structure Examples

Multiple locales in one file:

```yaml
en: {}
es: {}
```

Locale and filename mismatch:

```yaml
# translations.en.yml
es: {}
```

Label outside a bucket:

```yaml
en:
  lesli_babel:
    button_save: "Save"
```

Non-scalar value:

```yaml
en:
  lesli_babel:
    labels:
      navigation_items:
        - "Dashboard"
        - "Translations"
```

## Schema v1 Checklist

A valid managed file satisfies all of the following:

- The filename follows `translations.<locale>.yml`.
- The document contains exactly one locale root.
- The root locale matches the filename.
- The module matches the package's registered module code.
- Module, bucket, and label codes follow the naming convention.
- Labels appear directly below buckets.
- Every completed translation is a scalar string.
- Missing-value markers contain the exact complete translation path.
- Interpolation token names match across locales.
- No duplicate module, bucket, or label keys exist.
- No YAML aliases or arbitrary nested structures are present.

This contract is the foundation for the LesliBabel validator, importer, and deployer. Those components must reject invalid input rather than silently transform it into a different translation path.
