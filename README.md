## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.19 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |
| aws.destination | >= 4.0 |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_account\_ids | List of AWS account IDs to grant read-only access to the repo. Due to how policies are constructed, there's effectively a limit of about 9 accounts. | `list(string)` | `[]` | no |
| allowed\_account\_ids\_write | List of AWS account IDs to grant write access to the repo. Due to how policies are constructed, there's effectively a limit of about 9 accounts. | `list(string)` | `[]` | no |
| dest\_region | Region to replicate repo bucket to | `string` | `""` | no |
| logging\_bucket | S3 bucket name to log bucket access requests to (optional) | `string` | `null` | no |
| logging\_bucket\_prefix | S3 bucket prefix to log bucket access requests to (optional). If blank but a `logging_bucket` is specified, this will be set to the name of the bucket | `string` | `null` | no |
| name | Bucket name for the helm repo. Specify to control the exact name of the bucket, otherwise use `name_suffix` | `string` | `null` | no |
| name\_suffix | Bucket suffix for the repo (bucket will be named `[ACCOUNT_ID]-[REGION]-[name_suffix]`, not used if `name` is specified) | `string` | `"helmrepo"` | no |
| tags | Tags to add to supported resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket | Bucket name of the repo |

