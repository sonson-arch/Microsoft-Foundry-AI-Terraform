data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.location
}


resource "azurerm_user_assigned_identity" "uai" {
  name                = var.user_assigned_identity_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_storage_account" "sa" {
  name                          = "${local.prefix}storageaccount"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true #må være true for at Search Service skal kunne få tilgang til den 

  #RBAC-autentisering
  shared_access_key_enabled = false
}

resource "azurerm_storage_container" "container" {
  name                  = "${local.prefix}-documents"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_search_service" "search" {
  name                = "${local.prefix}-search-service"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "free"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "search_to_storage" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_search_service.search.identity[0].principal_id
}

resource "azurerm_role_assignment" "contributor_storage" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azapi_resource" "ai_foundry" {
  type      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name      = "${local.prefix}-${var.ai_foundry_name}"
  location  = var.location
  parent_id = azurerm_resource_group.rg.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  body = {
    kind = "AIServices"
    sku = {
      name = "S0"
    }
    properties = {
      allowProjectManagement = true
      customSubDomainName    = var.ai_foundry_name
      disableLocalAuth       = false
      publicNetworkAccess    = "Enabled"
    }
  }
}

resource "azapi_resource" "ai_project" {
  type      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name      = "${local.prefix}-${var.ai_project_name}"
  location  = var.location
  parent_id = azapi_resource.ai_foundry.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  body = {
    properties = {}
  }
}

## Deploy model
resource "azapi_resource" "model_deployment" {
  type      = "Microsoft.CognitiveServices/accounts/deployments@2025-06-01"
  name      = var.model_name
  parent_id = azapi_resource.ai_foundry.id

  body = {
    sku = {
      capacity = var.model_capacity
      name     = "GlobalStandard"
    }
    properties = {
      model = {
        name    = var.model_name
        format  = "OpenAI"
        version = var.model_version
      }
    }
  }
}

