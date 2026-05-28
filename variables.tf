variable "rg_name" {
  description = "The name of the resource group to create"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID to deploy resources into"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "ai_foundry_name" {
  description = "The name of the AI Foundry account"
  type        = string
}

variable "ai_project_name" {
  description = "The name of the AI Foundry project"
  type        = string
}

variable "user_assigned_identity_name" {
  description = "The name of the User-Assigned Identity (for new or existing)"
  type        = string
  }


variable "model_name" {
  description = "The model to deploy"
  type        = string
}

variable "model_version" {
  description = "The version of the model"
  type        = string
}

variable "model_capacity" {
  description = "The capacity (quota) for the model deployment"
  type        = number
}