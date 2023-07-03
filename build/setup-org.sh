echo "Setting up DevHub Connection..."
mkdir keys
echo $SFDC_SERVER_KEY | base64 -d > keys/server.key

echo "Authenticating..."
RES=$(sfdx force:auth:jwt:grant --clientid $SFDC_CLIENT_ID --jwtkeyfile keys/server.key --username $SFDC_USERNAME --setdefaultdevhubusername -a DevHub --json)
SFDC_AUTHENTICATE_ID=$(echo ${RES} | jq --raw-output .result.orgId) 
echo "OrgId..."
echo ${SFDC_AUTHENTICATE_ID}