# A basic build script that *should* build the system in static release mode
# Need to install termbox into the image mentioned below, so I might need to build an image for myself from it that installs termbox
docker run --rm -it -v $PWD:/app -w /app jrei/crystal-alpine crystal build --static --release src/crcophony.cr
