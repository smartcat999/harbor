ARG harbor_base_image_version
ARG harbor_base_namespace

FROM golang:1.21.3 AS builder

ARG registry_version

# Set environment variables
ENV DISTRIBUTION_DIR="/go/src/github.com/docker/distribution"
ENV BUILDTAGS="include_oss include_gcs"
ENV GO111MODULE=auto
ENV REGISTRY_VERSION=${registry_version}

# Set working directory
WORKDIR /go/src/github.com/docker

# Copy required patch file and optional Dockerfile.binary into container
COPY ./make/photon/registry/redis.patch /tmp/redis.patch
COPY ./make/photon/registry/Dockerfile.binary /tmp/Dockerfile.binary

# Build registry binary
RUN git clone -b $REGISTRY_VERSION https://github.com/distribution/distribution.git distribution; \
    cd distribution; \
    # Apply custom redis patch
    git apply /tmp/redis.patch; \
    # Build the registry binary with specific build tags
    CGO_ENABLED=0 make PREFIX=/go clean binaries; \
    echo "Successfully built the registry binary."

FROM ${harbor_base_namespace}/harbor-registry-base:${harbor_base_image_version}

COPY ./make/photon/common/install_cert.sh /home/harbor
COPY ./make/photon/registry/entrypoint.sh /home/harbor
COPY --from=builder /go/src/github.com/docker/distribution/bin/registry /usr/bin/registry_DO_NOT_USE_GC
COPY --from=builder /go/src/github.com/docker/distribution/cmd/registry/config-example.yml /etc/registry/config.yml

RUN chown -R harbor:harbor /etc/pki/tls/certs \
    && chown harbor:harbor /home/harbor/entrypoint.sh && chmod u+x /home/harbor/entrypoint.sh \
    && chown harbor:harbor /home/harbor/install_cert.sh && chmod u+x /home/harbor/install_cert.sh \
    && chown harbor:harbor /usr/bin/registry_DO_NOT_USE_GC && chmod u+x /usr/bin/registry_DO_NOT_USE_GC

HEALTHCHECK CMD curl --fail -s http://localhost:5000 || curl -k --fail -s https://localhost:5443 || exit 1

USER harbor

ENTRYPOINT ["/home/harbor/entrypoint.sh"]

VOLUME ["/storage"]
