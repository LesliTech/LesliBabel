# Frontend

LesliBabel renders inside Lesli's authenticated application shell. Its pages use LesliView for shared containers, headers, toolbars, tables, buttons, and form builders. Tailwind CSS provides the engine-specific layout and presentation.

## Tailwind Stylesheet

The editable entrypoint and generated Rails asset are separate:

```text
source/tailwind/application.tailwind.css
        ↓ build
app/assets/stylesheets/lesli_babel/application.tailwind.css
```

Edit the file under `source/tailwind`; never edit the compiled asset by hand. Commit the generated asset whenever an entrypoint or scanned template changes.

The entrypoint imports Tailwind with automatic source detection disabled:

```css
@import "tailwindcss/utilities.css" layer(utilities) source(none);
```

Every view or helper containing Tailwind classes must therefore have an explicit `@source` rule. The current sources cover:

- The translation dashboard.
- The labels index and form.
- The module sidebar.

Add another `@source` rule when migrating or creating a template. Tailwind cannot discover interpolated fragments such as `"text-#{status}-600"`; use mappings containing complete class names instead.

## Shared Components

Prefer LesliView components instead of recreating shared interface elements:

| Interface element | Component |
| --- | --- |
| Page wrapper | `LesliView::Layout::Container` |
| Title and actions | `LesliView::Components::Header` |
| Search and filters | `LesliView::Components::Toolbar` |
| Data listing | `LesliView::Elements::Table` |
| Actions | `LesliView::Elements::Button` |
| Label forms | `LesliView::Forms::BuilderHorizontal` |

The shared form builder already supplies Tailwind styling for fieldsets, labels, inputs, selects, validation states, and submit buttons. Templates should only add utilities for page-specific layout or elements not produced by the builder.

The labels index uses Alpine.js for copy-to-clipboard feedback. Keep the action as `type="button"`, retain a visible focus state, and update its accessible label when the copy succeeds.

## Avoid Utility Collisions

The application loads stylesheets in this order:

1. `lesli_assets/application.tailwind`
2. `lesli_assets/view.tailwind`
3. `lesli_babel/application.tailwind`

Tailwind utility selectors have equal specificity. A base utility emitted by the Babel bundle can therefore override a responsive utility from a shared LesliView component because the engine stylesheet loads last.

Avoid redundant base utilities when the browser's layout already provides the desired default. For example, this grid is one column by default and does not need `grid-cols-1`:

```erb
<div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
```

Adding `grid-cols-1` here would emit a global `.grid-cols-1` rule in the Babel bundle. That rule can override the responsive grid used by the shared Header component and push its actions onto a second row.

After adding a common layout utility, inspect shared components at their responsive breakpoints and check the browser's computed styles when behavior differs only in Babel.

## Build and Verify

From a complete Lesli development workspace, run the shared builder:

```shell
cd gems/LesliAssets
make build.tailwind
```

Use the watcher while editing templates or Tailwind sources:

```shell
make watch.tailwind
```

The builder discovers LesliBabel's entrypoint and writes the compiled output to `app/assets/stylesheets/lesli_babel/application.tailwind.css`.

Before committing a frontend change:

1. Build the Tailwind assets.
2. Confirm that the generated Babel stylesheet changed.
3. Test the dashboard and labels pages at mobile and desktop widths.
4. Verify header titles and actions remain aligned at desktop widths.
5. Run `git diff --check` from the LesliBabel repository.

## View Conventions

- Use responsive, mobile-first utilities.
- Keep data loading and shaping in services or controllers.
- Use semantic HTML and valid list structure in sidebar partials.
- Mark decorative icons with `aria-hidden="true"`.
- Give icon-only controls an accessible label.
- Preserve `focus-visible` styles for interactive elements.
- Treat files under `app/assets/stylesheets` with `.tailwind.css` names as generated output.

See [Views and Layouts](/engines/lesli/frontend/views), [Styles with Tailwind CSS](/engines/lesli/frontend/styles), and the [LesliView documentation](/gems/view/) for shared conventions and component APIs.
