#!/bin/bash
set -euxo pipefail

pushd python_legacy

# Check packaging constraint.
python -c 'import setuptools; where="./iceberg"; assert setuptools.find_packages(where) == setuptools.find_namespace_packages(where), "you seem to be missing or have extra __init__.py files"'
if [[ ${RELEASE_VERSION:-} ]]; then
    # Replace version with RELEASE_VERSION env variable
    sed -i.bak "s/__version__ = \"0.0.0.dev0\"/__version__ = \"$RELEASE_VERSION\"/" ./iceberg/__init__.py
else
    vim ./iceberg/__init__.py
fi

rm -rf build dist || true
python -m build
if [[ ! ${RELEASE_SKIP_UPLOAD:-} ]]; then
    python -m twine upload 'dist/*'
fi
git restore ./iceberg/__init__.py

popd
