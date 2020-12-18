FROM tsightler/ring-mqtt:latest
COPY pre-entrypoint.sh /
RUN apk update
RUN apk add bash
ENTRYPOINT ["/pre-entrypoint.sh"]
