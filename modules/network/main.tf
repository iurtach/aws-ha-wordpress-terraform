resource "aws_acm_certificate" "cert" {
  domain_name = var.domain_name
  validation_method = "DNS"
}

resource "aws_lb" "alb" {
  name = "wp-alb"
  load_balancer_type = "application"
  subnets = var.public_subnet_ids
  security_groups = [var.alb_sg_id]
}

resource "aws_lb_target_group" "tg" {
  name = "wp-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  health_check { path = "/wp-admin/install.php" } # Check if WordPress is up
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.cert.arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
 }
}

data "aws_route53_zone" "zone" {
 name = var.domain_name
 }

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name = var.domain_name
  type = "A"
  alias {
     name = aws_lb.alb.dns_name
     zone_id = aws_lb.alb.zone_id
     evaluate_target_health = true
 }
}
