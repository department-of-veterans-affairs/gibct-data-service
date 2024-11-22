vpc_subnets = [
    "dsva-vagov-dev-subnet-1a",
    "dsva-vagov-dev-subnet-1b",
    "dsva-vagov-dev-subnet-1c",
]

vpc = "dsva-vagov-dev-vpc"
fargate_count = 3
fargate_cpu = 2048
fargate_memory = 4096

## RYAN Mcneil Help!!!
LINK_HOST: https://dev-platform-api.va.gov
GIBCT_URL: https://dev.va.gov/gi-bill-comparison-tool
SANDBOX_URL: https://dev.va.gov/gi-bill-comparison-tool-sandbox
GOVDELIVERY_URL: stage-tms.govdelivery.com
GOVDELIVERY_STAGING_SERVICE: True
DEPLOYMENT_ENV: vagov-dev

# SSM
# SECRET_KEY_BASE: 0ae77385a98d4d28886d792832fbbe036152efb4a112fae2d06261850a5b6728
ADMIN_EMAIL: 'something@example.gov'
ADMIN_PW: 'something...'
GOVDELIVERY_TOKEN: 'abc123'
