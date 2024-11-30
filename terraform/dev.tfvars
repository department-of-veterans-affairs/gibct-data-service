vpc_subnets = [
    "dsva-vagov-dev-subnet-1a",
    "dsva-vagov-dev-subnet-1b",
    "dsva-vagov-dev-subnet-1c",
]

vpc = "dsva-vagov-dev-vpc"
fargate_count = 3
fargate_cpu = 2048
fargate_memory = 4096

deployment_env = vagov-dev
gibct_url = https://dev.va.gov/gi-bill-comparison-tool
govdelivery_staging_service = True
govdelivery_url = stage-tms.govdelivery.com
link_host = https://dev-platform-api.va.gov
sandbox_url = https://dev.va.gov/gi-bill-comparison-tool-sandbox

ps_prefix = dev

# SSM
# SECRET_KEY_BASE: 0ae77385a98d4d28886d792832fbbe036152efb4a112fae2d06261850a5b6728
ADMIN_EMAIL: 'something@example.gov'
ADMIN_PW: 'something...'
GOVDELIVERY_TOKEN: 'abc123'
