ARG DRAGEN_VERSION="4.5.4"
ARG RUNFILE="dragen-${DRAGEN_VERSION}-12.multi.el8.x86_64.run"

# ==========================================
# Build DRAGEN from Oracle Linux 8 RPM
# ==========================================
FROM oraclelinux:8 AS builder
ARG DRAGEN_VERSION
ARG RUNFILE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN yum -y install cpio && yum clean all

COPY "${RUNFILE}" /tmp/dragen.run

# Build DRAGEN from the RPM
RUN mkdir -p /tmp/dragen_extract /target_root \
    && /bin/sh /tmp/dragen.run --noexec --target /tmp/dragen_extract \
    && for rpm in /tmp/dragen_extract/*.rpm; do \
           rpm2cpio "$rpm" | (cd /target_root/ && cpio -idmv); \
       done

# ==========================================
# Runtime Build
# ==========================================
FROM oraclelinux:8
ARG DRAGEN_VERSION

ENV PATH="/opt/dragen/${DRAGEN_VERSION}/bin:${PATH:-/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin}"
ENV LD_LIBRARY_PATH="/usr/lib64:/opt/dragen/${DRAGEN_VERSION}/lib"

RUN yum -y install --nodocs oracle-epel-release-el8 \
    && yum -y install epel-release \
    && yum -y install --nodocs which bc perl rsync time udev systemd-libs \
    && yum -y install --nodocs --enablerepo=ol8_codeready_builder R-core \
    && yum clean all \
    && rm -rf /var/cache/yum /usr/share/doc /usr/share/man

COPY --from=builder /target_root/opt/dragen /opt/dragen
COPY --from=builder /target_root/opt/bitstream /opt/bitstream
COPY --from=builder /target_root/usr/lib64/ /usr/lib64/
COPY --from=builder /target_root/etc/ /etc/

RUN ldconfig \
    && find "/opt/dragen/${DRAGEN_VERSION}/bin" -maxdepth 1 -type f -executable -exec ln -sf {} /usr/local/bin/ \; \
    && test -x /usr/local/bin/dragen

WORKDIR /opt/dragen/${DRAGEN_VERSION}

EXPOSE 22

CMD ["dragen", "--help"]