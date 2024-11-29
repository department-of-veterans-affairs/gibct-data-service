vpc_subnets = [
    "dsva-vagov-staging-subnet-1a",
    "dsva-vagov-staging-subnet-1b",
    "dsva-vagov-staging-subnet-1c",
]

vpc = "dsva-vagov-prod-vpc"
fargate_count = 3
fargate_cpu = 2048
fargate_memory = 4096

deployment_env = vagov-staging
gibct_url = https://staging.va.gov/gi-bill-comparison-tool
govdelivery_staging_service = True
govdelivery_url = stage-tms.govdelivery.com
link_host = https://staging-platform-api.va.gov
sandbox_url = https://staging.va.gov/gi-bill-comparison-tool-sandbox
