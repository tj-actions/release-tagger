[![CI](https://github.com/tj-actions/release-tagger/workflows/CI/badge.svg)](https://github.com/tj-actions/release-tagger/actions?query=workflow%3ACI)
[![Update release version.](https://github.com/tj-actions/release-tagger/workflows/Update%20release%20version./badge.svg)](https://github.com/tj-actions/release-tagger/actions?query=workflow%3A%22Update+release+version.%22)
[![Public workflows that use this action.](https://img.shields.io/endpoint?url=https%3A%2F%2Fused-by.vercel.app%2Fapi%2Fgithub-actions%2Fused-by%3Faction%3Dtj-actions%2Frelease-tagger%26badge%3Dtrue)](https://github.com/search?o=desc\&q=tj-actions+release-tagger+path%3A.github%2Fworkflows+language%3AYAML\&s=\&type=Code)

## release-tagger

Automatically manage [Github action](https://docs.github.com/en/actions/creating-actions) releases by ensuring that a major release is always created or updated to point to the last minor/patch release.

![Screen Shot 2022-09-20 at 11 13 54 PM](https://user-images.githubusercontent.com/17484350/191419709-d13f6d43-91af-4209-95de-9a88d4e70d86.png)

## Usage

> NOTE: :warning:
>
> *   **IMPORTANT:** Any single major version release decription would be overwritten by this action (i.e `v2`). In order to preserve the single major version release description you'll need to create a semantic version. (i.e `v2.0.0`)

```yaml
name: Tag release

on:
  push:
    tags:
      - v*

jobs:
  test:
    runs-on: ubuntu-latest
    name: Create or update major release tag
    steps:
      - uses: actions/checkout@v3
      - name: Run release-tagger
        uses: tj-actions/release-tagger@v3
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|       INPUT        |  TYPE  | REQUIRED |         DEFAULT         |                                                                                                                                                  DESCRIPTION                                                                                                                                                   |
|--------------------|--------|----------|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| release\_notes\_file | string |   true   |  `"RELEASE_NOTES.md"`   |                                                                                                                                         File to write release notes to                                                                                                                                         |
|       token        | string |   true   | `"${{ github.token }}"` | [GITHUB\_TOKEN](https://docs.github.com/en/free-pro-team@latest/actions/reference/authentication-in-a-workflow#using-the-github_token-in-a-workflow) or a repo scoped [PersonalAccess Token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) |

<!-- AUTO-DOC-INPUT:END -->

*   Free software: [MIT license](LICENSE)

If you feel generous and want to show some extra appreciation:

[![Buy me a coffee][buymeacoffee-shield]][buymeacoffee]

[buymeacoffee]: https://www.buymeacoffee.com/jackton1

[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png

## Credits

This package was created with [Cookiecutter](https://github.com/cookiecutter/cookiecutter) using [cookiecutter-action](https://github.com/tj-actions/cookiecutter-action)

## Report Bugs

Report bugs at https://github.com/tj-actions/release-tagger/issues.

If you are reporting a bug, please include:

*   Your operating system name and version.
*   Any details about your workflow that might be helpful in troubleshooting.
*   Detailed steps to reproduce the bug.
