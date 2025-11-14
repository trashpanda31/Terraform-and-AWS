resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.sg_ids
  associate_public_ip_address = false
  iam_instance_profile        = var.instance_profile_name
  user_data                   = var.user_data
  user_data_replace_on_change = true

  tags = merge(
    { Name = var.name },
    var.tags
  )
}

resource "aws_eip" "this" {
  count  = var.allocate_eip ? 1 : 0
  domain = "vpc"
  tags   = { Name = "${var.name}-eip" }
}

resource "aws_eip_association" "this" {
  count         = var.allocate_eip ? 1 : 0
  allocation_id = aws_eip.this[0].id
  instance_id   = aws_instance.this.id
}
