if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: <source> <output_directory> <release|debug|pack> <output_file>"
    exit 1
fi

docker run --rm \
  -v $1:/workspace/src \
  -v $2:/workspace/build \
  renanrcp/godot-web-build build $3 $4
