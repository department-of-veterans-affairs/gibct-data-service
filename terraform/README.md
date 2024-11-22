### Build & Push Docker Image

The ECR registry is created by the Terraform in this repo.  So the terraform must be run prior to pushing the docker image.

```bash
docker build -t 008577686731.dkr.ecr.us-gov-west-1.amazonaws.com/dsva-vagov-gibct-default:latest .
aws ecr get-login-password | docker login --username AWS --password-stdin 008577686731.dkr.ecr.us-gov-west-1.amazonaws.com/dsva-vagov-gibct-default
docker push 008577686731.dkr.ecr.us-gov-west-1.amazonaws.com/dsva-vagov-gibct-default:latest
```

### Roll Fargate Tasks

To tell ecs to redeploy with the new image without executing the terraform use the following command.

```bash
aws ecs update-service --cluster dsva-vagov-gibct-default --service dsva-vagov-gibct-default --force-new-deployment --region us-gov-west-1
```

### Testing with curl

```bash
curl --socks5-hostname http://localhost:2001 http://dsva-vagov-gibct-default-fg.vfs.va.gov/
```