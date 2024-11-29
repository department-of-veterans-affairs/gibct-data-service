vpc_subnets = [
    "dsva-vagov-prod-subnet-1a",
    "dsva-vagov-prod-subnet-1b",
    "dsva-vagov-prod-subnet-1c",
]

vpc = "dsva-vagov-prod-vpc"
fargate_count = 3
fargate_cpu = 2048
fargate_memory = 4096

deployment_env = vagov-prod
gibct_url = https://www.va.gov/gi-bill-comparison-tool
govdelivery_staging_service = False
govdelivery_url = tms.govdelivery.com
link_host = https://api.va.gov
sandbox_url = https://www.va.gov/gi-bill-comparison-tool-sandbox
