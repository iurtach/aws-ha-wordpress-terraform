resource "aws_iam_role" "role" {
  name = "wp-role"
  assume_role_policy = jsonencode({
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "p" {
  role = aws_iam_role.role.id
  policy = jsonencode({
    Statement = [
      { Action = "secretsmanager:GetSecretValue", Effect = "Allow", Resource = "${var.db_secret_arn}*" },
      { Action = ["elasticfilesystem:*"], Effect = "Allow", Resource = "*" }
    ]
  })
}

resource "aws_iam_instance_profile" "prof" {
 name = "wp-prof"
 role = aws_iam_role.role.name
 }

resource "aws_launch_template" "lt" {
  name_prefix = "wp-lt"
  image_id = "ami-0bae57ee7c4478e01"
  instance_type = "t2.micro"
  iam_instance_profile { name = aws_iam_instance_profile.prof.name }
  network_interfaces { security_groups = [var.app_sg_id] }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    efs_id      = var.efs_id,
    rds_endpoint = var.db_endpoint,
    secret_arn  = var.db_secret_arn,
    region      = var.region
  }))
}

resource "aws_autoscaling_group" "asg" {
  max_size = 4
  min_size = 2
  desired_capacity = 2
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns = [var.tg_arn]
  launch_template {
     id = aws_launch_template.lt.id
     version = "$Latest"
 }
}
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}