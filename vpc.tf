
############################################################
### ネットワーク 
############################################################
### VPC ####################
resource "aws_vpc" "ec2-redis-proxy-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ec2-redis-proxy-vpc"
  }
}

### サブネット ####################
# パブリックサブネット
resource "aws_subnet" "ec2-redis-proxy-pub-subnet" {
  vpc_id                  = aws_vpc.ec2-redis-proxy-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ec2-redis-proxy-pub-subnet"
  }
}

### Internet Gateway ####################
resource "aws_internet_gateway" "ec2-redis-proxy-igw" {
  vpc_id = aws_vpc.ec2-redis-proxy-vpc.id

  tags = {
    Name = "ed2-redis-proxy-igw"
  }
}

### Route Table ####################
resource "aws_route_table" "ec2-redis-proxy-route-table" {
  vpc_id = aws_vpc.ec2-redis-proxy-vpc.id

  tags = {
    Name = "ec2-redis-proxy-route-table"
  }
}

resource "aws_route" "ec2-redis-proxy-route" {
  gateway_id             = aws_internet_gateway.ec2-redis-proxy-igw.id
  route_table_id         = aws_route_table.ec2-redis-proxy-route-table.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "ec2-redis-proxy-route-table-association" {
  subnet_id      = aws_subnet.ec2-redis-proxy-pub-subnet.id
  route_table_id = aws_route_table.ec2-redis-proxy-route-table.id
}


############################################################
### セキュリティグループ 
############################################################
### publicセキュリティー ####################
resource "aws_security_group" "ec2-redis-proxy-pub-sg" {
  name   = "ec2-redis-pub-sg"
  vpc_id = aws_vpc.ec2-redis-proxy-vpc.id
  tags = {
    Name = "ec2-redis-proxy-pub-sg"
  }
}

# アウトバウンド(外に出る)ルール
resource "aws_security_group_rule" "ec2-redis-proxy-pub-sg-out-all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2-redis-proxy-pub-sg.id
}

# インバウンド(受け入れる)ルール redis proxy
resource "aws_security_group_rule" "ec2-redis-proxy-pub-sg-in-redis-proxy" {
  type              = "ingress"
  from_port         = 16379
  to_port           = 16379
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2-redis-proxy-pub-sg.id
}

resource "aws_security_group_rule" "ec2-redis-proxy-pub-sg-in-ssh-proxy" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2-redis-proxy-pub-sg.id
}
