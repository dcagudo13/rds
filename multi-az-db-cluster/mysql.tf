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

  storage_type              = "io1"
  allocated_storage         = 100
  iops                      = 1000
  db_cluster_instance_class = "db.r5.large"

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

  # apply_immediately = true
}

resource "aws_rds_cluster_instance" "test_ido_instance" {
  count                = 3
  identifier           = "testido-${count.index}"
  cluster_identifier   = aws_rds_cluster.test_ido.cluster_identifier
  instance_class       = "db.r5.large"
  db_subnet_group_name = aws_db_subnet_group.ido_db.name
  publicly_accessible  = false
  engine_version       = aws_rds_cluster.test_ido.engine_version
  engine               = "aurora-mysql"

  performance_insights_enabled          = true
  performance_insights_retention_period = 7 # default
  
  monitoring_interval = 60 # interval in seconds
  monitoring_role_arn = aws_iam_role.em_access.arn

  lifecycle {
    create_before_destroy = true
  }

}

################################################################################
# Create an IAM role to allow enhanced monitoring
################################################################################

resource "aws_iam_role" "em_access" {
  name               = "em_access"
  assume_role_policy = data.aws_iam_policy_document.em_access.json
}

resource "aws_iam_role_policy_attachment" "em_access" {
  role       = aws_iam_role.em_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "em_access" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

################################################################################

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