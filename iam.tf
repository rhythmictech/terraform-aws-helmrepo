data "aws_iam_policy_document" "replication_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "replication" {
  count = "${var.dest_region != "" ? 1 : 0}"

  name_prefix        = "replication"
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "replication_policy_doc" {
  count = "${var.dest_region != "" ? 1 : 0}"
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.this.arn
    ]

  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]

    resources = [
      "${aws_s3_bucket.destination[0].arn}/*"
    ]

  }

}

resource "aws_iam_policy" "replication_policy" {
  count = "${var.dest_region != "" ? 1 : 0}"

  name_prefix = "replication-policy"
  policy      = data.aws_iam_policy_document.replication_policy_doc[0].json
}

resource "aws_iam_policy_attachment" "replication" {
  count = "${var.dest_region != "" ? 1 : 0}"

  name       = "replication"
  roles      = [aws_iam_role.replication[0].name]
  policy_arn = aws_iam_policy.replication_policy[0].arn
}

resource "random_id" "replication" {
  count       = "${var.dest_region != "" ? 1 : 0}"
  byte_length = 32
}