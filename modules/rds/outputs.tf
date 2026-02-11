output "db_endpoint" { value = aws_db_instance.wp_db.address }
output "db_id"       { value = aws_db_instance.wp_db.identifier }
output "secret_arn"  { value = aws_secretsmanager_secret.db_secret.arn }
