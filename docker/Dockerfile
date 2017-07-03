FROM mono 

ENV expose=${port:-50051}
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
RUN rm -rf ServerSideExtension packages

# Port SSEtoRserve is going to listen on
EXPOSE ${expose}

# Start command
ENTRYPOINT ["/usr/bin/mono",
            "/sse-r-plugin/csharp/SSEtoRserve/bin/Debug/SSEtoRserve.exe",
            "-p",
            ${expose}]