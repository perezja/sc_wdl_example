FROM satijalab/seurat:latest 

RUN apt-get update && \
    apt-get -y install \
    sudo \
    build-essential \
    curl \
    git \
    nfs-common \
    gdebi-core \
    python3-debian \
    python3-apt \
    python3-pip \
    openssh-client \
    openssl \
    unzip \
    vim \
    wget \
    locales \
    apt-transport-https \
    ca-certificates \
    gnupg

# rstudio
RUN wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.07.1-554-amd64.deb && \
    sudo gdebi -n rstudio-server-2022.07.1-554-amd64.deb && \
    rm rstudio-server-*-amd64.deb && \
    useradd debian && \
    echo "debian:veritas" | chpasswd && \
    mkdir /home/debian && \
    chown debian:debian /home/debian

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8

WORKDIR /home/debian

# google SDK CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg

RUN sudo apt-get update && sudo apt-get install google-cloud-cli

# python dependencies
RUN pip install miniwdl leidenalg pandas 
RUN R -e "install.packages(c('argparse', 'logger', 'glue'))"

# jupyter notebook for vignette on creating input JSON 
# to host `jupyter notebook --allow-root -port=3737 --notebook-dir=/home/debian/code/gedi`
RUN pip3 install jupyter
RUN jupyter notebook --generate-config

# prepare script
COPY src /opt
RUN chmod -R +x /opt
