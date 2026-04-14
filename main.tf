
terraform {
  backend "s3" {
    bucket = "jenkins-bucket-20260324020327285500000001"
    key    = "deliverables/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# =============================================================================
# Class 7 G-Check Deliverables — S3 Upload
# Creates a public S3 bucket and uploads all screenshot deliverables
# =============================================================================

resource "aws_s3_bucket" "deliverables" {
  bucket_prefix = "gutcheck-class7"
  force_destroy = true

  tags = {
    Name    = "gutcheck-class7-deliverables"
    Purpose = "Gutcheck submission deliverables"
  }
}

# Allow public access
resource "aws_s3_bucket_ownership_controls" "deliverables" {
  bucket = aws_s3_bucket.deliverables.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "deliverables" {
  bucket = aws_s3_bucket.deliverables.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "deliverables" {
  bucket = aws_s3_bucket.deliverables.id

  depends_on = [aws_s3_bucket_public_access_block.deliverables]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.deliverables.arn}/*"
    }]
  })
}

#=============================================================================
#Upload screenshots
#============================================================================

resource "aws_s3_object" "webhook_trigger" {
  bucket       = aws_s3_bucket.deliverables.id
  key          = "screenshots/01-webhook-trigger.jpg"
  source       = "${path.module}/deliverables/01-webhook-trigger.jpg"
  content_type = "image/jpg"
}

resource "aws_s3_object" "tf_success" {
  bucket       = aws_s3_bucket.deliverables.id
  key          = "screenshots/02-theo-approval.jpg"
  source       = "${path.module}/deliverables/02-theo-approval.jpg"
  content_type = "image/jpg"
}

resource "aws_s3_object" "stage_view" {
  bucket       = aws_s3_bucket.deliverables.id
  key          = "screenshots/03-stage-view.jpg"
  source       = "${path.module}/deliverables/03-stage-view.jpg"
  content_type = "image/jpg"
}

resource "aws_s3_object" "theo_approval" {
  bucket       = aws_s3_bucket.deliverables.id
  key          = "screenshots/04-terraform-success.jpg"
  source       = "${path.module}/deliverables/04-theo-approval.jpg"
  content_type = "image/jpg"
}

resource "aws_s3_object" "bucket_files" {
  bucket       = aws_s3_bucket.deliverables.id
  key          = "screenshots/05-bucket-files.png"
  source       = "${path.module}/deliverables/05-bucket-files.png"
  content_type = "image/png"
}

resource "aws_s3_object" "readme" {
  bucket       = aws_s3_bucket.deliverables.id
  key          = "README.md"
  content_type = "text/markdown"
  #acl          = "public-read"

  content = <<-EOF
    # Class 7 G-Check Deliverables!
    

    ## Repo
    https://github.com/Velma098/Gutcheck-Class7

    ## Evidence
    | Requirement | File |
    |---|---|
    | Working webhook trigger | screenshots/01-webhook-trigger.png |
    | Successful Terraform deployment via Jenkins | screenshots/02-terraform-success.png |
    | Jenkins stage view | screenshots/03-stage-view.png |
    | Theo approval | screenshots/04-theo-approval.png |
  EOF
}

#=============================================================================
#Outputs — public URLs for each deliverable
#=============================================================================

output "deliverables_bucket" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.deliverables.id
}

output "webhook_trigger_url" {
  description = "Public URL - webhook trigger screenshot"
  value       = "https://${aws_s3_bucket.deliverables.bucket_regional_domain_name}/screenshots/01-webhook-trigger.png"
}

output "tf_success_url" {
  description = "Public URL - Terraform success screenshot"
  value       = "https://${aws_s3_bucket.deliverables.bucket_regional_domain_name}/screenshots/02-terraform-success.png"
}

output "stage_view_url" {
  description = "Public URL - stage view screenshot"
  value       = "https://${aws_s3_bucket.deliverables.bucket_regional_domain_name}/screenshots/03-stage-view.png"
}

output "theo_approval_url" {
  description = "Public URL - Theo approval screenshot"
  value       = "https://${aws_s3_bucket.deliverables.bucket_regional_domain_name}/screenshots/04-theo-approval.png"
}

output "readme_url" {
  description = "Public URL - README"
  value       = "https://${aws_s3_bucket.deliverables.bucket_regional_domain_name}/README.md"
}