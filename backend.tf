# data "github_actions_secret" "client_secret" {
#   secret_name = "AZURE_CLIENT_SECRET_VALUE"
# }
terraform {
  backend "azurerm" {
    subscription_id = "b3c81c82-8ece-4492-ac8a-a32c95f8bfdf"
    tenant_id       = "8183da53-5112-46d8-bd0d-564f717bef66"
    client_id       = "d637088f-6258-45d3-b144-ceb7b995d06f"
    client_secret   = data.github_actions_secret.client_id.value
    resource_group_name = "rg-training"
    storage_account_name = "satfstatetraining"
    container_name = "state"
    key = "terraform.tfstate"  # Name of the state file
    # skip_provider_registration = "true"
    # access_key = "sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-03-21T14:27:09Z&st=2024-03-21T06:27:09Z&spr=https&sig=aVxs41LqYsc9KLjWAIr42QHLn%2FfNWzsJuqUdvW8Q2Ig%3D"  # Replace with key or SAS token

    # Optional: Configure encryption for additional security
    # encrypt = true
  }
}
