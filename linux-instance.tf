resource "azurerm_network_interface" "terra-demo" {
  name                = "terra-nic"
  #location            = azurerm_resource_group.terra-demo.location
  location            = "east us"
 # resource_group_name = azurerm_resource_group.terra-demo.name
  resource_group_name =  "fs-det-DevExSDAGroup"


  ip_configuration {
    name                          = "internal"
    #subnet_id                     = azurerm_subnet.terra-demo.id
     subnet_id = "/subscriptions/200c7489-b327-42c4-b931-85c9259878ae/resourceGroups/USEPSBXDNTRSG01/providers/Microsoft.Network/virtualNetworks/USEPSBXDNTVNT01/subnets/USEPSBXDNTSBN02"


    private_ip_address_allocation = "Dynamic"
   #public_ip_address_id          = azurerm_public_ip.terra-demo.id
  }
}

resource "azurerm_linux_virtual_machine" "terra-demo" {
  name                = "terra-virtual-machine"
  # name                = "terra-machine01-.NET"
  #resource_group_name = azurerm_resource_group.terra-demo.name
  resource_group_name =  "fs-det-DevExSDAGroup"
  #location            = azurerm_resource_group.terra-demo.location
  location            = "east us"
  # size                = D2s v3
   size                  = var.size
  # size                = "Standard_D2_v2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.terra-demo.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")  // ls "~/.ssh/" to check the key and for creating ssh-keygen.exe
 #public_key = file("~/.ssh/authorized_keys")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    
    publisher = "Canonical"
  # offer     = Ubuntu
    offer      =    var.offer
    sku       = "16.04-LTS"
    version   = "latest"
    # publisher = "Canonical"
    # offer     = "UbuntuServer"
    # sku       = "16.04-LTS"
    # version   = "latest"
  }

  tags = {
    Name     = "p44_virtual machine"
    PID      = "pDADEVX03"
    prj-name = "DevEx Platform"
    owner    = "DevEX Team"
  }

}

resource "azurerm_virtual_machine_extension" "terra-demo" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.terra-demo.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "sudo apt-get update && sudo apt-get install apache2 -y && sudo systemctl start apache2 && sudo systemctl enable apache2 && sudo echo '<h1>Hello World from Terraform</h1>' | sudo tee /var/www/html/index.html"
 }
SETTINGS

  tags = {
    environment = "Production"
  }
}
