variable "aws_region" {
  default     = "us-west-2"
  description = "AWS Region to deploy example API Gateway REST API"
  type        = string
}

variable "rest_api_name" {
  default     = "api-gateway-rest-inhabit-example"
  description = "Name of the API Gateway REST API (can be used to trigger redeployments)"
  type        = string
}

variable "backend_config" {
  type = map(string)
  default = {
    url  = "http://petstore-demo-endpoint.execute-api.com"
    path = "petstore"
  }
}

variable "stage_name" {
  type        = string
  default     = "alpha"
  description = "Describes the stage used for API deployments"
}

variable "base_path" {
  type        = string
  default     = "pets"
  description = "Base path for API"
}
