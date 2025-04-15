resource "aws_internet_gateway" "secops-reptool-vpc-igw" {
  vpc_id = "${aws_vpc.secops-reptool-vpc.id}"

  tags {
    Name = "secops-reptool-vpc-igw"
  }
}
