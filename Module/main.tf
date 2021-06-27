locals {
  has_whitelist = length(var.whitelist) > 0 ? true : false
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-bucket"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_iam_user" "bucket_user" {
  name = "${var.bucket_name}-s3-user"
}

resource "aws_iam_user_policy" "bucket_user_access_policy" {
  name   = "${aws_iam_user.bucket_user.name}-s3-policy"
  user   = aws_iam_user.bucket_user.name
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_iam_access_key" "bucket_user_access_key" {
  user = aws_iam_user.bucket_user.name
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = ["s3:*"]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      "${aws_s3_bucket.bucket.arn}/",
    ]
  }
}

data "aws_iam_policy_document" "whitelist_policy" {
  statement {
    sid    = "VPNReadGetObject"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.whitelist
      }
  }
}

resource "aws_s3_bucket_policy" "whitelist_policy" {
  count = local.has_whitelist ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.whitelist_policy.json
}
