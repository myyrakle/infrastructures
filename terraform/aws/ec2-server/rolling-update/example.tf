locals {
    default_vpc_id = "vpc-..." # default VPC ID
    public_subnet_ids = [
      "subnet-...", // us-east-1a
      "subnet-..."  // us-east-1b
    ]
    private_subnet_ids = [
      "subnet-...", // us-east-1a
      "subnet-..."  // us-east-1b
    ]
    key_name = "...-key"

    office_ip = "?/32"
}

module "something_server" {
  source = "./modules"

  environment = "prod"
  service_name = "something-server" # 서비스 이름
  region   = "us-east-1" # 버지니아

  # 다음 변수들은 실제 환경에 맞게 값을 설정해야 합니다.
  # terraform.tfvars 파일을 사용하거나, CI/CD 파이프라인에서 변수를 주입하는 것을 권장합니다.
  key_name                 = local.key_name
  vpc_id                   = local.default_vpc_id
  public_subnet_ids        = local.public_subnet_ids
  private_subnet_ids       = local.private_subnet_ids
  ec2_security_group_ids   = ["..."] # EC2 보안 그룹 ID

  instance_type           = "t3.micro"
  desired_capacity        = 0
  min_size                = 1 # 최소 1개 인스턴스
  max_size                = 2 # 최대 2개 인스턴스

  health_check_path       = "/"
  health_check_port       = "80"
  log_retention_in_days   = 7
  # ami_id                  = "ami-0a91cd9eb650de472" # Ubuntu 22.04 LTS (Seoul)
}