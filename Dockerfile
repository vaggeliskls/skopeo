# Use Ubuntu 18.04 as the base image
FROM ubuntu:18.04

# Set ARG for the Skopeo Git tag to be used for the clone
ARG SKOPEO_TAG=v1.16.1  # Default tag, can be overridden at build time

# Install required dependencies: mingw for cross-compiling, curl, make, and various libraries
RUN apt-get update && \
    apt-get install -y mingw-w64 curl make \
    libgpgme-dev libassuan-dev libdevmapper-dev pkg-config git && \
    # Clean up the apt cache to reduce image size
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the Go binary from the official Go image
COPY --from=golang:1.23.1-bullseye /usr/local/go/ /usr/local/go/

# Set environment variables to include Go in the PATH
ENV PATH="/usr/local/go/bin:${PATH}"

# Set build tags and disable documentation generation
ENV BUILDTAGS=containers_image_openpgp
ENV DISABLE_DOCS=1

# Set the working directory for building Skopeo
WORKDIR /skopeo

# Clone the Skopeo GitHub repository using the provided tag
RUN git clone --branch ${SKOPEO_TAG} https://github.com/containers/skopeo.git . && \
    git checkout ${SKOPEO_TAG}

# Run the make command to build different binaries for multiple platforms
CMD /bin/bash -c \
    make bin/skopeo.linux.amd64 && \
    make bin/skopeo.linux.arm64 && \
    make bin/skopeo.darwin.amd64 && \
    make bin/skopeo.darwin.arm64 && \
    make bin/skopeo.windows.amd64.exe && \
    make bin/skopeo.windows.arm64.exe && \
    # Rename the Linux binary to ensure it's available as a default output
    [ -f ./bin/skopeo ] && mv ./bin/skopeo ./bin/skopeo.linux.amd64

# Example build command:
# docker build -f Dockerfile --build-arg SKOPEO_TAG=v1.8.0 -t skopeo-build .
# To override the tag, change the SKOPEO_TAG arg during build

# Example run command to map the output directory:
# docker run -v $(pwd)/bin:/skopeo/bin -t skopeo-build
