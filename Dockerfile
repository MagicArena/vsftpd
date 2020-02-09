FROM alpine:latest

LABEL cn.magicarnea.description="Vsftpd docker image based on alpine." \
      cn.magicarnea.vendor="MagicArena" \
      cn.magicarnea.maintainer="everoctivian@gmail.com" \
      cn.magicarnea.versionCode=1 \
      cn.magicarnea.versionName="3.0.3"

# if you want use APK mirror then uncomment, modify the mirror address to which you favor
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://mirrors.aliyun.com|g' /etc/apk/repositories

ENV TIME_ZONE=Asia/Shanghai
RUN set -ex && \
    apk add --no-cache ca-certificates curl tzdata shadow build-base linux-pam-dev unzip vsftpd openssl && \
    ln -snf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
    echo ${TIME_ZONE} > /etc/timezone && \
    rm -rf /tmp/* /var/cache/apk/*

COPY libpam-pwdfile.zip /tmp/
RUN set -ex && \
    unzip -q /tmp/libpam-pwdfile.zip -d /tmp/ && \
    cd /tmp/libpam-pwdfile && \
    make install && \
    rm -rf /tmp/libpam-pwdfile && \
    rm -f  /tmp/libpam-pwdfile.zip

COPY ./etc/pam.d/vsftpd /etc/pam.d/
RUN set -ex && \
    mkdir -p /var/log/vsftpd/ && \
    mkdir -p /var/mail/ && \
    useradd ftpuser -m -d /home/ftpuser/ -s /sbin/nologin && \
    chown -R ftpuser:ftpuser /home/ftpuser/

CMD ["/etc/vsftpd/vsftpd.conf"]

ENTRYPOINT ["/usr/sbin/vsftpd"]
