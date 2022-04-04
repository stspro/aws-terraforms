locals{
  environment_type
  environment
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"
  acl = var.acl
  force_destroy = true
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
  dynamic "versioning" {
    content {
     enabled
      mfa_delete
    }
  }
  dynamic "logging" {
    content {
     target_bucket
     target_prefix
    }
  }
  dynamic "lifecycle_rule" {
    content {
     target_bucket
     target_prefix
    }
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}

resource "aws_s3_account_public_access_block" "example" {
  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.example.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.example.arn}/*",
    ]
  }
}
