resource "aws_efs_file_system" "fs" {
 creation_token = "wp-efs"
  encrypted = true
 }

resource "aws_efs_mount_target" "mt" {
  count = 2
  file_system_id = aws_efs_file_system.fs.id
  subnet_id = var.private_subnet_ids[count.index]
  security_groups = [var.efs_sg_id]
}
