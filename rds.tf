# Create a DB subnet group
resource "aws_db_subnet_group" "private" {
  name       = "private"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "private-db-subnet-group"
  }
}

# Create a security group for the RDS instance
resource "aws_security_group" "rds" {
  name        = "rds"
  description = "Allow inbound traffic to RDS MySQL instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.6.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds"
  }
}

# Create an RDS MySQL instance
resource "aws_db_instance" "mysql" {
  identifier_prefix  = "mysql"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t2.micro"
  allocated_storage  = 20
  storage_encrypted  = true
  multi_az           = true
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.private.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Replace these with your actual username and password
  username = "admin"
  password = "password"

  tags = {
    Name = "mysql"
  }
}
