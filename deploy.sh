cd round-table-ui
yarn build && yarn deploy

cd ../round-table-api
sam package --template-file template.yaml               --output-template-file serverless-output.yaml  --s3-bucket round-table-api
sam deploy  --template-file serverless-output.yaml      --stack-name round-table-api                   --capabilities CAPABILITY_IAM