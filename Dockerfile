# Build a Dockerfile from the alpine-crystal one that also installs termbox
FROM jrei/crystal-alpine
# We won't copy the app onto the image, no need, so just install termbox
RUN git clone https://github.com/nsf/termbox.git /termbox
RUN cd /termbox && \
    ./waf configure --prefix=/usr && \
    ./waf && \
    ./waf install

