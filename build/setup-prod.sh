echo "Setting up Org Connection..."
mkdir keys

echo $SFDC_CLIENT_ID
echo $SFDC_SERVER_KEY | base64 -d > keys/server.key

echo "Authenticating..."
sf org login jwt --username $SFDC_USERNAME --jwt-key-file keys/server.key  --client-id $SFDC_CLIENT_ID --alias prod-org --set-default --instance-url https://login.salesforce.com
sf org list