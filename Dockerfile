FROM alpine:3.9

ENV KUBECTL_VERSION 1.13.1
ENV KUBECTL_URI https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl

RUN set -x \
&&  apk add --update ca-certificates curl bash \
&&  curl -Ls ${KUBECTL_URI} -o /usr/bin/kubectl \
&&  chmod +x /usr/bin/kubectl

COPY run.sh /
ENTRYPOINT ["/run.sh"]