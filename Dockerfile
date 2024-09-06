FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y mingw-w64 curl make \
    libgpgme-dev libassuan-dev libdevmapper-dev pkg-config 

COPY --from=golang:1.23.1-bullseye /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

ENV BUILDTAGS=containers_image_openpgp
ENV DISABLE_DOCS=1

WORKDIR skopeo
COPY . .
CMD /bin/bash -c \
    make bin/skopeo.linux.amd64 && \
    make bin/skopeo.linux.arm64 && \
    make bin/skopeo.darwin.amd64 && \
    make bin/skopeo.darwin.arm64 && \
    make bin/skopeo.windows.amd64.exe && \
    make bin/skopeo.windows.arm64.exe && \
    [ -f ./bin/skopeo ] && mv ./bin/skopeo ./bin/skopeo.linux.amd64
# docker build -f Dockerfile -t skopeo-build .
# docker run -v ./bin:/skopeo/bin -t skopeo-build