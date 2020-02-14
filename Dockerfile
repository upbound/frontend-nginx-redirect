FROM alpine:latest

# YOU CAN ALSO SET ENV VARIABLES
# ENV WORKER_CONNECTIONS 1024
# ENV HTTP_PORT 8080
# ENV REDIRECT https://www.google.com/

COPY nginx-boot.sh /sbin/nginx-boot

RUN chmod +x /sbin/nginx-boot && \
    apk --update add nginx bash && \
    rm -fR /var/cache/apk/*

EXPOSE 8080

CMD [ "/sbin/nginx-boot" ]
