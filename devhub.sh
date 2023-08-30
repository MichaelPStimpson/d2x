#!/bin/bash

if [ -f /tmp/dev_hub_authenticated ]; then
    exit 0
fi


if [ -z "$DEV_HUB_AUTH_URL" ]; then
    if [ -z "$DEV_HUB_USERNAME" ]; then
        echo "DEV_HUB_USERNAME is not set, length is $(echo $(($(echo $DEV_HUB_USERNAME|wc -c)-1))). You must set either DEV_HUB_AUTH_URL or DEV_HUB_USERNAME, DEV_HUB_CLIENT_ID, and DEV_HUB_PRIVATE_KEY."
        exit 1
    fi
    if [ -z "$DEV_HUB_CLIENT_ID" ]; then
        echo "DEV_HUB_CLIENT_ID is not set, length is $(echo $(($(echo $DEV_HUB_CLIENT_ID|wc -c)-1))). You must set either DEV_HUB_AUTH_URL or DEV_HUB_USERNAME, DEV_HUB_CLIENT_ID, and DEV_HUB_PRIVATE_KEY."
        exit 1
    fi
    if [ -z "$DEV_HUB_PRIVATE_KEY" ]; then
        echo "DEV_HUB_PRIVATE_KEY is not set, length is $(echo $(($(echo $DEV_HUB_PRIVATE_KEY|wc -c)-1))). You must set either DEV_HUB_AUTH_URL or DEV_HUB_USERNAME, DEV_HUB_CLIENT_ID, and DEV_HUB_PRIVATE_KEY."
        exit 1
    fi

    echo "Authenticating to DevHub using JWT..."

    # Write the DEV_HUB_PRIVATE_KEY to a file
    echo $DEV_HUB_PRIVATE_KEY > /tmp/dev_hub.key

    # Authenticate the DevHub
    sf org login jwt \
        --username $DEV_HUB_USERNAME \
        --jwt-key-file /tmp/dev_hub.key \
        --client-id $DEV_HUB_CLIENT_ID \
        --alias DevHub \
        --set-default-dev-hub

    rm /tmp/dev_hub.key

else
    # Authenticate using Auth URL
    echo "Authenticating to DevHub using auth url..."

    # Write the DEV_HUB_AUTH_URL to a file
    echo $DEV_HUB_AUTH_URL > /tmp/dev_hub_auth_url

    # Authenticate the DevHub
    sfdx org login sfdx-url -f /tmp/dev_hub_auth_url -a DevHub -d

    rm /tmp/dev_hub_auth_url
fi

if [ -z "$PACKAGING_ORG_AUTH_URL" ]; then
else
    # Authenticate using Auth URL
    echo "Authenticating to Packaging Org using auth url..."

    # Write the PACKAGING_ORG_AUTH_URL to a file
    echo $PACKAGING_ORG_AUTH_URL > /tmp/packaging_org_auth_url

    # Authenticate the DevHub
    sfdx org login sfdx-url -f /tmp/packaging_org_auth_url -a packaging

    # Import the org to CumulusCI
    cci org import packaging packaging

    rm /tmp/packaging_org_auth_url
fi

# Ensure the force-app/main/default folder exists
mkdir -p force-app/main/default

touch /tmp/dev_hub_authenticated