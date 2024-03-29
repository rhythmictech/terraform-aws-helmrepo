########################################
# General Vars
########################################

variable "allowed_account_ids" {
  default     = []
  description = "List of AWS account IDs to grant read-only access to the repo. Due to how policies are constructed, there's effectively a limit of about 9 accounts."
  type        = list(string)
}

variable "allowed_account_ids_write" {
  default     = []
  description = "List of AWS account IDs to grant write access to the repo. Due to how policies are constructed, there's effectively a limit of about 9 accounts."
  type        = list(string)
}
variable "dest_extra_bucket_policy" {
  default     = ""
  description = "Extra bucket policies to attach to the destination bucket. Pass in as aws_iam_policy_document json"
  type        = string
}

variable "dest_logging_bucket" {
  default     = null
  description = "S3 bucket name to log bucket access requests to (optional)"
  type        = string
}

variable "dest_logging_bucket_prefix" {
  default     = null
  description = "S3 bucket prefix to log bucket access requests to (optional). If blank but a `logging_bucket` is specified, this will be set to the name of the bucket"
  type        = string
}

variable "dest_region" {
  default     = ""
  description = "Region to replicate repo bucket to (omit to disable replication)"
  type        = string
}
variable "logging_bucket" {
  default     = null
  description = "S3 bucket name to log bucket access requests to (optional)"
  type        = string
}

variable "logging_bucket_prefix" {
  default     = null
  description = "S3 bucket prefix to log bucket access requests to (optional). If blank but a `logging_bucket` is specified, this will be set to the name of the bucket"
  type        = string
}

variable "name" {
  default     = null
  description = "Bucket name for the helm repo. Specify to control the exact name of the bucket, otherwise use `name_suffix`"
  type        = string
}

variable "name_suffix" {
  default     = "helmrepo"
  description = "Bucket suffix for the repo (bucket will be named `[ACCOUNT_ID]-[REGION]-[name_suffix]`, not used if `name` is specified)"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to add to supported resources"
  type        = map(string)
}
