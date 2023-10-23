resource "aws_vpc" "myvpc" {
  cidr_block =  = "10.0.0.0/24"
}

resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/16"
    availability_zone_id = "ap-south-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/16"
    availability_zone_id = "ap-south-1b"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
    route_table_id = aws_route_table.rt.id
    subnet_id =aws_subnet.sub1.id
}

resource "aws_route_table_association" "rta2" {
    route_table_id = aws_route_table.rt.id
    subnet_id =aws_subnet.sub2.id
}

resource "aws_security_group" "mysg" {
    vpc_id = aws_vpc.myvpc.id
    name = "web"

    ingress{
        description = "HTTP"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    ingress {
        description = "All-Traffic"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }
    
    egress{
        description = "All-Traffic"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

tags = {
  Name = "web-sg"
}
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "mybucketaws"
}

resource "aws_instance" "webserver1" {
    ami = "ami-0b41f7055516b991a"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mysg]
    subnet_id = aws_subnet.sub1.id
    user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
    ami = "ami-0b41f7055516b991a"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mysg]
    subnet_id = aws_subnet.sub2.id
    user_data = base64encode(file("userdata.sh"))
}


