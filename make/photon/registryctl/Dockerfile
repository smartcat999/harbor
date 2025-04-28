ARG harbor_base_image_version
ARG harbor_base_namespace
ARG go_build_image

FROM ${go_build_image} AS builder

COPY . /harbor

WORKDIR /harbor
RUN /harbor/make/photon/common/env.sh /harbor/src/registryctl /harbor/make/photon/registryctl/harbor_registryctl


FROM ${go_build_image} AS registry_builder

ARG registry_version

# Set environment variables
ENV DISTRIBUTION_DIR="/go/src/github.com/docker/distribution"
ENV BUILDTAGS="include_oss include_gcs"
ENV GO111MODULE=auto
ENV REGISTRY_VERSION=${registry_version}

# Set working directory
WORKDIR /go/src/github.com/docker

# Copy required patch file and optional Dockerfile.binary into container
#COPY ./make/photon/registry/redis.patch /tmp/redis.patch
COPY ./make/photon/registry/Dockerfile.binary /tmp/Dockerfile.binary

# Build registry binary
RUN git clone -b $REGISTRY_VERSION https://github.com/distribution/distribution.git distribution; \
    cd distribution; \
    # Apply custom redis patch
#    git apply /tmp/redis.patch; \
    # Build the registry binary with specific build tags
    CGO_ENABLED=0 make PREFIX=/go clean binaries; \
    echo "Successfully built the registry binary."


FROM ${harbor_base_namespace}/harbor-registryctl-base:${harbor_base_image_version}

COPY ./make/photon/common/install_cert.sh /home/harbor
#COPY ./make/photon/registry/binary/registry /usr/bin/registry_DO_NOT_USE_GC
COPY --from=registry_builder /go/src/github.com/docker/distribution/bin/registry /usr/bin/registry_DO_NOT_USE_GC
COPY ./make/photon/registryctl/start.sh /home/harbor
#COPY ./make/photon/registryctl/harbor_registryctl /home/harbor
COPY --from=builder /harbor/make/photon/registryctl/harbor_registryctl /home/harbor

RUN chown -R harbor:harbor /etc/pki/tls/certs \
    && chown harbor:harbor /home/harbor/harbor_registryctl && chmod u+x /home/harbor/harbor_registryctl \
    && chown harbor:harbor /usr/bin/registry_DO_NOT_USE_GC && chmod u+x /usr/bin/registry_DO_NOT_USE_GC \
    && chown harbor:harbor /home/harbor/start.sh && chmod u+x /home/harbor/start.sh \
    && chown harbor:harbor /home/harbor/install_cert.sh && chmod u+x /home/harbor/install_cert.sh


HEALTHCHECK CMD curl --fail -s http://localhost:8080/api/health || curl -sk --fail --key /etc/harbor/ssl/registryctl.key --cert /etc/harbor/ssl/registryctl.crt https://localhost:8443/api/health || exit 1

VOLUME ["/var/lib/registry"]

ENTRYPOINT ["/home/harbor/start.sh"]

USER harbor
