package test_test

import (
	"crypto/rand"
	"fmt"
  "os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

const (
	awsRegionVar       = "region"
	cidrVar            = "cidr"
	expectedNamePrefix = "terratest-vpc"
	nameOutput         = "name"
	nameVar            = "name"
	testDir            = "../"
)

var approvedRegions = []string{"us-east-1", "us-east-2", "us-west-1", "us-west-2"}

func TestVPCModule(t *testing.T) {
	awsRegion := aws.GetRandomStableRegion(t, approvedRegions, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testDir,
		Vars: map[string]interface{}{
			awsRegionVar: awsRegion,
			cidrVar:      "10.0.0.0/16",
			nameVar:      generateVpcName(),
		},

		BackendConfig: map[string]interface{}{
			"bucket":         os.Getenv("BACKEND_BUCKET"),
			"key":            os.Getenv("BACKEND_KEY"),
			"region":         os.Getenv("BACKEND_REGION"),
			"dynamodb_table": os.Getenv("BACKEND_DYNAMODB_TABLE"),
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	actualName := terraform.Output(t, terraformOptions, nameOutput)
	require.Contains(t, actualName, expectedNamePrefix)
}

func generateVpcName() string {
	chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-"
	length := 4

	b := make([]byte, length)
	rand.Read(b)

	for i := 0; i < length; i++ {
		b[i] = chars[int(b[i])%len(chars)]
	}

	return fmt.Sprintf("%s-%s", expectedNamePrefix, string(b))
}
