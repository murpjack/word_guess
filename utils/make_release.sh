#!/bin/bash


echo "Retrieving latest tag."
git fetch -a
tag_name=$(git describe --tags)

latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
echo "latest tag = $latest_tag"

echo "Retrieving possible release for tag $tag_name."
if [ $(gh release view "$tag_name") ]; then
  echo "No release created."

else
  echo "No release currently exists for tag $tag_name. Attempting to create..."

  # TODO: Add a pre-commit hook to enforce tagging of commits
  # TODO: Add a pre-commit hook to enforce a changelog
  gh release create $tag_name --title "$tag_name" $@
fi
