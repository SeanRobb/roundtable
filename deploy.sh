cd werewolf-ui
yarn build && yarn deploy

cd ../werewolf-api
sam package      --template-file template.yaml      --output-template-file serverless-output.yaml      --s3-bucket werewolf-api
sam deploy      --template-file serverless-output.yaml      --stack-name werewolf-api --capabilities CAPABILITY_IAM