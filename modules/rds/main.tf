resource "random_password" "pass" {
 length = 16
 special = true
 }

resource "aws_secretsmanager_secret" "db_secret" { 
  name = "wp-db-pass"
  recovery_window_in_days = 0  # Allows immediate deletion/recreation if needed
}

resource "aws_secretsmanager_secret_version" "v" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({ username = "admin", password = random_password.pass.result })
}

resource "aws_db_subnet_group" "rds" {
 name = "wp-rds"
 subnet_ids = var.private_subnet_ids
 }

resource "aws_db_instance" "wp_db" {
  identifier = "wp-mysql"
  engine = "mysql"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  multi_az = true
  db_name = "wordpress"
  username = "admin"
  password = random_password.pass.result
  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [var.db_sg_id]
  backup_retention_period = 3
  skip_final_snapshot = true
}
