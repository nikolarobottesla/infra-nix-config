# Start with the minimal Fedora 42 image
FROM quay.io/fedora/fedora-minimal:42
WORKDIR /

# Install COPR plugin and enable Asahi repositories
RUN dnf install -y 'dnf5-command(copr)' && \
    dnf copr enable -y @asahi/mesa && \
    dnf copr enable -y @asahi/fedora-remix-scripts

# Add architecture-specific repositories for FEX mesa overlays

# i386 Repository
RUN echo '[copr:copr.fedorainfracloud.org:group_asahi:mesa-i386]' > /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'name=Copr repo for mesa owned by @asahi (i386)' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'baseurl=https://download.copr.fedorainfracloud.org/results/@asahi/mesa/fedora-$releasever-i386/' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'type=rpm-md' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'skip_if_unavailable=True' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'gpgcheck=1' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-group_asahi-mesa' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'enabled=1' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'enabled_metadata=1' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'priority=5' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo && \
    echo 'includepkgs=mesa-fex-emu-overlay-i386*' >> /etc/yum.repos.d/group_asahi-mesa-i386.repo

# x86_64 Repository
RUN echo '[copr:copr.fedorainfracloud.org:group_asahi:mesa-x86_64]' > /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'name=Copr repo for mesa owned by @asahi (x86_64)' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'baseurl=https://download.copr.fedorainfracloud.org/results/@asahi/mesa/fedora-$releasever-x86_64/' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'type=rpm-md' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'skip_if_unavailable=True' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'gpgcheck=1' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-group_asahi-mesa' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'enabled=1' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'enabled_metadata=1' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'priority=5' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo && \
    echo 'includepkgs=mesa-fex-emu-overlay-x86_64*' >> /etc/yum.repos.d/group_asahi-mesa-x86_64.repo

# Clean DNF cache before installing packages
RUN dnf clean all
RUN dnf upgrade --refresh -y

# Install the Asahi platform metapackage
RUN dnf install -y asahi-platform-metapackage-fex

# Install the rest of the required packages
RUN dnf install -y \
    fontconfig \
    dejavu-sans-fonts \
    dejavu-serif-fonts \
    dejavu-sans-mono-fonts \
    sudo \
    xz \
    ps \
    vim \
    xterm \
    ar \
    tar \
    bash \
    coreutils \
    util-linux \
    procps-ng \
    findutils \
    grep \
    sed \
    gawk \
    gzip \
    which \
    less \
    nano \
    passwd \
    shadow-utils \
    systemd \
    iproute \
    iputils \
    curl \
    wget \
    mesa-libGLU \
    ca-certificates \
    alsa-utils

# Enable the Asahi Steam COPR and install Steam
RUN dnf copr enable -y @asahi/steam && \
    dnf install -y steam

# Final cleanup to reduce image size
RUN dnf clean all && \
    rm -rf /var/cache/dnf/* /tmp/* /var/tmp/*

CMD ["/bin/bash"]