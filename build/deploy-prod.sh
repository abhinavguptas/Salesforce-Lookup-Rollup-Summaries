#Deploy the package to Prod
sf project convert source --api-version 58.0 --root-dir force-app --output-dir src 
sf project deploy start --metadata-dir src --target-org prod-org --concise --ignore-conflicts