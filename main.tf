provider "aws" {
  alias  = "destination"
  region = var.dest_region
}

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

  dest_logging_map = var.dest_logging_bucket == null ? [] : [{
    bucket = var.dest_logging_bucket
    prefix = var.dest_logging_bucket_prefix != null ? var.dest_logging_bucket_prefix : "${local.bucket_name}-replica"
  }]
}

# This bucket uses a dynamic block to generate logging. If users do not wish to log,
# that's on them, but the module supports it.
#tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-encryption-customer-key
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

  depends_on = [
    aws_s3_bucket.this,
    aws_s3_bucket_policy.this
  ]
}

data "aws_iam_policy_document" "this" {
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
    # Remove accounts with write access from this statement to keep policy size down
    for_each = setsubtract(var.allowed_account_ids, var.allowed_account_ids_write)

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

  dynamic "statement" {
    for_each = var.allowed_account_ids_write

    content {
      sid = "Allow Cross-account write access (${statement.value})"
      actions = [
        "s3:GetObject*",
        "s3:PutObject*"
      ]
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

########################################
# Source replication configuration
########################################
resource "aws_s3_bucket_replication_configuration" "this" {
  count = var.dest_region != "" ? 1 : 0

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.this.id

  rule {
    id       = random_id.replication[0].b64_std
    priority = 0

    delete_marker_replication {
      status = "Enabled"
    }

    filter {
      prefix = ""
    }

    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.destination[0].arn
    }
  }
}

########################################
# Replicated bucket
########################################
#tfsec:ignore:AWS002
resource "aws_s3_bucket" "destination" {
  count    = var.dest_region != "" ? 1 : 0
  provider = aws.destination

  bucket = "${local.bucket_name}-replica"
  acl    = "private"
  tags   = var.tags

  dynamic "logging" {
    for_each = local.dest_logging_map

    content {
      target_bucket = logging.value.bucket
      target_prefix = logging.value.prefix
    }
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

resource "aws_s3_bucket_public_access_block" "dest_block_public_access" {
  count    = var.dest_region != "" ? 1 : 0
  provider = aws.destination

  bucket                  = aws_s3_bucket.destination[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "destination" {
  count    = var.dest_region != "" ? 1 : 0
  provider = aws.destination
  dynamic "statement" {
    for_each = var.allowed_account_ids

    content {

      sid       = "Allow cross-account access to list objects (${statement.value})"
      actions   = ["s3:ListBucket"]
      effect    = "Allow"
      resources = [aws_s3_bucket.destination[0].arn]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }
    }
  }

  dynamic "statement" {
    # Remove accounts with write access from this statement to keep policy size down
    for_each = setsubtract(var.allowed_account_ids, var.allowed_account_ids_write)

    content {
      sid       = "Allow Cross-account read-only access (${statement.value})"
      actions   = ["s3:GetObject*"]
      effect    = "Allow"
      resources = ["${aws_s3_bucket.destination[0].arn}/*"]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }
    }
  }

  dynamic "statement" {
    for_each = var.allowed_account_ids_write

    content {
      sid = "Allow Cross-account write access (${statement.value})"
      actions = [
        "s3:GetObject*",
        "s3:PutObject*"
      ]
      effect    = "Allow"
      resources = ["${aws_s3_bucket.destination[0].arn}/*"]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }
    }
  }
}

data "aws_iam_policy_document" "destination_combined" {
  count    = var.dest_region != "" ? 1 : 0
  provider = aws.destination
  source_policy_documents = [
    data.aws_iam_policy_document.destination[0].json,
    var.dest_extra_bucket_policy,
  ]
}

resource "aws_s3_bucket_policy" "destination" {
  count    = var.dest_region != "" ? 1 : 0
  provider = aws.destination

  bucket = aws_s3_bucket.destination[0].id
  policy = data.aws_iam_policy_document.destination_combined[0].json
}
