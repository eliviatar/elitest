# Simple Example - DynamoDB Resource Policy Check
#
# This example demonstrates both PASS and FAIL scenarios:
#
# ✅ PASS: module.my_dynamodb_table.aws_dynamodb_table.this
#    - Has resource policy attached (via module output)
#    - Policy includes Condition blocks
#    - Even though Action is "dynamodb:*" and Principal has ":root", conditions exist
#
# ❌ FAIL: module.table_without_policy.aws_dynamodb_table.this
#    - No resource policy attached
#    - Violates the requirement that DynamoDB tables must have resource policies

# ✅ PASS - This table has a resource policy with conditions
module "table_with_policy" {
  source = "./dynamodb_module"

  table_name = "my-test-table"
  hash_key   = "id"
}

# ❌ FAIL - This table has NO resource policy attached
module "table_without_policy" {
  source = "./dynamodb_module"
  
  table_name = "table-without-policy"
  hash_key   = "id"
}

# IAM policy document with conditions
data "aws_iam_policy_document" "dynamodb_policy" {
  statement {
    actions = ["dynamodb:*"]
    effect  = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = ["o-example123"]
    }
  }
  
  statement {
    actions = ["dynamodb:*"]
    effect  = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:root"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = ["o-example123"]
    }
  }
}

# Resource policy attached to the module's table output
# This should PASS because:
# 1. Table has resource policy attached (via module output)
# 2. Policy has Condition blocks
# 3. Even though Action is "dynamodb:*" and Principal has ":root", conditions exist
resource "aws_dynamodb_resource_policy" "table_policy" {
  resource_arn = module.table_with_policy.table_arn
  policy       = data.aws_iam_policy_document.dynamodb_policy.json
}
