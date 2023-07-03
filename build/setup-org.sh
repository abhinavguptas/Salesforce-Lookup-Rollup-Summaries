echo "Setting up Org Connection..."
mkdir keys
echo $SFDC_SERVER_KEY | > keys/server.key

echo "Authenticating..."
sfdx force:auth:jwt:grant --clientid $SFDC_CLIENT_ID --jwtkeyfile keys/server.key --username $SFDC_USERNAME --setdefaultdevhubusername -a DevHub
sfdx force:org:list