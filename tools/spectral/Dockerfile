ARG GOLANG
FROM ${GOLANG}

ARG SPECTRAL_VERSION

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64) TARGET_ARCH="linux-x64" ;; \
      aarch64) TARGET_ARCH="linux-arm64" ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    echo $TARGET_ARCH && \
    curl -fsSL -o /usr/bin/spectral https://github.com/stoplightio/spectral/releases/download/${SPECTRAL_VERSION}/spectral-${TARGET_ARCH} && \
    chmod +x /usr/bin/spectral

ENTRYPOINT ["/usr/bin/spectral"]
CMD ["--version"]