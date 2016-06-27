FROM jenkins:2.0
USER root

# install docker to have the CLI available
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
  echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list && \
  apt-get update && \
  apt-get install -y docker-engine

# add jenkins user to docker group
RUN usermod -a -G docker jenkins

# install ansible
RUN echo "===> Installing python, sudo, and supporting tools..." && \
  apt-get update -y  &&  apt-get install --fix-missing           && \
  DEBIAN_FRONTEND=noninteractive         \
  apt-get install -y                     \
      python python-yaml sudo            \
      curl gcc python-pip python-dev libffi-dev libssl-dev  && \
  apt-get -y --purge remove python-cffi          && \
  pip install --upgrade cffi                     && \
  \
  \
  echo "===> Installing applications via pip..."   && \
  pip install awscli ansible                       && \
  pip install --upgrade setuptools pyasn1          && \
  \
  \
  echo "===> Removing unused APT resources..."                  && \
  apt-get -f -y --auto-remove remove \
               gcc python-dev libffi-dev libssl-dev  && \
  apt-get clean                                                 && \
  rm -rf /var/lib/apt/lists/*  /tmp/*

USER jenkins
