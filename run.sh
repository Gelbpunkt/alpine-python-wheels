#!/usr/bin/env bash
rm -rf wheels
rm index
podman build -t wheels:latest .
podman run -d --rm --name wheels wheels:latest
podman cp --pause=false wheels:/wheels/ .
ls wheels >> index
