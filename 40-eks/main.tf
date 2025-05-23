resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCk0vk3Zhv8ZAjKMq42qbYS+NGKJB+YlyzAqbVy8Po89rdMDN7jvltXI1OkXBIvxvzCZU1TQhv5okJf6r7FebZognJSkP8iXKUu1Gx1YNC6PZsW9GhTOGWTS81pykapGMmFR/rv7rYP1rwvP9Ki2sLdCI7YCy2qdW2le6K7HPKtd3lPYbt3NlmTkbSQLH7kFGgTs00qb+kkjE+GqpAxlqvRMLjDElSk05X2+2qy+hXNbpz//4kFQNpWTDP7Gn7mLjaIDjK00ffg8tOS3Yo5WFsrAUYeQmY//bOenS1te76Wr87KdA2ImAo35IBQ6YJ4yaL8CT2MCVIuXZxbKoa0DDlOPFVnS54H0ho89ammsTkS4hZJy2XIPEJdkoZIvJxWD65Kyr/Vkm1W6vjcqzsss5w2ItMVYG83Xks+u9QO1Ur5QBSP/bhFO180z2GFuuvQbVz+M351xQ4mSGPy0vPjhM0aUfmEjOUz8ZJgeHQuF/YObvZBT3EuSLrkSNTxCGDDwc5zGfe04MUIO7Gg9BV9JJyy0YbWdLyl6nQe6txqESvTSVkY6DHm3OtXLu3nTG/jeOjA1tAuByK8T6TlJQzVQ0Op7zEJs4xH8oQQhPLEJu+zdj9vaW65zKhGFsBfkBaqR5rvQvUXb6GdRues+S00KOVm4n6kPzi0kFKH1kwjQOXNzw== gompa@Charumathi"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.31" # later we upgrade 1.32
  create_node_security_group = false
  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id
  node_security_group_id = local.eks_node_sg_id

  #bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server = {}
  }

  # Optional
  cluster_endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
}