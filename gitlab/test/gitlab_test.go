package test_test

import (
	"crypto/rand"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

const (
	awsRegionVar = "region"
	testDir      = "../"
)

var approvedRegions = []string{"us-east-1", "us-east-2", "us-west-1", "us-west-2"}

func TestGitLabModule(t *testing.T) {
	awsRegion := aws.GetRandomStableRegion(t, approvedRegions, nil)

	nameSuffix := generateNameSuffix()

	// This is used for testing Elasticache in its own subnets
	vpcId := os.Getenv("VPC_ID")
	createCacheTestingVpc := false
	if vpcId == "" {
		createCacheTestingVpc = true
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testDir,
		Vars: map[string]interface{}{
			awsRegionVar:                    awsRegion,
			"role_permissions_boundary_arn": os.Getenv("FLOW_LOG_PERMISSION_BOUNDARY"),
			"kubernetes_namespace":          "gitlab-test",
			"kubernetes_service_account":    "gitlab-test",
			"bucket_name_suffix":            nameSuffix,
			"oidc_provider_arn":             fmt.Sprintf("arn:%s:iam::111111111111:oidc-provider/oidc.eks.%s.amazonaws.com/id/22222222222222222222222222222222", getAWSPartition(awsRegion), awsRegion),
			"create_cache_testing_vpc":      createCacheTestingVpc,
			"vpc_id":                        vpcId,
			"create_cache_testing_subnets":  true,
			"elasticache_cluster_name":      "terratest-gitlab-cache",
		},

		BackendConfig: map[string]interface{}{
			"bucket":         os.Getenv("BACKEND_BUCKET"),
			"key":            "swf-gitlab-terratest.tfstate",
			"region":         os.Getenv("BACKEND_REGION"),
			"dynamodb_table": os.Getenv("BACKEND_DYNAMODB_TABLE"),
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	bucketNames := terraform.OutputList(t, terraformOptions, "s3_bucket_id")
	for _, bucket := range bucketNames {
		fmt.Printf("Looking at %s\n", bucket)
		require.Contains(t, bucket, nameSuffix)
	}
}

func getAWSPartition(region string) string {
	partition := endpoints.AwsPartition()

	return partition.ID()
}

func generateNameSuffix() string {
	chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	length := 4

	b := make([]byte, length)
	rand.Read(b)

	for i := 0; i < length; i++ {
		b[i] = chars[int(b[i])%len(chars)]
	}

	return fmt.Sprintf("-%s", strings.ToLower(string(b)))
}
