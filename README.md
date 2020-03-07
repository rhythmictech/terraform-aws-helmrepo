# terraform-aws-helmrepo

Create an S3 bucket intended to serve as a Helm repo. Configures basic encryption.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Prefix name for the helm repo \(e.g., EKS cluster name\) | string | `"default"` | no |
| tags | Tags to add to supported resources | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket\_repo |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
