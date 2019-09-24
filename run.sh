#!/usr/bin/env bash
podman build -t wheels:latest .
podman run -d --rm --name wheels wheels:latest
podman cp wheels:/wheels/ .
