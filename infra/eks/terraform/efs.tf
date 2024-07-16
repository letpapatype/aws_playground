module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.6.3"

  # File system
  name           = "${var.cluster_name}-efs"
  creation_token = "${var.cluster_name}-efs-token"
  encrypted      = true
  kms_key_arn    = module.eks.kms_key_arn

  # performance_mode                = "maxIO"
  # NB! PROVISIONED TROUGHPUT MODE WITH 256 MIBPS IS EXPENSIVE ~$1500/month
  # throughput_mode                 = "provisioned"
  # provisioned_throughput_in_mibps = 256

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false

  security_group_name        = "${var.cluster_name}-efs-sg"
  security_group_description = "${var.cluster_name} EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
    }
  }

  # Access point(s)
  access_points = {
    posix_example = {
      name = "posix-example"
      posix_user = {
        gid            = 1001
        uid            = 1001
        secondary_gids = [1002]
      }

      tags = {
        Additionl = "yes"
      }
    }
    root_example = {
      root_directory = {
        path = "/jenkins"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }


  }

  # Backup policy
  enable_backup_policy = true

  # Replication configuration
  create_replication_configuration = true
  replication_configuration_destination = {
    region = "eu-west-2"
  }

  tags = {
    Created_By   = "${local.tags.created-by}"
    Environment  = "${local.tags.env}"
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = { for subnet_id in module.vpc.private_subnets : subnet_id => subnet_id }

  depends_on = [module.efs, module.vpc]

  file_system_id = module.efs.id
  subnet_id      = each.value
  // Add other necessary attributes here
  security_groups = [module.vpc.default_security_group_id,module.eks.cluster_primary_security_group_id]

}

output "efs_id" {
  value = module.efs.id
}

// TODO: #2 Ensure eks node security groups make it to the efs mount targets