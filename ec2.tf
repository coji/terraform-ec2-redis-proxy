############################################################
### EC2 
############################################################
# 最新版のAmazonLinux2のAMI情報
data "aws_ami" "tf_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

# user data
data "template_file" "ec2-redis-proxy-ec2-user_data" {
  template = file("./user_data.sh.tpl")
}

# Redis Proxyサーバー
resource "aws_instance" "ec2-redis-proxy" {
  ami                    = data.aws_ami.tf_ami.image_id
  instance_type          = "t2.nano"
  subnet_id              = aws_subnet.ec2-redis-proxy-pub-subnet.id
  vpc_security_group_ids = [aws_security_group.ec2-redis-proxy-pub-sg.id]
  key_name               = aws_key_pair.coji-key.key_name
  user_data              = element(data.template_file.ec2-redis-proxy-ec2-user_data.*.rendered, 0)
  tags = {
    Name = "ec2-redis-proxy"
  }
}

# ssh key pair
resource "aws_key_pair" "coji-key" {
  key_name   = "coji-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJWmv1WUYIwDMCIEyVsNMMKpABUN3yXLbCKWPQzUzZdkBPUCh6JNMa3N2+B1vmfUCCHfSG3BDjePDBASQO+3WKPH5xM9v5k6Q9FqpQ3tR2kd3mrAV4y9vAv+cHtJo/CkBMy92DjE3LalBZK+Gqjzl9xXb5XJWkLQnjDRDrnqRbfUdWm21uplEfGMIPsOiizmRMp+28jRy2CYKEDwrlaq4pxTTfho95baLn0VuiD90Mw6Y2X3b3tW6+7o6z5NiLoluMxSNIi1T/UTQ8/DlU53xYS398S8WXZBjnNcc+FygG2Y4kRegtTRcT39wByzFqbwN/wHC/R4AR8QekZmtUw2vz coji@coji-air13.local"
}
