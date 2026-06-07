terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" { 
    region = "us-east-1" 
}

# 1. Bloco destinado à criação da VPC conforme requisito: CIDR 10.0.0.0/16 e Nome vpc-lab)
resource "aws_vpc" "vpc_lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-lab"
  }
}

# 2. Bloco destinado à criação da SUB-REDE /24 conforme requisito: CIDR 10.0.1.0/24 e IP Público de forma automática.
resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.vpc_lab.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-lab-publica"
  }
}

# 3. Bloco destinado à criação e anexação do INTERNET GATEWAY.
resource "aws_internet_gateway" "igw_lab" {
  vpc_id = aws_vpc.vpc_lab.id

  tags = {
    Name = "igw-lab"
  }
}

# 4. Bloco destinado à configurar a tabela de rotas conforme requisito requisito: rota 0.0.0.0/0 para o IGW. 
resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.vpc_lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_lab.id
  }

  tags = {
    Name = "rt-lab-publica"
  }
}
# 4.1 Também foi feita a associação da tabela de rotas à sub-rede criada no passo 2.
resource "aws_route_table_association" "associacao_publica" {
  subnet_id      = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.rt_publica.id
}

# 5. Bloco destinado à criação do SECURITY GROUP conforme requisito: SSH/Porta 22 apenas para o meu IP
resource "aws_security_group" "sg_ssh" {
  name        = "sg_permitir_ssh"
  description = "Permite acesso SSH apenas do meu IP"
  vpc_id      = aws_vpc.vpc_lab.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["181.191.169.232/32"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-lab-ssh"
  }
}

# 6. Bloco destinado à criação da INSTÂNCIA EC2 conforme requisito: AMI: Amazon Linux 2, e com a instância t2.micro.
resource "aws_instance" "servidor_lab" {
  ami                    = "ami-026992d753d5622bc" 
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_publica.id
  vpc_security_group_ids = [aws_security_group.sg_ssh.id]
  key_name               = "iRedelabPSC" 

  tags = {
    Name = "Servidor-Lab"
  }
}

# 7. Bloco destinado ao output do IP PÚBLICO
output "ip_publico" {
  value       = aws_instance.servidor_lab.public_ip
  description = "Utilize este IP para realizar o comando de acesso SSH no terminal"
}
