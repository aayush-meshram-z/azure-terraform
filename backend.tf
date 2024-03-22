terraform {
  backend "azurerm" {
    subscription_id = "b3c81c82-8ece-4492-ac8a-a32c95f8bfdf"
    tenant_id       = "8183da53-5112-46d8-bd0d-564f717bef66"
    client_id       = "d637088f-6258-45d3-b144-ceb7b995d06f"
    resource_group_name = "rg-training"
    storage_account_name = "satfstatetraining"
    container_name = "state"
    key = "terraform.tfstate"  # Name of the state file
  }
}
