FROM mcr.microsoft.com/devcontainers/base:ubuntu
# Install the xz-utils package, zip, curl, git, wget, unzip, and jq
RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  apt-transport-https \
  apt-utils \
  ca-certificates \
  curl \
  git \
  gnupg \
  iputils-ping \
  lsb-release \
  python3-pip \
  software-properties-common \
  unzip \
  wget \
  gpg \
  coreutils

  # install terraform and hcp
RUN wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && apt install terraform hcp -y

# install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  sudo ./aws/install

# install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
  chmod 700 get_helm.sh && \
  ./get_helm.sh

