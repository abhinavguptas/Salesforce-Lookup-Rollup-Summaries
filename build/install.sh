echo "Installing Dependencies... "
sudo npm install sfdx-cli --global
sudo npm install @salesforce/cli --global

echo "Installing plugins... "
echo y |sfdx plugins:install https://github.com/Accenture/sfpowerkit -f
echo "Installing jq to read json... "
sudo apt-get install jq