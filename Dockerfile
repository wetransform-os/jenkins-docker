FROM jenkins:2.0
USER root

# install docker to have the CLI available
ENV DOCKER_VERSION 17.12.0~ce-0~debian

RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
RUN apt-get update
RUN apt-get install -y docker-ce=$DOCKER_VERSION


# add jenkins user to docker group
RUN usermod -a -G docker jenkins

# install go and set environment
ENV GO_VERSION 1.9.3
RUN wget https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz
RUN tar -xvf go$GO_VERSION.linux-amd64.tar.gz
RUN mv go/ /usr/local
ENV GOROOT /usr/local/go
ENV GOPATH /var/jenkins_home/go
ENV GOBIN $GOPATH/bin
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

# install ansible
# libstdc++6 for hale GDAL binding
# genisoimage for hale macOS DMG image
# pin Jinja2 to 2.8.1 b/c of https://github.com/ansible/ansible/issues/20494
RUN echo "===> Installing python, sudo, and supporting tools..." && \
  apt-get update -y  &&  apt-get install --fix-missing           && \
  DEBIAN_FRONTEND=noninteractive         \
  apt-get install -y                     \
      python python-yaml sudo rsync      \
      libstdc++6 genisoimage \
      curl gcc python-pip python-dev libffi-dev libssl-dev  && \
  apt-get -y --purge remove python-cffi          && \
  pip install --upgrade cffi                     && \
  \
  \
  echo "===> Installing applications via pip..."   && \
  pip install --upgrade setuptools pyasn1          && \
  pip install awscli git+git://github.com/ansible/ansible.git@v2.3.0.0-1 && \
  pip install Jinja2==2.8.1                        && \
  \
  \
  echo "===> Removing unused APT resources..."                  && \
  apt-get -f -y --auto-remove remove \
               gcc python-dev libffi-dev libssl-dev  && \
  apt-get clean                                                 && \
  rm -rf /var/lib/apt/lists/*  /tmp/*

USER jenkins
