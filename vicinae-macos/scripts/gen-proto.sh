#!/bin/bash

# Ensure protoc is installed
if ! command -v protoc &> /dev/null; then
    echo "protoc could not be found. Please install it (e.g. brew install protobuf)"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# vicinae-macos root
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
# Repository root (one level up from vicinae-macos)
REPO_ROOT="$(dirname "$PROJECT_ROOT")"

# Output directory
OUT_DIR="$PROJECT_ROOT/Sources/Vicinae/Protobuf"
PROTO_DIR="$REPO_ROOT/proto"

mkdir -p "$OUT_DIR"

# Generate Swift code
protoc --swift_out="$OUT_DIR" --swift_opt=Visibility=Public --proto_path="$PROTO_DIR" "$PROTO_DIR"/*.proto

echo "Protobuf files generated in $OUT_DIR"
