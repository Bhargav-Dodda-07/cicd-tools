resource "aws_instance" "jenkins" {
  ami           = local.ami_id
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id = "subnet-030e221202289ab5d"

  root_block_device {
    volume_size = 50 # Set your new total size here
    volume_type = "gp3"
  }

  user_data = file("jenkins.sh")

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-jenkins"
    }
  )
}

resource "aws_instance" "jenkins_agent" {
  ami           = local.ami_id
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id = "subnet-030e221202289ab5d"

  root_block_device {
    volume_size = 50 # Set your new total size here
    volume_type = "gp3"
  }

  user_data = file("jenkins-agent.sh")

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-jenkins-agent"
    }
  )
}

resource "aws_security_group" "main" {
  name        = "${var.project_name}-${var.environment}-jenkins"
  description = "Created to attach Jenkins and its agents"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-jenkins"
    }
  )
}

resource "aws_route53_record" "jenkins" {
  zone_id = var.zone_id
  name    = "jenkins.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.jenkins.public_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "jenkins-agent" {
  zone_id = var.zone_id
  name    = "jenkins-agent.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.jenkins_agent.private_ip]
  allow_overwrite = true
}