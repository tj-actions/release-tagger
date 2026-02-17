#!/usr/bin/env bash

set -euo pipefail

if [[ $GITHUB_REF != "refs/tags/"* ]]; then
  echo "::error::This should only run on tags push or on release.";
  exit 1;
fi

GITHUB_HOST=${GITHUB_SERVER_URL#https://}
REMOTE_URL=https://$INPUTS_TOKEN@$GITHUB_HOST/$GITHUB_REPOSITORY

echo "Remote URL: $REMOTE_URL"

git fetch "$REMOTE_URL" +refs/tags/*:refs/tags/*

NEW_TAG=${GITHUB_REF/refs\/tags\//}
MAJOR_VERSION=$(echo "$NEW_TAG" | cut -d. -f1)
RELEASE_ASSETS_DIR=$(mktemp -d)

for tag in $(git tag -l --sort=-version:refname "$MAJOR_VERSION.*" | grep -E '^v[0-9]+\.[0-9]+(\.[0-9]+)?$'); do
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
    if [[ "$INPUTS_RETAG_MAJOR" == "true" ]]; then
      # Update the release notes
      gh release edit "$MAJOR_VERSION" --notes-file "$INPUTS_RELEASE_NOTES_FILE" --title "$MAJOR_VERSION"
  
      # if the RELEASE_ASSETS_DIR is not empty, upload the assets
      if [[ -n "$(find "$RELEASE_ASSETS_DIR" -type f)" ]]; then
        gh release upload --clobber "$MAJOR_VERSION" "$RELEASE_ASSETS_DIR"/*
      fi
      # Re-tag the major version using the latest tag
      git tag -f "$MAJOR_VERSION" "$NEW_TAG"
      git push -f "$REMOTE_URL" "$MAJOR_VERSION"
    else
      echo "No changes required."
    fi
  else
    if [[ -n "$(find "$RELEASE_ASSETS_DIR" -type f)" ]]; then
      gh release create "$MAJOR_VERSION" --notes-file "$INPUTS_RELEASE_NOTES_FILE" --title "$MAJOR_VERSION" "$RELEASE_ASSETS_DIR"/*
    else
      gh release create "$MAJOR_VERSION" --notes-file "$INPUTS_RELEASE_NOTES_FILE" --title "$MAJOR_VERSION"
    fi
  fi
fi


cat <<EOF >> "$GITHUB_OUTPUT"
major_version=$MAJOR_VERSION
new_version=$NEW_TAG
EOF

rm -f "$INPUTS_RELEASE_NOTES_FILE" || true
rm -rf "$RELEASE_ASSETS_DIR" || true
