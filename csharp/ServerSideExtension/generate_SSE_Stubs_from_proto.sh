#!/bin/sh
cd $1
TOOLS_DIR="../packages/Grpc.Tools.1.4.x/tools/linux_x64"
PROTO_DIR="../../proto"
$TOOLS_DIR/protoc -I$PROTO_DIR --grpc_out=. --csharp_out=. --plugin=protoc-gen-grpc=$TOOLS_DIR/grpc_csharp_plugin $PROTO_DIR/ServerSideExtension.proto