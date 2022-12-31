#https://gist.github.com/andyshinn/3ae01fa13cb64c9d36e7
#https://forums.docker.com/t/how-to-run-a-cron-job-inside-a-container-alpine/7759/4
FROM alpine:3.11
RUN apk update
RUN apk add curl
RUN apk add bash
RUN apk add tzdata
RUN apk add bind-tools
COPY dnsimple-updatedns /etc/periodic/15min/dnsimple-updatedns
RUN chmod +x /etc/periodic/15min/dnsimple-updatedns
RUN ./etc/periodic/15min/dnsimple-updatedns
CMD crond -l 2 -f
