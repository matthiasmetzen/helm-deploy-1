FROM alpine:3.13

ENV BASE_URL="https://get.helm.sh"

ENV HELM_FILE="helm-v3.9.0-linux-amd64.tar.gz"

ARG SOPS_VERSION="v3.7.1"

RUN apk add --no-cache ca-certificates \
    --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
    jq curl wget bash nodejs yarn git gnupg age && \
    \
    wget https://github.com/mozilla/sops/releases/download/$SOPS_VERSION/sops-$SOPS_VERSION.linux -O /usr/local/bin/sops && \
    chmod 0755 /usr/local/bin/sops && \
    chown root:root /usr/local/bin/sops && \
    mkdir /lib64 && \
    ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && \
    curl -L ${BASE_URL}/${HELM_FILE} | tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    helm plugin install https://github.com/jkroepke/helm-secrets --version v3.14.0

COPY . /usr/src

RUN ["yarn", "--cwd", "/usr/src", "install"]

ENTRYPOINT ["node", "--experimental-modules", "/usr/src/index.js"]
