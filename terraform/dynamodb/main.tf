data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_dynamodb_table" "product_table" {
  attribute = [
    {
      name = "PK"
      type = "S"
    },
    {
      name = "SK"
      type = "S"
    },
    {
      name = "GS1-PK"
      type = "S"
    },
    {
      name = "GS1-SK"
      type = "S"
    },
    {
      name = "GS2-PK"
      type = "S"
    },
    {
      name = "GS2-SK"
      type = "S"
    },
    {
      name = "LS1-SK"
      type = "S"
    }
  ]
  local_secondary_index = [
    {
      name               = "LS1"
      non_key_attributes = [
        {
          AttributeName = "PK"
          KeyType       = "HASH"
        },
        {
          AttributeName = "LS1-SK"
          KeyType       = "RANGE"
        }
      ]
      projection_type = {
        ProjectionType = "ALL"
      }
    }
  ]
  global_secondary_index = [
    {
      name               = "GSI1"
      non_key_attributes = [
        {
          AttributeName = "GS1-PK"
          KeyType       = "HASH"
        },
        {
          AttributeName = "GS1-SK"
          KeyType       = "RANGE"
        }
      ]
      projection_type = {
        ProjectionType = "ALL"
      }
      ProvisionedThroughput = {
        ReadCapacityUnits  = 1
        WriteCapacityUnits = 1
      }
    },
    {
      name               = "GSI2"
      non_key_attributes = [
        {
          AttributeName = "GS2-PK"
          KeyType       = "HASH"
        },
        {
          AttributeName = "GS2-SK"
          KeyType       = "RANGE"
        }
      ]
      projection_type = {
        ProjectionType = "ALL"
      }
      ProvisionedThroughput = {
        ReadCapacityUnits  = 1
        WriteCapacityUnits = 1
      }
    }
  ]
  name = "OnlineShop_TF"
  hash_key = "PK"
}