FROM ubuntu:18.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    iputils-ping \
    libcurl4 \
    libicu60 \
    libunwind8 \
    netcat \
    libssl1.0 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH=amd64
ARG AGENT_VERSION=2.196.2

WORKDIR /azp
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz; \
    else \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${TARGETARCH}-${AGENT_VERSION}.tar.gz; \
    fi; \
    curl -LsS "$AZP_AGENTPACKAGE_URL" | tar -xz

#Added support for docker in docker

RUN apt update && apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release sudo && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io && docker --version && rm -rf /var/lib/apt/lists/*

ENV DOTNET_CLI_TELEMETRY_OPTOUT=0
ENV AZP_AGENT_DOWNGRADE_DISABLED=true
#Added support for latest Nexus Sonatype (this required Net Core 3.1+)

RUN apt update && apt install wget curl && wget https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && rm -v packages-microsoft-prod.deb &&    apt-get update && apt-get install -y apt-transport-https && DOTNET_CLI_TELEMETRY_OPTOUT=0 apt-get install -y dotnet-sdk-3.1 dotnet-sdk-2.1 && rm -rf /var/lib/apt/lists/*

ENV ANT_HOME=/usr/share/ant GRADLE_HOME=/usr/share/gradle M2_HOME=/usr/share/maven 

RUN apt-get update  && apt-get install -y --no-install-recommends  unzip   maven  && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://services.gradle.org/distributions/gradle-4.6-bin.zip -o gradle-4.6.zip  && unzip -d /usr/share gradle-4.6.zip  && ln -s /usr/share/gradle-4.6/bin/gradle /usr/bin/gradle  && rm gradle-4.6.zip
RUN apt-get update  && apt-get install -y --no-install-recommends     ant     ant-optional  && rm -rf /var/lib/apt/lists/*
COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
