resource "aws_api_gateway_resource" "resource_pets" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = var.base_path
}

resource "aws_api_gateway_method" "method_pets_get" {
  depends_on    = [aws_api_gateway_rest_api.rest_api]
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.resource_pets.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.querystring.type" = false
    "method.request.querystring.page" = false
  }
}

resource "aws_api_gateway_integration" "method_pets_get_integration" {
  depends_on              = [aws_api_gateway_resource.resource_pets]
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.resource_pets.id
  http_method             = aws_api_gateway_method.method_pets_get.http_method
  integration_http_method = aws_api_gateway_method.method_pets_get.http_method
  type                    = "HTTP"
  uri                     = "${local.backend}/${var.base_path}"
  request_parameters = {
    "integration.request.querystring.type" = "method.request.querystring.type"
    "integration.request.querystring.page" = "method.request.querystring.page"
  }
}

resource "aws_api_gateway_integration_response" "method_pets_get_integration_response_200" {
  depends_on  = [aws_api_gateway_integration.method_pets_get_integration]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_pets.id
  http_method = aws_api_gateway_method.method_pets_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "method_pets_get_method_response_200" {
  depends_on  = [aws_api_gateway_integration_response.method_pets_get_integration_response_200]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.resource_pets.id
  http_method = aws_api_gateway_method.method_pets_get.http_method
  status_code = "200"
  # @see https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-apitgateway-method-methodresponse.html
  response_models = {
    "application/json" = "Empty"
  }
}
