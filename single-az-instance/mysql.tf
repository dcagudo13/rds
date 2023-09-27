resource "aws_rds_cluster" "test_ido" {
  cluster_identifier      = "testido-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.2"
  db_subnet_group_name    = aws_db_subnet_group.ido_db.name
  database_name           = "testido"
  master_username         = local.db_creds.username
  master_password         = local.db_creds.password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.allow_mysql.id]

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery",
  ]

  lifecycle {
    create_before_destroy = true
    # ignore_changes = [
    #   engine_version,
    # ]
  }
}

resource "aws_rds_cluster_instance" "test_ido_instance" {

  identifier           = "testido"
  cluster_identifier   = aws_rds_cluster.test_ido.cluster_identifier
  instance_class       = "db.t2.micro" # changed instance class from db.r5.large to reduce cost for this POC
  db_subnet_group_name = aws_db_subnet_group.ido_db.name
  publicly_accessible  = false
  engine_version       = aws_rds_cluster.test_ido.engine_version
  engine               = "aurora-mysql"


  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_db_subnet_group" "ido_db" {
  name       = "main"
  subnet_ids = [data.aws_subnet.subnet_id_a.id, data.aws_subnet.subnet_id_b.id]
}

# secret has been created manually instead
# resource "aws_secretsmanager_secret" "ido_secret" {
#   name = "ido_cred"
# }

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = "ido_cred"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.secret.secret_string
  )
}

# simplified the security group
resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow allow_mysql inbound traffic"
  vpc_id      = data.aws_vpc.vpc_id.id

  tags = {
    Name = "allow_mysql"
  }
}

resource "aws_ssm_parameter" "ido_connect_endpoint" {
  name  = "ido_connect_endpoint"
  type  = "String"
  value = aws_rds_cluster.test_ido.endpoint
}

resource "aws_ssm_parameter" "ido_connect_host" {
  name  = "ido_connect_host"
  type  = "String"
  value = aws_rds_cluster.test_ido.endpoint
}

resource "aws_ssm_parameter" "ido_connect_port" {
  name  = "ido_connect_port"
  type  = "String"
  value = aws_rds_cluster.test_ido.port
}