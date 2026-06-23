resource "azurerm_ssh_public_key" "main" {
  name                = "${var.prefix}-sshkey"
  resource_group_name = var.resource_group_name
  location            = var.location
  public_key          = var.ssh_public_key
  tags                = var.tags
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.prefix}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  disable_password_authentication = true

  network_interface_ids = [
    var.network_interface_id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  custom_data = base64encode(templatefile("${path.module}/../../scripts/setup.sh", {
    admin_username = var.admin_username
  }))

  identity {
    type = "SystemAssigned"
  }
}
