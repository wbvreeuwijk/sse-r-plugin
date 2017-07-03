FROM mono 

ENV expose=${port:-50051}
ENV rserveHost=${rserveHost:-rserve}
ENV grpcHost=${grpcHost:-0.0.0.0}

# Details
LABEL version="1.0"
LABEL description="Image running SSEtoRserve in mono"

# Initial setup
RUN apt-get update && apt-get upgrade -y
RUN apt-get install git unzip -y

# Get SSEtoRserve sources
RUN git clone https://github.com/wbvreeuwijk/sse-r-plugin.git

# Setup build environment
WORKDIR /sse-r-plugin/csharp
RUN nuget restore \
 && temp_dir=packages/Grpc.Tools.1.4.x/tmp \
 && curl_url=https://www.nuget.org/api/v2/package/Grpc.Tools/ \
 && mkdir -p $temp_dir \
 && cd $temp_dir \
 && curl -sL $curl_url > tmp.zip; unzip tmp.zip \
 && cd .. \
 && cp -r tmp/tools . \
 && rm -rf tmp \
 && cd ../.. \
 && chmod 755 packages/Grpc.Tools.1.4.x/tools/linux_x64/protoc \
 && chmod 755 packages/Grpc.Tools.1.4.x/tools/linux_x64/grpc_csharp_plugin \
 && chmod 755 ServerSideExtension/generate_SSE_Stubs_from_proto.sh
 
# Build application
RUN msbuild ServerSideExtension.sln

# Cleanup 
# RUN rm -rf ServerSideExtension packages

# Port SSEtoRserve is going to listen on
EXPOSE ${expose}

# Create configuration file for SSEtoRserve
RUN { \
    echo '<?xml version="1.0" encoding="utf-8" ?>';\
    echo '  <configuration>';\
    echo '    <configSections>';\
    echo '        <sectionGroup name="applicationSettings" type="System.Configuration.ApplicationSettingsGroup, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" >';\
    echo '            <section name="SSEtoRserve.Properties.Settings" type="System.Configuration.ClientSettingsSection, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" requirePermission="false" />';\
    echo '        </sectionGroup>';\
    echo '    </configSections>';\
    echo '    <startup>';\
    echo '        <supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.5.2" />';\
    echo '    </startup>';\
    echo '    <applicationSettings>';\
    echo '        <SSEtoRserve.Properties.Settings>';\
    echo '            <setting name="grpcPort" serializeAs="String">';\
    echo '                <value>50051</value>';\
    echo '            </setting>';\
    echo '            <setting name="rserveHost" serializeAs="String">';\
    echo '                <value>127.0.0.1</value>';\
    echo '            </setting>';\
    echo '            <setting name="rservePort" serializeAs="String">';\
    echo '                <value>6311</value>';\
    echo '            </setting>';\
    echo '            <setting name="grpcHost" serializeAs="String">';\
    echo '                <value>0.0.0.0</value>   <!-- Set to 0.0.0.0 if you want it reachable from the outside world -->';\
    echo '            </setting>';\
    echo '        </SSEtoRserve.Properties.Settings>';\
    echo '    </applicationSettings>';\
    echo '</configuration>';\
} | tee /sse-r-plugin/csharp/SSEtoRserve/bin/Debug/SSEtoRserve.exe.config

## Use Debian unstable via pinning -- new style via APT::Default-Release
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && echo "deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/" > /etc/apt/sources.list.d/ubuntu-unstable.list \
	&& echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default

ENV R_BASE_VERSION 3.4.0

## Now install R and littler, and create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
RUN apt-get update \
	&& apt-get install -t unstable -y --no-install-recommends \
		littler \
                r-cran-littler \
		r-base=${R_BASE_VERSION}* \
		r-base-dev=${R_BASE_VERSION}* \
		r-recommended=${R_BASE_VERSION}* \
        && echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
        && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
	&& ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& rm -rf /var/lib/apt/lists/*

# Start command
#ENTRYPOINT ["/usr/bin/mono", "/sse-r-plugin/csharp/SSEtoRserve/bin/Debug/SSEtoRserve.exe"]