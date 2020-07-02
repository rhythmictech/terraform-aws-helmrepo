data "aws_caller_identity" "current" {
}

data "aws_region" "region" {
}

locals {
  bucket_name = var.name != null ? var.name : "${data.aws_caller_identity.current.account_id}-${data.aws_region.region.name}-${var.name_suffix}"

  logging_map = var.logging_bucket == null ? [] : [{
    bucket = var.logging_bucket
    prefix = var.logging_bucket_prefix != null ? var.logging_bucket_prefix : local.bucket_name
  }]
}

# This bucket uses a dynamic block to generate logging. If users do not wish to log,
# that's on them, but the module supports it.
#tfsec:ignore:AWS002
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
  acl    = "private"
  tags   = var.tags

  dynamic "logging" {
    for_each = local.logging_map

    content {
      target_bucket = logging.value.bucket
      target_prefix = logging.value.prefix
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_s3_bucket.this]
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "DenyIncorrectEncryptionHeader"
    actions   = ["s3:PutObject*"]
    effect    = "Deny"
    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }

  statement {
    sid       = "DenyUnEncryptedObjectUploads"
    actions   = ["s3:PutObject*"]
    effect    = "Deny"
    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = [true]
    }

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }

  dynamic "statement" {
    for_each = var.allowed_account_ids

    content {

      sid       = "Allow cross-account access to list objects (${statement.value})"
      actions   = ["s3:ListBucket"]
      effect    = "Allow"
      resources = [aws_s3_bucket.this.arn]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }
    }
  }

  dynamic "statement" {
    for_each = var.allowed_account_ids

    content {
      sid       = "Allow Cross-account read-only access (${statement.value})"
      actions   = ["s3:GetObject*"]
      effect    = "Allow"
      resources = ["${aws_s3_bucket.this.arn}/*"]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}
