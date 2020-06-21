# Werewolf Project
## Werewolf UI
1. cd werewolf-ui
### To Develop Locally
1. yarn start
## Werewolf API
1. cd werewolf-api
### To Deploy locally
1. rackup lib/werewolf/config.ru
### To Deploy to AWS
1. sam package      --template-file template.yaml      --output-template-file serverless-output.yaml      --s3-bucket werewolf-api
2. sam deploy      --template-file serverless-output.yaml      --stack-name werewolf-api --capabilities CAPABILITY_IAM