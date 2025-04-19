FROM ubuntu:22.04

ENV TZ=Asia/Ho_Chi_Minh

# Dùng BuildKit hoặc apt-get chuẩn không cảnh báo
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://opensource.xtdv.net/ubuntu/|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|http://opensource.xtdv.net/ubuntu/|g' /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget curl tar tzdata ca-certificates bash iproute2 \
    net-tools systemctl sudo gpg lsb-release gnupg fail2ban && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY install.sh ./install.sh

RUN chmod +x ./install.sh && ./install.sh

VOLUME ["/etc/x-ui"]

CMD ["bash", "-c", "x-ui start && tail -f /dev/null"]
