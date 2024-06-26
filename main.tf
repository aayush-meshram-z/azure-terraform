
resource "azurerm_resource_group" "rg" {
  name     = "rg-personal-001"
  location = "South India"
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-password-secret"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-training-0001"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "snet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "vm-training-win-0001-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-vm-win.id
  }
}

resource "azurerm_public_ip" "pip-vm-win" {
  name                = "pip-vm-training-win-0001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "pip-vm-linux" {
  name                = "pip-vm-training-linux-0001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-personal-0001"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "Create",
    ]

    secret_permissions = [
      "Get",
      "Set",
    ]

    storage_permissions = [
      "Get",
      "Set",
    ]
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-neal-win-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D4s_v3"
  admin_username      = "adminuser"
  admin_password      = data.azurerm_key_vault_secret.vm_password.value
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-pro"
    version   = "latest"
  }
}


# resource "azurerm_network_interface" "linux_nic" {
#   name                = "linux-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.snet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pip-vm-linux.id
#   }
# }

# resource "azurerm_linux_virtual_machine" "linux_vm" {
#   name                            = "vm-k8s-linux-01"
#   resource_group_name             = azurerm_resource_group.rg.name
#   location                        = azurerm_resource_group.rg.location
#   size                            = "Standard_F4"
#   admin_username                  = "adminuser"
#   admin_password                  = data.azurerm_key_vault_secret.vm_password.value
#   disable_password_authentication = false
#   network_interface_ids = [
#     azurerm_network_interface.linux_nic.id,
#   ]

#   # admin_password {
#   #   username   = "adminuser"
#   #   vm_password = data.azurerm_key_vault_secret.vm_password.value
#   # }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }
# }
