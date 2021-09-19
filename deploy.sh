#!/bin/sh
set -e

terraform -chdir=infra init -input=false
terraform -chdir=infra plan -input=false
terraform -chdir=infra apply -input=false

BUCKET=s3://counting-aid.kittenhero.zone
docker-compose run dev npm run build
aws s3 rm $BUCKET --recursive
find site/dist -maxdepth 1 -type f -exec aws s3 cp {} $BUCKET --cache-control no-store \;
aws s3 sync site/dist/assets $BUCKET/assets
