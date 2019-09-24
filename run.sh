#!/usr/bin/env bash
rm -rf wheels
podman build -t wheels:latest .
podman run -d --rm --name wheels wheels:latest
podman cp wheels:/wheels/ .
ls wheels >> index
