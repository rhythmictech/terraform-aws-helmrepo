# terraform-aws-helmrepo

[![tflint](https://github.com/rhythmictech/terraform-aws-helmrepo/workflows/tflint/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-aws-helmrepo/actions?query=workflow%3Atflint+event%3Apush+branch%3Amain)
[![tfsec](https://github.com/rhythmictech/terraform-aws-helmrepo/workflows/tfsec/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-aws-helmrepo/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amain)
[![yamllint](https://github.com/rhythmictech/terraform-aws-helmrepo/workflows/yamllint/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-aws-helmrepo/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amain)
[![misspell](https://github.com/rhythmictech/terraform-aws-helmrepo/workflows/misspell/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-aws-helmrepo/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amain)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-helmrepo/workflows/pre-commit-check/badge.svg?branch=main&event=push)](https://github.com/rhythmictech/terraform-aws-helmrepo/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amain)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=RhythmicTech" alt="follow on Twitter"></a>

Create an S3 bucket intended to serve as a Helm repo. Configures basic encryption and supports sharing the bucket across many accounts.

## Usage
```
module {
    source = "rhythmictech/helmrepo/aws"
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.19 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_account\_ids | List of AWS account IDs to grant read-only access to the repo. Due to how policies are constructed, there's effectively a limit of about 9 accounts. | `list(string)` | `[]` | no |
| logging\_bucket | S3 bucket name to log bucket access requests to (optional) | `string` | `null` | no |
| logging\_bucket\_prefix | S3 bucket prefix to log bucket access requests to (optional). If blank but a `logging_bucket` is specified, this will be set to the name of the bucket | `string` | `null` | no |
| name | Bucket name for the helm repo. Specify to control the exact name of the bucket, otherwise use `name_suffix` | `string` | `null` | no |
| name\_suffix | Bucket suffix for the repo (bucket will be named `[ACCOUNT_ID]-[REGION]-[name_suffix]`, not used if `name` is specified) | `string` | `"helmrepo"` | no |
| tags | Tags to add to supported resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket | Bucket name of the repo |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
