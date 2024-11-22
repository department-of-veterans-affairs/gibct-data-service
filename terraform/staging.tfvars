vpc_subnets = [
    "dsva-vagov-staging-subnet-1a",
    "dsva-vagov-staging-subnet-1b",
    "dsva-vagov-staging-subnet-1c",
]

vpc = "dsva-vagov-prod-vpc"
fargate_count = 3
fargate_cpu = 2048
fargate_memory = 4096

## RYAN Mcneil Help!!!
LINK_HOST: https://staging-platform-api.va.gov
GIBCT_URL: https://staging.va.gov/gi-bill-comparison-tool
SANDBOX_URL: https://staging.va.gov/gi-bill-comparison-tool-sandbox
GOVDELIVERY_URL: stage-tms.govdelivery.com
GOVDELIVERY_STAGING_SERVICE: True
DEPLOYMENT_ENV: vagov-staging
