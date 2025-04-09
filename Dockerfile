FROM ubuntu:22.04

ENV TZ=Asia/Ho_Chi_Minh

# Cập nhật hệ thống & cài gói cần thiết
RUN apt update && \
    apt install -y \
    wget curl tar tzdata ca-certificates bash iproute2 \
    systemctl net-tools sudo gpg lsb-release gnupg \
    fail2ban && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt autoremove

# Tạo thư mục làm việc
WORKDIR /app

# Copy script cài đặt
COPY install.sh ./install.sh

# Đặt quyền thực thi và chạy cài đặt
RUN chmod +x ./install.sh && ./install.sh

# Dùng volume để giữ cấu hình
VOLUME ["/etc/x-ui"]

# Khởi động container
CMD ["bash", "-c", "x-ui start && bash"]

