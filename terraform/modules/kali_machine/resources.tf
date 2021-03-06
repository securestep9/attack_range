
data "aws_ami" "latest-kali-linux" {
  count = var.config.kali_machine == "1" ? 1 : 0
  most_recent = true
  owners = ["679593333241"] # owned by AWS marketplace

  filter {
      name   = "name"
      values = ["Kali Linux 2020*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

resource "aws_instance" "kali_machine" {
  count = var.config.kali_machine == "1" ? 1 : 0
  ami           = data.aws_ami.latest-kali-linux[count.index].id
  instance_type = "t2.medium"
  key_name = var.config.key_name
  subnet_id = var.ec2_subnet_id
  vpc_security_group_ids = [var.vpc_security_group_ids]
  private_ip = var.config.kali_machine_private_ip
  tags = {
    Name = "attack-range-kali_machine"
  }

  provisioner "remote-exec" {
    inline = ["echo booted"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = aws_instance.kali_machine[count.index].public_ip
      private_key = file(var.config.private_key_path)
    }
  }

}

resource "aws_eip" "kali_ip" {
  count = var.config.kali_machine == "1" ? 1 : 0
  instance      = aws_instance.kali_machine[0].id
}
