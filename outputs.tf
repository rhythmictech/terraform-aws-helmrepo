output "s3_bucket" {
  description = "Bucket name of the repo"
  value       = aws_s3_bucket.this.bucket
}
