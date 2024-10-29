FROM python:3.9-slim-buster

ARG tag

VOLUME /config

ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y git bash \
&& if [ -z "$tag"]; then \
    echo 'no tag passed in, cloning insteon-mqtt latest'; \
    git clone 'https://github.com/TD22057/insteon-mqtt.git' /opt/insteon-mqtt; \
  else \ 
    echo "cloning insteon-mqtt tag $tag"; \
    git clone --branch $tag 'https://github.com/TD22057/insteon-mqtt.git' /opt/insteon-mqtt; \
  fi \
&& pip install /opt/insteon-mqtt \
&& rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh entrypoint.sh

CMD ["bin/bash", "./entrypoint.sh"]