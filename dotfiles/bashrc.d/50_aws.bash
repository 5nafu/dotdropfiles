function aws-sso-expiry {
  aws configure get sso_start_url --profile ${AWS_PROFILE} | xargs -I {} grep -h {} ~/.aws/sso/cache/*.json | jq .expiresAt | xargs -I {} sh -c 'TZ="UTC" date -j -f "%Y-%m-%dT%H:%M:%S" "+%s" $1 2>/dev/null' -- {} | xargs date -j -f "%s"
}

alias awsd="source _awsd"
alias awslogin='aws sso login && yawsso -d -p $AWS_PROFILE'
