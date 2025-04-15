resource "aws_instance" "secops-reptool-dmz-jump-01" {
    ami = "ami-941e04f0"
    instance_type = "m4.large"
    subnet_id = "${aws_subnet.secops-reptool-dmz.id}"
    associate_public_ip_address = "true"
    key_name = "secops-reptool-deployer-key"
    vpc_security_group_ids = ["${aws_security_group.secops-reptool-dmz-jump-01-sg.id}"]
    tags {
      Name = "secops-reptool-dmz-jump-01"
    }
}

resource "aws_instance" "secops-reptool-dmz-gateway-01" {
    ami = "ami-941e04f0"
    instance_type = "m4.large"
    subnet_id = "${aws_subnet.secops-reptool-dmz.id}"
    associate_public_ip_address = "true"
    key_name = "secops-reptool-deployer-key"
    vpc_security_group_ids = ["${aws_security_group.secops-reptool-dmz-gateway-01-sg.id}"]
    tags {
      Name = "secops-reptool-dmz-gateway-01"
    }
}

resource "aws_instance" "secops-reptool-prod-app-01" {
    ami = "ami-941e04f0"
    instance_type = "c4.xlarge"
    subnet_id = "${aws_subnet.secops-reptool-prod.id}"
    key_name = "secops-reptool-deployer-key"
    vpc_security_group_ids = ["${aws_security_group.secops-reptool-prod-app-01-sg.id}"]
    tags {
      Name = "secops-reptool-prod-app-01"
    }
    root_block_device {
      volume_size = 50
    }
}
