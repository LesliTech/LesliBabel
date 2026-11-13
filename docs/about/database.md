# Database

LesliBabel uses collection code `09` and engine code `01`. It stores translation structure in three tables:

| Migration code | Table | Responsibility | Important relationships |
| --- | --- | --- | --- |
| `09.01.10.01.10` | `lesli_babel_modules` | Installed engine or application namespaces | Parent of buckets |
| `09.01.11.01.10` | `lesli_babel_buckets` | Controller or feature groups inside a module | Belongs to a module |
| `09.01.12.01.10` | `lesli_babel_labels` | Translation keys, locale values, and translation state | Belongs to a bucket |

Modules, buckets, and labels use regular database deletion. Labels contain a column for each supported locale and metadata used to track translation state and references. The YAML files and version control provide the recovery path for translation content, so the database does not retain deleted records.

Labels can be permanently deleted from the translation editor after explicit confirmation. Modules and buckets are not deleted from the interface, and their foreign keys prevent removing a parent that still owns translations.

The portable references are stored alongside the foreign keys:

- `buckets.reference_module` identifies the owning module.
- `labels.reference_bucket` identifies the module and bucket used to build the translation path.

These references are required and remain stable because translation keys are immutable after creation.

The ownership hierarchy is:

```text
lesli_babel_modules
└── lesli_babel_buckets
    └── lesli_babel_labels
```

Changing the configured locale set can require both application configuration and schema support. Verify the label columns before enabling a new managed locale.

Module, bucket, and label identities are protected by unique indexes over their complete paths. Foreign keys prevent deleting modules or buckets that still own translations. Translation values and context use database `text` columns so they are not limited to varchar-sized content.

Prepare and inspect the schema through the host application:

```shell
bin/rails lesli:db:prepare
bin/rails db:migrate:status
```

See [Database Architecture](/engines/lesli/database/structure) and [Migration Versioning](/engines/lesli/database/versioning) for shared conventions.
