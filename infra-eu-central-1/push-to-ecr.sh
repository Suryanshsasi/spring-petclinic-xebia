#!/bin/bash
$(aws ecr get-login --no-include-email --region eu-central-1)
docker push <your-ecr-repo>
