#!/usr/bin/env bash

set -e

if [[ $GITHUB_REF != "refs/tags/"* ]]; then
  echo "::warning::Skipping: This should only run on tags push or on release.";
  exit 0;
fi

git fetch origin +refs/tags/*:refs/tags/*

NEW_TAG=${GITHUB_REF/refs\/tags\//}
MAJOR_VERSION=$(echo "$NEW_TAG" | cut -d. -f1)

# Re-tag the major version using the latest tag
git tag -f "$MAJOR_VERSION" "$NEW_TAG"
git push -f "$INPUTS_REMOTE" "$MAJOR_VERSION"

echo "::set-output name=major_version::$MAJOR_VERSION"
echo "::set-output name=new_version::$NEW_TAG"
