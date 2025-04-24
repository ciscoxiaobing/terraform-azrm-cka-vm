
module "regions" {
  source                    = "ciscoxiaobing/utl-cnregions/azurerm"
  version                   = "0.1.0"
  use_cached_data           = false
  availability_zones_filter = true
  recommended_filter        = false
  enable_telemetry          = false
}

resource "azurerm_resource_group" "linux_srg" {
  name     = var.resource_group_name
  location = try(module.regions.regions[0].name, "chinanorth2")
  tags = var.tags

}

resource "azurerm_virtual_network" "jack_vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_namespace1, var.vnet_namespace2]
  location            = try(module.regions.regions[0].name, "chinanorth2")
  resource_group_name = azurerm_resource_group.linux_srg.name

  tags = var.tags
}
resource "azurerm_subnet" "jack_vnet_web_subnet" {
  name                 = var.web_subnet
  resource_group_name  = azurerm_resource_group.linux_srg.name
  virtual_network_name = azurerm_virtual_network.jack_vnet.name
  address_prefixes     = [var.web_subnet_address_space]
}

resource "azurerm_subnet" "jack_vnet_db_subnet" {
  name                 = var.db_subnet
  resource_group_name  = azurerm_resource_group.linux_srg.name
  virtual_network_name = azurerm_virtual_network.jack_vnet.name
  address_prefixes     = [var.db_subnet_address_space]
}

resource "azurerm_subnet" "jack_vnet_gateway_subnet" {
  name                 = var.gateway_subnet
  resource_group_name  = azurerm_resource_group.linux_srg.name
  virtual_network_name = azurerm_virtual_network.jack_vnet.name
  address_prefixes     = [var.gateway_subnet_address_space]
}

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.linux_srg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "jack_diag_sto" {
  name                            = "diag${random_id.randomId.hex}"
  resource_group_name             = azurerm_resource_group.linux_srg.name
  location                        = try(module.regions.regions[0].name, "chinanorth2")
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}
resource "azurerm_public_ip" "vm_publicIP" {
  count               = var.countnum
  name                = "${var.public_ip_name}${count.index}"
  location            = try(module.regions.regions[0].name, "chinanorth2")
  resource_group_name = azurerm_resource_group.linux_srg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
resource "azurerm_network_security_group" "jack-nsg" {
  name                = var.jack-nsg-name
  location            = try(module.regions.regions[0].name, "chinanorth2")
  resource_group_name = azurerm_resource_group.linux_srg.name

  security_rule {
    name                       = var.jack-nsg-home-rule
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = ["20.9.64.134/32", "182.1.9.78/32", "11.94.154.197/32"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WFH"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = ["20.23.64.13/32", "18.160.9.7/32"]
    destination_address_prefix = "*"
  }

  tags = var.tags
}
resource "azurerm_network_security_rule" "jack-nsg-isp-rule" {
  name                        = var.jack-nsg-isp-rule-name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "8080", "10050-10051"]
  source_address_prefixes     = ["11.25.100.21/32", "8.22.10.0/24"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.linux_srg.name
  network_security_group_name = azurerm_network_security_group.jack-nsg.name
}

resource "azurerm_network_interface" "jack_linux_nic1" {
  count               = var.countnum
  name                = "${var.jack_linux_nic1_name}${count.index}"
  location            = try(module.regions.regions[0].name, "chinanorth2")
  resource_group_name = azurerm_resource_group.linux_srg.name


  ip_configuration {
    name                          = "vm-${lower(var.jack_linux_nic1_setting_name)}-${count.index}"
    subnet_id                     = azurerm_subnet.jack_vnet_web_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = element(var.nics, count.index)
    public_ip_address_id          = element(azurerm_public_ip.vm_publicIP.*.id, count.index)
  }

  tags = var.tags
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg-nic-association" {
  count                     = var.countnum
  network_interface_id      = element(azurerm_network_interface.jack_linux_nic1.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.jack-nsg.id
}

resource "azurerm_availability_set" "avset" {
  name                         = var.avsetname
  location                     = try(module.regions.regions[0].name, "chinanorth2")
  resource_group_name          = azurerm_resource_group.linux_srg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 3
  managed                      = true
}

resource "azurerm_linux_virtual_machine" "jack_linux_vm" {
  count = var.countnum
  name  = "${var.short_name}-${var.vm_name}-${var.role}-${format(var.count_format, count.index + 1)}"
  location                        = try(module.regions.regions[0].name, "chinanorth2")
  resource_group_name             = azurerm_resource_group.linux_srg.name
  network_interface_ids           = [element(azurerm_network_interface.jack_linux_nic1.*.id, count.index)]
  size                            = "Standard_A4_v2"
  admin_username                  = var.vmuser_name
  admin_password                  = var.sshpwd
  disable_password_authentication = false

  os_disk {
    name                 = "OsDisk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.production == "prod" ? "OpenLogic" : "Canonical"
    offer     = var.production == "prod" ? "CentOS" : "UbuntuServer"
    sku       = var.production == "prod" ? "7_9" : "18.04-LTS"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.jack_diag_sto.primary_blob_endpoint
  }

  tags = var.tags
}
