package test_test

import (
	"crypto/rand"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

const testDir = "../"

// Not including us-west-1 because the module we consume expects at least 3 AZs
// https://github.com/defenseunicorns/terraform-aws-uds-eks/blob/ef4865882ddef472e3eecf31829ec1f47b5f755c/locals.tf#L2
var approvedRegions = []string{"us-east-1", "us-east-2", "us-west-2"}

func TestEksModule(t *testing.T) {

	// We expect a region from CI.  If it's not there, get an approved one.
	awsRegion := os.Getenv("REGION")
	if awsRegion == "" {
		awsRegion = aws.GetRandomStableRegion(t, approvedRegions, nil)
	}

	vpcId := os.Getenv("VPC_ID")
	iamRolePermissionsBoundary := os.Getenv("IAM_ROLE_PERMISSIONS_BOUNDARY")
	clusterSubnets := os.Getenv("CLUSTER_SUBNETS")
	cidrBlocks := os.Getenv("CIDR_BLOCKS")
	clusterCniSubnets := os.Getenv("CLUSTER_CNI_SUBNETS")

	createTestResources := false
	if vpcId == "" || iamRolePermissionsBoundary == "" || clusterSubnets == "" || cidrBlocks == "" || clusterCniSubnets == "" {
		createTestResources = true
	}

	clusterName := generateClusterName()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testDir,
		Vars: map[string]interface{}{
			"region":                        awsRegion,
			"create_test_resources":         createTestResources,
			"cluster_name":                  clusterName,
			"vpc_id":                        vpcId,
			"iam_role_permissions_boundary": iamRolePermissionsBoundary,
			"cluster_subnets":               strings.Split(clusterSubnets, ","),
			"cluster_cni_subnets":           strings.Split(clusterCniSubnets, ","),
		},

		BackendConfig: map[string]interface{}{
			"bucket":         os.Getenv("BACKEND_BUCKET"),
			"key":            fmt.Sprintf("%s-terratest.tfstate", clusterName),
			"region":         os.Getenv("BACKEND_REGION"),
			"dynamodb_table": os.Getenv("BACKEND_DYNAMODB_TABLE"),
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	clusterStatus := terraform.Output(t, terraformOptions, "cluster_status")
	possibleStatus := []string{"CREATING", "ACTIVE"}
	require.Contains(t, possibleStatus, clusterStatus)
}

func generateClusterName() string {
	chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	length := 4

	b := make([]byte, length)
	rand.Read(b)

	for i := 0; i < length; i++ {
		b[i] = chars[int(b[i])%len(chars)]
	}

	return fmt.Sprintf("swf-cluster-%s", strings.ToLower(string(b)))
}
