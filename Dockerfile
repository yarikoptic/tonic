# SERVICE BUILDER IMAGE
FROM golang:alpine AS binbuilder

# Build dependencies
RUN apk --no-cache --no-progress add gcc musl-dev

RUN go version
COPY ./go.mod ./go.sum /tonic/
WORKDIR /tonic

# Service to compile can be defined as a build arg.
# Default is example.
ARG service=example

# download deps before bringing in the sources
RUN go mod download
COPY ./templates /tonic/templates
COPY ./utonics /tonic/utonics
COPY ./tonic /tonic/tonic
RUN go build -o ${service} ./utonics/${service}/

### ============================ ###

# RUNNER IMAGE
FROM alpine:latest

RUN apk --no-cache --no-progress add git

WORKDIR /tonic

# Service to compile can be defined as a build arg.
# Default is example.
ARG service=example

# Copy binary and resources into runner image
COPY --from=binbuilder /tonic/${service} /tonic/service
COPY ./assets /tonic/assets

ENTRYPOINT /tonic/service
EXPOSE 3000
