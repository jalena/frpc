FROM alpine:latest AS builder
WORKDIR /root

RUN mkdir /tmp/frp && \
    cd /tmp/frp && \
    ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/fatedier/frp/releases/latest | grep 'tag_name' | cut -d\" -f4) && \
    frp_ver="frp_$(echo ${ver} | sed -e 's/^[a-zA-Z]//g')" && \
    wget --no-check-certificate "https://github.com/fatedier/frp/releases/download/${ver}/${frp_ver}_linux_amd64.tar.gz" && \
    tar zxf ${frp_ver}_linux_amd64.tar.gz && \
    mv /tmp/frp/${frp_ver}_linux_amd64/frpc /usr/local/bin/frpc && \
    chmod +x /usr/local/bin/frpc

FROM alpine:latest
LABEL maintainer="jalena@bcsytv.com"
WORKDIR /root/
COPY --from=builder /usr/local/bin/frpc /usr/bin/frpc
RUN apk add --no-cache --update tzdata && \
    mkdir -p /var/logs/ && \
    rm -rf /tmp/* /var/cache/apk/*

ENTRYPOINT ["/usr/bin/frpc"]
CMD ["-c", "/etc/frpc.toml"]
