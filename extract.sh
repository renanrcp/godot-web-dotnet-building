if [ -z "$1" ]; then
    echo "Usage: <output_directory>"
    exit 1
fi

docker run --rm -v $1:/out renanrcp/godot-web-build extract
