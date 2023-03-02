locals {
  # Base path for backend.
  backend = "${var.backend_config.url}/${var.backend_config.path}"
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.rest_api_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# This is a concept that's not even really mentioned or mapped 1:1 in the
# AWS API Gateway documentation.
resource "aws_api_gateway_deployment" "rest_api_deploymment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resource_pets.id,
      aws_api_gateway_method.method_pets_get.id,
      aws_api_gateway_integration.method_pets_get_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage_alpha" {
  depends_on    = [aws_cloudwatch_log_group.rest_api_log_group]
  deployment_id = aws_api_gateway_deployment.rest_api_deploymment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.stage_name
  # @see https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-apigateway-deployment-accesslogsetting.html
  # @see https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#set-up-access-logging-using-cloudformation
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.rest_api_log_group.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] $context.httpMethod $context.resourcePath $context.protocol $context.status $context.responseLength $context.requestId $context.extendedRequestId"
  }
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.stage_alpha.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
    # Rate limit default is 10000
    throttling_rate_limit = 5000
    # Burst limit default is 10000
    throttling_burst_limit = 3000
  }
}

resource "aws_cloudwatch_log_group" "rest_api_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.rest_api.id}/${var.stage_name}"
  retention_in_days = 7
}

