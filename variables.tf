########################################
# General Vars
########################################
variable "allow_cross_account_write" {
  default     = false
  description = "Allow write access to helm repo from `allowed_account_ids`"
  type        = bool
}

variable "allowed_account_ids" {
  default     = []
  description = "List of AWS account IDs to grant read-only access to the repo. Due to how policies are constructed, there's effectively a limit of about 9 accounts."
  type        = list(string)
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
