resource "aws_globalaccelerator_accelerator" "ga" {
  name = "${var.app_name}-ga"
  enabled = true
  ip_address_type = "IPV4"
}

resource "aws_globalaccelerator_listener" "https" {
  accelerator_arn = aws_globalaccelerator_accelerator.ga.id
  protocol = "TCP"
  port_range { from_port = 443 to_port = 443 }
}

# Primary endpoint group (eu-central-1)
resource "aws_globalaccelerator_endpoint_group" "primary" {
  listener_arn = aws_globalaccelerator_listener.https.id
  endpoint_group_region = var.region
  health_check_protocol = "TCP"
  health_check_port = 443

  endpoint_configuration {
    endpoint_id = aws_lb.alb.arn
    weight = 128
  }
}
