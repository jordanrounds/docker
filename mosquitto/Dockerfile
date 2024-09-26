FROM eclipse-mosquitto:2.0.18

RUN apk update && \
    apk add --no-cache bash tzdata

COPY pre-entrypoint.sh /pre-entrypoint.sh

RUN chmod +x /pre-entrypoint.sh

ENTRYPOINT ["/pre-entrypoint.sh"]
CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]