FROM mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-16.04-tfs-2018-u2-docker-18.06.1-ce-standard

#Added support for latest Nexus Sonatype (this required Net Core 3.1+)
RUN wget https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && rm -v packages-microsoft-prod.deb &&
apt-get update && apt-get install -y apt-transport-https && DOTNET_CLI_TELEMETRY_OPTOUT=0 apt-get install -y dotnet-sdk-3.0 && apt-get clean

ENV DOTNET_CLI_TELEMETRY_OPTOUT=0

CMD ["./start.sh"]
