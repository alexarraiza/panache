#Stage 1 - Install dependencies and build the app
FROM ubuntu:18.04 AS build-env

ARG PROJECT_DIR=/srv/api
ENV PATH=/opt/flutter/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update && \
    apt-get install -y \
        xz-utils \
        zip \
        unzip \
        git \
        openssh-client \
        curl && \
    rm -rf /var/cache/apt

RUN curl -L https://storage.googleapis.com/flutter_infra/releases/beta/linux/flutter_linux_v1.14.6-beta.tar.xz | tar -C /opt -xJ

WORKDIR ${PROJECT_DIR}
COPY ./ ./
WORKDIR ${PROJECT_DIR}/panache_web


RUN flutter doctor
RUN flutter upgrade
RUN flutter config --enable-web
RUN flutter build web

# Stage 2 - Create the run-time image
FROM nginx
COPY --from=build-env /srv/api/panache_web/build/web /usr/share/nginx/html
