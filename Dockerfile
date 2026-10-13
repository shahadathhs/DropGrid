# Extends the upstream CI image with runtime libraries Godot expects.
# barichello/godot-ci is a bare Ubuntu image and lacks fontconfig, which
# Godot loads at startup (missing it prints an error on every run).
ARG GODOT_VERSION=4.7.2
FROM barichello/godot-ci:${GODOT_VERSION}

RUN apt-get update \
	&& apt-get install -y --no-install-recommends libfontconfig1 \
	&& rm -rf /var/lib/apt/lists/*

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["godot", "--version"]
