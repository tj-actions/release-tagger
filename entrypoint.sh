#!/usr/bin/env bash

set -euo pipefail

if [[ $GITHUB_REF != "refs/tags/"* ]]; then
  echo "::warning::Skipping: This should only run on tags push or on release.";
  exit 0;
fi

git fetch "$INPUTS_REMOTE" +refs/tags/*:refs/tags/*

NEW_TAG=${GITHUB_REF/refs\/tags\//}
MAJOR_VERSION=$(echo "$NEW_TAG" | cut -d. -f1)
RELEASE_ASSETS_DIR=$(mktemp -d)

for tag in $(git tag -l --sort=-version:refname "$MAJOR_VERSION.*"); do
  echo "Adding $tag to release notes"
  {
    echo "# Changes in $tag"
    gh release view "$tag" --json body --jq '.body'
    printf "\n---\n\n"
  } >> "$INPUTS_RELEASE_NOTES_FILE"

done

# Download the release asset
gh release download "$NEW_TAG" --dir "$RELEASE_ASSETS_DIR" || true

if [[ -f "$INPUTS_RELEASE_NOTES_FILE" ]]; then
  if gh release view "$MAJOR_VERSION" > /dev/null 2>&1; then
    # Update the release notes
    gh release edit "$MAJOR_VERSION" --notes-file "$INPUTS_RELEASE_NOTES_FILE" --title "$MAJOR_VERSION"

    # if the RELEASE_ASSETS_DIR is not empty, upload the assets
    if [[ -n "$(find "$RELEASE_ASSETS_DIR" -type f)" ]]; then
      gh release upload --clobber "$MAJOR_VERSION" "$RELEASE_ASSETS_DIR"/*
    fi

    # Re-tag the major version using the latest tag
    git tag -f "$MAJOR_VERSION" "$NEW_TAG"
    git push -f "$INPUTS_REMOTE" "$MAJOR_VERSION"
  else
    if ls "$RELEASE_ASSETS_DIR"/*; then
      gh release create "$MAJOR_VERSION" --notes-file "$INPUTS_RELEASE_NOTES_FILE" --title "$MAJOR_VERSION" "$RELEASE_ASSETS_DIR"/*
    else
      gh release create "$MAJOR_VERSION" --notes-file "$INPUTS_RELEASE_NOTES_FILE" --title "$MAJOR_VERSION"
    fi
  fi
fi

if [[ -z "$GITHUB_OUTPUT" ]]; then
  echo "::set-output name=major_version::$MAJOR_VERSION"
  echo "::set-output name=new_version::$NEW_TAG"
else
  cat <<EOF >> "$GITHUB_OUTPUT"
major_version=$MAJOR_VERSION
new_version=$NEW_TAG
EOF
fi

rm -f "$INPUTS_RELEASE_NOTES_FILE" || true
rm -rf "$RELEASE_ASSETS_DIR" || true
