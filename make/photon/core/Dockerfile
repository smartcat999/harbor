ARG harbor_base_image_version
ARG harbor_base_namespace
ARG go_build_image
FROM ${go_build_image} AS builder

COPY . /harbor

WORKDIR /harbor
RUN BUILD_CORE=true /harbor/make/photon/common/env.sh /harbor/src/core /harbor/make/photon/core/harbor_core


FROM ${harbor_base_namespace}/harbor-core-base:${harbor_base_image_version}

HEALTHCHECK CMD curl --fail -s http://localhost:8080/api/v2.0/ping || curl -k --fail -s https://localhost:8443/api/v2.0/ping || exit 1
COPY ./make/photon/common/install_cert.sh /harbor/
COPY ./make/photon/core/entrypoint.sh /harbor/
#COPY ./make/photon/core/harbor_core /harbor/
COPY --from=builder /harbor/make/photon/core/harbor_core /harbor/
COPY ./src/core/views /harbor/views
COPY ./make/migrations /harbor/migrations
COPY ./icons /harbor/icons

RUN chown -R harbor:harbor /etc/pki/tls/certs \
    && chown -R harbor:harbor /harbor/ \
    && chmod u+x /harbor/entrypoint.sh \
    && chmod u+x /harbor/install_cert.sh \
    && chmod u+x /harbor/harbor_core

WORKDIR /harbor/
USER harbor
ENTRYPOINT ["/harbor/entrypoint.sh"]
COPY make/photon/prepare/versions /harbor/
