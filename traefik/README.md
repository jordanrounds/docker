## Generate basic auth password
echo $(htpasswd -nB jordan) | sed -e s/\\$/\\$\\$/g

This should be changed to not escape the $ since its being written to a file in docker secrets and not as an environment variable
