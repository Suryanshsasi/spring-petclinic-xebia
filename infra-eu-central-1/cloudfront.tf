resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = "example.com"
    origin_id   = "exampleOrigin"
  }
  enabled = true
}
