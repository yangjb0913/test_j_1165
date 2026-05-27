FROM ubuntu:22.04

LABEL org.opencontainers.image.ref.name=ubuntu
LABEL org.opencontainers.image.version=22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bzip2 \
    wget \
    git \
    ca-certificates \
    curl \
    && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y g++ \
    && \
    rm -rf /var/lib/apt/lists/*

RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-4.5.1-Linux-x86_64.sh' -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/miniconda3 && \
    rm -f miniconda.sh

ENV PATH=/opt/miniconda3/bin:${PATH}

RUN conda config --add channels conda-forge && \
    conda config --remove channels defaults

WORKDIR /testbed

COPY setup_repo.sh /root/setup_repo.sh
RUN chmod +x /root/setup_repo.sh && \
    /bin/bash /root/setup_repo.sh

COPY setup_env.sh /root/setup_env.sh
RUN chmod +x /root/setup_env.sh && \
    /bin/bash /root/setup_env.sh

RUN echo "127.0.0.1 localhost.jovyan.org >> /etc/hosts"
ENV JUPYTERHUB_TEST_SUBDOMAIN_HOST=http://localhost.jovyan.org:8000
