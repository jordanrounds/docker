FROM eclipse-mosquitto:1.6.9
#https://medium.com/ale-world/standard-init-linux-go-187-exec-user-process-caused-no-such-file-or-directory-e8e45b20f2cd
RUN apk update
RUN apk add bash
RUN apk add tzdata
COPY pre-entrypoint.sh ./
COPY mosquitto.conf ./mosquitto/config
ENTRYPOINT ["/pre-entrypoint.sh"]
CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]