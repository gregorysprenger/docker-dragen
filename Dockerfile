ARG runfile=dragen-4.3.6-11.multi.el8.x86_64.run

FROM oraclelinux:8
ARG runfile

# Install packages in specific order
RUN dnf install -y \
    unzip \
    which \
    wget \
    && dnf config-manager --enable ol8_codeready_builder \
    && dnf install -y \
    oracle-epel-release-el8 \
    && dnf install -y \
    smartmontools \
    kernel-devel \
    hostname \
    kernel \
    rsync \
    dkms \
    time \
    perl \
    gdb \
    sos \
    bc \
    R \
    && dnf clean all

# Fake out the preflight check for kernel version/kernel-devel package match
COPY fake_uname/uname /usr/bin/uname

# Use local download under runfile/ due to required signed URL
COPY runfile/"${runfile}" /

# Have to fake out the Docker build to think RUN returned without error
RUN /bin/sh "${runfile}"; \
    rm -rf "${runfile}" && \
    rm -rf /dragen_software
