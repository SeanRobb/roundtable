
1. sam package      --template-file template.yaml      --output-template-file serverless-output.yaml      --s3-bucket werewolf-api
2. sam deploy      --template-file serverless-output.yaml      --stack-name werewolf-api --capabilities CAPABILITY_IAM