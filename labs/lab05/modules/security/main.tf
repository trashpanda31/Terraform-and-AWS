resource "aws_security_group" "frontend" {
  name   = "lab05-frontend-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port        = var.frontend_port
    to_port          = var.frontend_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = { Name = "lab05-frontend-sg" }
}

resource "aws_security_group" "backend" {
  name   = "lab05-backend-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "lab05-backend-sg" }
}

