#!/bin/bash

# Gradual Deployment Script for Terraform Infrastructure
# This script helps manage phased deployments using feature flags

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-dev}
PHASE=${2:-all}
TERRAFORM_DIR="environments/${ENVIRONMENT}"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if directory exists
check_environment() {
    if [ ! -d "$TERRAFORM_DIR" ]; then
        print_error "Environment directory $TERRAFORM_DIR does not exist"
        exit 1
    fi
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform in $TERRAFORM_DIR"
    cd "$TERRAFORM_DIR"
    terraform init
    cd - > /dev/null
}

# Function to create terraform.tfvars from example
create_tfvars() {
    if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
        print_status "Creating terraform.tfvars from example"
        cp "$TERRAFORM_DIR/terraform.tfvars.example" "$TERRAFORM_DIR/terraform.tfvars"
        print_warning "Please update terraform.tfvars with your specific values"
    fi
}

# Function to deploy phase 1: VPC and Networking
deploy_phase1() {
    print_status "Deploying Phase 1: VPC and Networking"
    
    cd "$TERRAFORM_DIR"
    
    # Update terraform.tfvars for phase 1
    cat > terraform.tfvars << EOF
# Phase 1: VPC and Networking Only
enable_vpc = true
enable_eks = false
enable_ingress = false
enable_acm = false
enable_dns_resolver = false
enable_middleware = false
enable_postgres = false
enable_mysql = false
enable_iam = true

# Add your other configuration here
aws_region = "us-west-2"
project_name = "myapp"
organization = "mycompany"
EOF
    
    print_status "Running terraform plan for Phase 1"
    terraform plan -out=phase1.tfplan
    
    read -p "Do you want to apply Phase 1? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Applying Phase 1"
        terraform apply phase1.tfplan
        print_success "Phase 1 completed successfully"
    else
        print_warning "Phase 1 deployment cancelled"
    fi
    
    cd - > /dev/null
}

# Function to deploy phase 2: EKS Cluster
deploy_phase2() {
    print_status "Deploying Phase 2: EKS Cluster"
    
    cd "$TERRAFORM_DIR"
    
    # Update terraform.tfvars for phase 2
    cat > terraform.tfvars << EOF
# Phase 2: VPC + EKS Cluster
enable_vpc = true
enable_eks = true
enable_ingress = false
enable_acm = false
enable_dns_resolver = false
enable_middleware = false
enable_postgres = false
enable_mysql = false
enable_iam = true

# Add your other configuration here
aws_region = "us-west-2"
project_name = "myapp"
organization = "mycompany"
EOF
    
    print_status "Running terraform plan for Phase 2"
    terraform plan -out=phase2.tfplan
    
    read -p "Do you want to apply Phase 2? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Applying Phase 2"
        terraform apply phase2.tfplan
        print_success "Phase 2 completed successfully"
    else
        print_warning "Phase 2 deployment cancelled"
    fi
    
    cd - > /dev/null
}

# Function to deploy phase 3: Ingress and Load Balancers
deploy_phase3() {
    print_status "Deploying Phase 3: Ingress and Load Balancers"
    
    cd "$TERRAFORM_DIR"
    
    # Update terraform.tfvars for phase 3
    cat > terraform.tfvars << EOF
# Phase 3: VPC + EKS + Ingress + ACM
enable_vpc = true
enable_eks = true
enable_ingress = true
enable_acm = true
enable_dns_resolver = true
enable_middleware = false
enable_postgres = false
enable_mysql = false
enable_iam = true

# Add your other configuration here
aws_region = "us-west-2"
project_name = "myapp"
organization = "mycompany"
EOF
    
    print_status "Running terraform plan for Phase 3"
    terraform plan -out=phase3.tfplan
    
    read -p "Do you want to apply Phase 3? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Applying Phase 3"
        terraform apply phase3.tfplan
        print_success "Phase 3 completed successfully"
    else
        print_warning "Phase 3 deployment cancelled"
    fi
    
    cd - > /dev/null
}

# Function to deploy phase 4: Databases
deploy_phase4() {
    print_status "Deploying Phase 4: Databases"
    
    cd "$TERRAFORM_DIR"
    
    # Update terraform.tfvars for phase 4
    cat > terraform.tfvars << EOF
# Phase 4: VPC + EKS + Ingress + ACM + Databases
enable_vpc = true
enable_eks = true
enable_ingress = true
enable_acm = true
enable_dns_resolver = true
enable_middleware = true
enable_postgres = true
enable_mysql = true
enable_iam = true

# Add your other configuration here
aws_region = "us-west-2"
project_name = "myapp"
organization = "mycompany"
EOF
    
    print_status "Running terraform plan for Phase 4"
    terraform plan -out=phase4.tfplan
    
    read -p "Do you want to apply Phase 4? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Applying Phase 4"
        terraform apply phase4.tfplan
        print_success "Phase 4 completed successfully"
    else
        print_warning "Phase 4 deployment cancelled"
    fi
    
    cd - > /dev/null
}

# Function to deploy all phases at once
deploy_all() {
    print_status "Deploying All Phases at Once"
    
    cd "$TERRAFORM_DIR"
    
    # Use the full configuration
    print_status "Running terraform plan for full deployment"
    terraform plan -out=full.tfplan
    
    read -p "Do you want to apply full deployment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Applying full deployment"
        terraform apply full.tfplan
        print_success "Full deployment completed successfully"
    else
        print_warning "Full deployment cancelled"
    fi
    
    cd - > /dev/null
}

# Function to show current status
show_status() {
    print_status "Current deployment status for environment: $ENVIRONMENT"
    
    cd "$TERRAFORM_DIR"
    
    if [ -f "terraform.tfstate" ]; then
        print_status "Resources currently deployed:"
        terraform state list | head -20
        
        if [ $(terraform state list | wc -l) -gt 20 ]; then
            print_status "... and $(($(terraform state list | wc -l) - 20)) more resources"
        fi
    else
        print_warning "No Terraform state found. Run 'terraform init' first."
    fi
    
    cd - > /dev/null
}

# Function to rollback specific modules
rollback_module() {
    local module_name=$1
    
    print_status "Rolling back module: $module_name"
    
    cd "$TERRAFORM_DIR"
    
    # Disable the specific module
    terraform apply -var="enable_${module_name}=false" -auto-approve
    
    print_success "Module $module_name has been disabled"
    
    cd - > /dev/null
}

# Function to show help
show_help() {
    echo "Gradual Deployment Script for Terraform Infrastructure"
    echo ""
    echo "Usage: $0 [environment] [phase]"
    echo ""
    echo "Environments:"
    echo "  dev       - Development environment (default)"
    echo "  staging   - Staging environment"
    echo "  prod      - Production environment"
    echo ""
    echo "Phases:"
    echo "  phase1    - VPC and Networking only"
    echo "  phase2    - VPC + EKS Cluster"
    echo "  phase3    - VPC + EKS + Ingress + ACM"
    echo "  phase4    - VPC + EKS + Ingress + ACM + Databases"
    echo "  all       - Deploy everything at once (default)"
    echo "  status    - Show current deployment status"
    echo "  rollback  - Rollback specific module (requires module name)"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev phase1          # Deploy VPC only in dev"
    echo "  $0 staging phase2      # Deploy VPC + EKS in staging"
    echo "  $0 prod all            # Deploy everything in prod"
    echo "  $0 dev status          # Show current status in dev"
    echo "  $0 dev rollback postgres # Rollback PostgreSQL in dev"
}

# Main script logic
main() {
    case $PHASE in
        "phase1")
            check_environment
            init_terraform
            create_tfvars
            deploy_phase1
            ;;
        "phase2")
            check_environment
            init_terraform
            create_tfvars
            deploy_phase2
            ;;
        "phase3")
            check_environment
            init_terraform
            create_tfvars
            deploy_phase3
            ;;
        "phase4")
            check_environment
            init_terraform
            create_tfvars
            deploy_phase4
            ;;
        "all")
            check_environment
            init_terraform
            create_tfvars
            deploy_all
            ;;
        "status")
            check_environment
            show_status
            ;;
        "rollback")
            if [ -z "$3" ]; then
                print_error "Module name required for rollback"
                echo "Usage: $0 [environment] rollback [module_name]"
                echo "Example: $0 dev rollback postgres"
                exit 1
            fi
            check_environment
            rollback_module "$3"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Invalid phase: $PHASE"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 