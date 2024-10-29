
#!/bin/bash

/bin/cp /opt/insteon-mqtt/config-example.yaml /config/config-example.yaml.default
echo "in entry point"
  if [ ! -f /config/config.yaml ]; then
    echo "Copying config.yaml"
    /bin/cp /opt/insteon-mqtt/config-example.yaml /config/config.yaml
  fi

insteon-mqtt /config/config.yaml start