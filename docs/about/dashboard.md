# Translation Dashboard

The LesliBabel dashboard summarizes the state of the database catalog and provides direct access to translations that require work. Its statistics are built by the read-only `LesliBabel::TranslationService`; opening the dashboard never modifies translations or YAML files.

## Catalog Metrics

| Metric | Meaning |
| --- | --- |
| Total labels | Every label registered in the catalog, including disabled labels. |
| Configured locales | Number of locale keys in `Lesli.config.babel[:locales]`. |
| Pending translations | Sum of blank values across all configured locales and non-disabled labels. Both `NULL` and an empty string are pending. |
| Global coverage | Completed values divided by all completed and pending values across configured locales, rounded to the nearest whole percentage. |

When there are no configured locales or no translatable labels, pending translations and coverage are both `0`.

Each locale card uses the same non-disabled label set and shows:

- `Translated`: labels whose value for that locale is neither `NULL` nor an empty string.
- `Pending`: non-disabled labels without a value for that locale.
- `Coverage`: `translated / (translated + pending)`, rounded to the nearest whole percentage.

Locale cards are ordered from the lowest coverage to the highest coverage so the languages requiring attention appear first. Selecting a card opens the labels list filtered to missing translations for that locale. The pending-translations action in the header opens labels missing a value in any configured locale.

## Label Workflow States

Workflow states describe why a label requires attention. They are independent from the calculated pending count: a blank locale value does not automatically change the label status, and setting a status does not make a translation complete.

| Status | Meaning | Export behavior |
| --- | --- | --- |
| No status | The label has not been assigned a workflow state. | Included. |
| `ok` | The label is ready and does not require workflow attention. | Included. |
| `need_translation` | One or more values still require translation or review. | Included; blank values become full-path placeholders. |
| `need_help` | The translator needs linguistic or technical assistance. | Included. |
| `need_context` | The label needs product or interface context before it can be translated confidently. | Included. |
| `disabled` | The label is intentionally inactive and must not be released. | Excluded from export and coverage calculations. |

The dashboard attention cards count labels marked `need_translation`, `need_help`, and `need_context`. These are label counts, not missing-value counts, so they can differ from pending translations.

## Web Deploy Flow

Web deploy replaces the official `config/locales/translations.<locale>.yml` files with documents generated from the database. It should be used only by trusted operators in a writable, version-controlled source checkout.

1. The dashboard and labels index show an enabled Deploy button only when web deploy is allowed.
2. The user must confirm that the official YAML files will be replaced.
3. Turbo disables the submit button and changes its text to `Deploying...` while the request is running, preventing duplicate submissions.
4. The authenticated and authorized controller invokes `LesliBabel::TranslationDeployService`.
5. The service generates every YAML document before writing, verifies the destinations, and stages temporary files beside their targets.
6. Each destination is replaced with an atomic rename.
7. The interface reports success only after every replacement completes. Generation and filesystem failures display their real error message instead of a success notification.

Generation errors prevent all writes. Each individual file replacement is atomic, but the complete multi-file deploy is not a single filesystem transaction: if a later rename fails, files replaced earlier remain updated. Review the resulting version-control diff after every deploy.

The `lesli_babel:deploy` Rake task uses the same deploy service, but it is not controlled by the web setting described below.

## `allow_web_deploy` Configuration

Configure the web endpoint through the host application, normally in an initializer:

```ruby
# config/initializers/lesli_babel.rb
Lesli.config.babel[:allow_web_deploy] = false
```

| Configuration | Development and test | Production |
| --- | --- | --- |
| Key omitted | Enabled | Disabled |
| `true` | Enabled | Enabled |
| `false` | Disabled | Disabled |

The environment-dependent default is equivalent to:

```ruby
Lesli.config.babel.fetch(:allow_web_deploy, !Rails.env.production?)
```

When disabled, the interface displays a non-interactive `Web deploy disabled` control and the endpoint returns a forbidden response without invoking the deploy service. The setting affects only web requests; trusted shell and release workflows can still run:

```shell
bin/rails lesli_babel:deploy
```

Keep the setting explicitly `false` in production unless the application has trusted operators, standard Lesli authentication and authorization, and writable version-controlled locale files.
