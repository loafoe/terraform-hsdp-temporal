variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t2.medium"
}

variable "volume_size" {
  description = "The volume size to use in GB"
  type        = number
  default     = 50
}

variable "user_groups" {
  description = "User groups to assign to cluster"
  type        = list(string)
}

variable "user" {
  description = "LDAP user to use for connections"
  type        = string
}

variable "bastion_host" {
  description = "Bastion host to use for SSH connections"
  type        = string
}

variable "private_key" {
  description = "Private key for SSH access (should not have a passphrase)"
  type        = string
}

variable "org_name" {
  description = "Cloudfoundry ORG name to use for reverse proxy"
  type        = string
}

variable "app_domain" {
  description = "The app domain to use"
  type        = string
}

variable "temporal_image" {
  description = "The Temporal server image to use"
  type        = string
  default     = "loafoe/auto-setup:0.0.1"
}

variable "temporal_web_image" {
  description = "The Temporal web image to use"
  type        = string
  default     = "temporalio/web:1.0.0"
}

variable "agent_image" {
  description = "Agent image"
  type        = string
  default     = "loafoe/ch-agent:0.0.37"
}

variable "postgres_plan" {
  description = "The HSDP-RDS PostgreSQL plan to use"
  type        = string
  default     = "postgres-medium-dev"
}

variable "workers" {
  description = "Number of worker nodes to spin up"
  type        = number
  default     = 1
}

variable "worker_instance_type" {
  description = "Instance type of worker nodes"
  type        = string
  default     = "m5.xlarge"
}
