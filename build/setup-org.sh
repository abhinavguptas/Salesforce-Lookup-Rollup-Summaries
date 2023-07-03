echo "Setting up Org Connection..."
mkdir keys

echo $SFDC_CLIENT_ID
echo $SFDC_SERVER_KEY | base64 -d > keys/server.key

echo "Authenticating..."
sfdx force:auth:jwt:grant --instanceurl https://login.salesforce.com --clientid $SFDC_CLIENT_ID --jwtkeyfile keys/server.key --username $SFDC_USERNAME --setdefaultdevhubusername -a DevHub
sfdx force:org:list