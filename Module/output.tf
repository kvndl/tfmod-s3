output "bucket_name" {
  value = aws_s3_bucket.service_bucket.id
}

output "bucket_access_key" {
  value = aws_iam_access_key.service_bucket_user_access_key.id
}

output "bucket_secret_key" {
  value = aws_iam_access_key.service_bucket_user_access_key.secret
}