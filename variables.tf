variable "name" {
  default = "default"
  description = "Prefix name for the helm repo (e.g., EKS cluster name)"
  type = string
}

variable "tags" {
  default = {}
  description = "Tags to add to supported resources"
  type    = map(string)
}
