BASEDIR=$(dirname "$0")
SRC_DIR="$BASEDIR"
IOS_DST_DIR="$BASEDIR/../streamar-ios/streamar-ios/Proto"

protoc --swift_out=$IOS_DST_DIR --swiftgrpc_out=$IOS_DST_DIR "$SRC_DIR/channel.proto"
