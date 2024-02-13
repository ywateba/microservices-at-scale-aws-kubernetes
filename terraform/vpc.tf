# Create a Virtual Private Cloud (VPC) with DNS hostname support enabled.
# This acts as the virtual network environment for your AWS resources.
resource "aws_vpc" "uda_vpc" {
  cidr_block           = "10.0.0.0/16" # Specifies the IP address range for the VPC.
  enable_dns_hostnames = true         # Enables instances in the VPC to receive DNS hostnames.

  tags = {
    Name = "my-vpc" # Tags the VPC with a name for identification.
  }
}

# Create an Internet Gateway and attach it to the VPC.
# This allows communication between resources in your VPC and the internet.
resource "aws_internet_gateway" "uda_igw" {
  vpc_id = aws_vpc.uda_vpc.id # Associates the internet gateway with the VPC.

  tags = {
    Name = "my-internet-gateway" # Tags the Internet Gateway for identification.
  }
}

# Retrieve a list of available Availability Zones (AZs) within the region for the account.
# This data source is used to distribute resources across different AZs.
data "aws_availability_zones" "uda_azs" {
  state = "available" # Filters the AZs to only include those that are available.
}

# Create the first public subnet within the VPC.
# Public subnets have routes to the Internet Gateway, enabling outbound internet access.
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.uda_vpc.id # Associates the subnet with the VPC.
  cidr_block              = "10.0.1.0/24" # Defines the subnet's IP address range.
  map_public_ip_on_launch = true # Automatically assigns public IP addresses to instances launched in this subnet.
  availability_zone       = data.aws_availability_zones.uda_azs.names[0] # Specifies the AZ for the subnet.

  tags = {
    Name = "public-subnet-1" # Tags the subnet for identification.
  }
}

# Create the second public subnet in a different Availability Zone for high availability.
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.uda_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.uda_azs.names[1]

  tags = {
    Name = "public-subnet-2"
  }
}

# Create the third public subnet in another Availability Zone to further ensure high availability.
resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.uda_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.uda_azs.names[2]

  tags = {
    Name = "public-subnet-3"
  }
}

# Create a route table for the public subnets.
# This includes a default route to the Internet Gateway, allowing outbound internet access.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.uda_vpc.id # Associates the route table with the VPC.

  route {
    cidr_block = "0.0.0.0/0" # Represents all IP addresses (internet).
    gateway_id = aws_internet_gateway.uda_igw.id # Specifies the Internet Gateway as the target for internet-bound traffic.
  }

  tags = {
    Name = "public-route-table" # Tags the route table for identification.
  }
}

# Associate each of the public subnets with the public route table.
# This enables instances in these subnets to use the route table's routes for internet access.
resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rta_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id
}
