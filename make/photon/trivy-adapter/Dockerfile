ARG harbor_base_image_version
ARG harbor_base_namespace
ARG trivy_adapter_version
ARG trivy_version
ARG go_build_image

FROM ${go_build_image} AS trivy_adapter_context

ENV TRIVY_ADAPTER_VERSION=${trivy_adapter_version}

RUN mkdir -p /go/src/github.com/aquasecurity && \
    cd /go/src/github.com/aquasecurity && \
    git clone https://github.com/aquasecurity/harbor-scanner-trivy.git && \
    cd /go/src/github.com/aquasecurity/harbor-scanner-trivy && \
    git checkout $TRIVY_ADAPTER_VERSION

WORKDIR /go/src/github.com/aquasecurity/harbor-scanner-trivy/

RUN export GOOS=linux GO111MODULE=on CGO_ENABLED=0 && \
	go build -o scanner-trivy cmd/scanner-trivy/main.go


FROM aquasec/trivy:${trivy_version} AS trivy_context


FROM ${harbor_base_namespace}/harbor-trivy-adapter-base:${harbor_base_image_version}

ARG trivy_version

COPY ./make/photon/common/install_cert.sh /home/scanner
COPY ./make/photon/trivy-adapter/entrypoint.sh /home/scanner
#COPY ./make/photon/trivy-adapter/binary/trivy /usr/local/bin/trivy
COPY --from=trivy_context /usr/local/bin/trivy /usr/local/bin/trivy
#COPY ./make/photon/trivy-adapter/binary/scanner-trivy /home/scanner/bin/scanner-trivy
COPY --from=trivy_adapter_context /go/src/github.com/aquasecurity/harbor-scanner-trivy/scanner-trivy /home/scanner/bin/scanner-trivy

RUN chown -R scanner:scanner /etc/pki/tls/certs \
    && chown scanner:scanner /home/scanner/entrypoint.sh && chmod u+x /home/scanner/entrypoint.sh \
    && chown scanner:scanner /usr/local/bin/trivy && chmod u+x /usr/local/bin/trivy \
    && chown scanner:scanner /home/scanner/bin/scanner-trivy && chmod u+x /home/scanner/bin/scanner-trivy \
    && chown scanner:scanner /home/scanner/install_cert.sh && chmod u+x /home/scanner/install_cert.sh

HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl --fail -s http://localhost:8080/probe/healthy || curl -k --fail -s https://localhost:8443/probe/healthy || exit 1

ENV TRIVY_VERSION=${trivy_version}

USER scanner

ENTRYPOINT ["/home/scanner/entrypoint.sh"]
