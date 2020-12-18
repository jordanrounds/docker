#!/bin/bash

echo
echo "DNSimple Dynamic Dns Container Init"
echo "Creating secret files"
echo

if ! [[ -f $SECRETS/dnsimple.account_id ]]
then
touch $SECRET/dnsimple.account_id
read -p 'DNSimple account id: ' account_id
echo $account_id >> $SECRETS/dnsimple.account_id
echo "Added $SECRETS/dnsimple.account_id and populated with $account_id"
else
echo "$SECRETS/dnsimple.account_id already exists, skipping creation"
fi

if ! [[ -f $SECRETS/dnsimple.record_id ]]
then
touch $SECRET/dnsimple.record_id
read -p 'DNSimple record id: ' record_id
echo $record_id >> $SECRETS/dnsimple.record_id
echo "Added $SECRETS/dnsimple.record_id and populated with $record_id"
else
echo "$SECRETS/dnsimple.record_id already exists, skipping creation"
fi

if ! [[ -f $SECRETS/dnsimple.token ]]
then
touch $SECRET/dnsimple.token
read -p 'DNSimple token: ' token
echo $token >> $SECRETS/dnsimple.token
echo "Added $SECRETS/dnsimple.token and populated with $token"
else
echo "$SECRETS/dnsimple.token already exists, skipping creation"
fi

if ! [[ -f $SECRETS/dnsimple.wildcard_record_id ]]
then
touch $SECRET/dnsimple.wildcard_record_id
read -p 'DNSimple wildcard record id: ' wildcard_record_id
echo $wildcard_record_id >> $SECRETS/dnsimple.wildcard_record_id
echo "Added $SECRETS/dnsimple.wildcard_record_id and populated with $wildcard_record_id"
else
echo "$SECRETS/dnsimple.wildcard_record_id already exists, skipping creation"
fi

if ! [[ -f $SECRETS/dnsimple.zone_id ]]
then
touch $SECRET/dnsimple.zone_id
read -p 'DNSimple zone id: ' zone_id
echo $zone_id >> $SECRETS/dnsimple.zone_id
echo "Added $SECRETS/dnsimple.zone_id and populated with $zone_id"
else
echo "$SECRETS/dnsimple.zone_id already exists, skipping creation"
fi

