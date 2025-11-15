# EC2 Instances

# EC2 Instance A in AZ-1
resource "aws_instance" "instance_a" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = templatefile("${path.module}/user-data.sh", {
    instance_name = "A"
  })

  user_data_replace_on_change = true

  tags = {
    Name    = "${var.project_name}-instance-a"
    Project = var.project_name
    AZ      = var.availability_zones[0]
  }
}

# EC2 Instance B in AZ-2
resource "aws_instance" "instance_b" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = templatefile("${path.module}/user-data.sh", {
    instance_name = "B"
  })

  user_data_replace_on_change = true

  tags = {
    Name    = "${var.project_name}-instance-b"
    Project = var.project_name
    AZ      = var.availability_zones[1]
  }
}
