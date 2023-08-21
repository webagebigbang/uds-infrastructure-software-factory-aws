region = "us-west-2"

# Object Storage Variables
bucket_name_suffix         = "-example"
kubernetes_namespace       = "gitlab"
kubernetes_service_account = "gitlab"
oidc_provider_arn          = "arn:aws:iam::111111111111:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/22222222222222222222222222222222"

# Database Variables
db_subnet_group_name = "uds-swf"

# Elasticache Variables
elasticache_subnet_group_name = "uds-swf"
elasticache_password = "mysecretudsswfpassword"
