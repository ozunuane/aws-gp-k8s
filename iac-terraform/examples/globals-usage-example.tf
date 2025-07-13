# Example: How to Use the Globals Module
# This shows the proper way to use global variables in your environments

# 1. Import the globals module in your environment's main.tf
module "globals" {
  source = "../globals"
}

# 2. Use the global variables in your modules
module "vpc" {
  source = "../modules/vpc"

  environment          = "dev"
  vpc_cidr             = module.globals.vpc_cidr_blocks["dev"]
  public_subnet_cidrs  = module.globals.public_subnet_cidrs["dev"]
  private_subnet_cidrs = module.globals.private_subnet_cidrs["dev"]
  enable_nat_gateway   = module.globals.enable_nat_gateway["dev"]
  enable_vpc_endpoints = module.globals.enable_vpc_endpoints["dev"]

  tags = merge(module.globals.common_tags, {
    Environment = "dev"
  })
}

module "eks" {
  source = "../modules/eks"

  environment               = "dev"
  kubernetes_version        = module.globals.kubernetes_versions["dev"]
  node_group_instance_types = module.globals.node_instance_types["dev"]
  node_group_min_size       = module.globals.node_scaling_config["dev"].min_size
  node_group_max_size       = module.globals.node_scaling_config["dev"].max_size
  node_group_desired_size   = module.globals.node_scaling_config["dev"].desired_size
  enable_karpenter          = module.globals.enable_karpenter["dev"]

  # ... other configuration
}

module "middleware" {
  source = "../modules/middleware"

  environment       = "dev"
  enable_redis      = module.globals.enable_middleware["dev"].redis
  enable_kafka      = module.globals.enable_middleware["dev"].kafka
  enable_rabbitmq   = module.globals.enable_middleware["dev"].rabbitmq
  enable_documentdb = module.globals.enable_middleware["dev"].documentdb

  # ... other configuration
}

# 3. Benefits of this approach:
# - Single source of truth for all environment configurations
# - Easy to update settings across all environments
# - Type safety and validation
# - Clear separation between global and environment-specific settings
# - No duplication of configuration data 