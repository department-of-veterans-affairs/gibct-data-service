vpc_subnets = [
    "dsva-vagov-prod-subnet-1a",
    "dsva-vagov-prod-subnet-1b",
    "dsva-vagov-prod-subnet-1c",
]

vpc = "dsva-vagov-prod-vpc"
fargate_count = 3
fargate_cpu = 2048
fargate_memory = 4096

## RYAN Mcneil Help!!!
LINK_HOST: https://api.va.gov
GIBCT_URL: https://www.va.gov/gi-bill-comparison-tool
SANDBOX_URL: https://www.va.gov/gi-bill-comparison-tool-sandbox
GOVDELIVERY_URL: tms.govdelivery.com
GOVDELIVERY_STAGING_SERVICE: False
DEPLOYMENT_ENV: vagov-prod
