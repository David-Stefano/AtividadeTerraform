resource "azurerm_virtual_network" "vnet_atividade" {
    name                = "vnet_atividadet"
    address_space       = ["10.80.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.rg_atividade.name

    depends_on = [ azurerm_resource_group.rg_atividade ]
}

resource "azurerm_public_ip" "publicip_atividade_db" {
    name                         = "publicip_atividade_db"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.rg_atividade.name
    allocation_method            = "Static"
    idle_timeout_in_minutes = 30

    depends_on = [ azurerm_resource_group.rg_atividade ]
}

resource "azurerm_subnet" "subnet_atividade" {
    name                 = "subnet_atividade"
    resource_group_name  = azurerm_resource_group.rg_atividade.name
    virtual_network_name = azurerm_virtual_network.vnet_atividade.name
    address_prefixes       = ["10.80.4.0/24"]

    depends_on = [ azurerm_resource_group.rg_atividade]
}



resource "azurerm_network_interface" "nic_atividade_db" {
    name                      = "nic_atividade_db"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.rg_atividade.name

    ip_configuration {
        name                          = "myNicConfigurationDB"
 	subnet_id                     = azurerm_subnet.subnet_atividade.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.80.4.10"
        public_ip_address_id          = azurerm_public_ip.publicip_atividade_db.id
    }

    depends_on = [ azurerm_resource_group.rg_atividade ]
}

resource "azurerm_network_interface_security_group_association" "nicsq_atividade_db" {
    network_interface_id      = azurerm_network_interface.nic_atividade_db.id
    network_security_group_id = azurerm_network_security_group.security_atividade.id

    depends_on = [ azurerm_network_interface.nic_atividade_db, azurerm_network_security_group.security_atividade]
}

resource "azurerm_network_security_group" "security_atividade" {
    name                = "security_atividade"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.rg_atividade.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPInbound"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPOutbound"
        priority                   = 1003
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }


  security_rule {
        name                       = "MySqlOutbound"
        priority                   = 1004
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }


  security_rule {
        name                       = "MySqlInbound"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    depends_on = [ azurerm_resource_group.rg_atividade ]
}



data "azurerm_public_ip" "ip_atividade_data_db" {
  name                = azurerm_public_ip.publicip_atividade_db.name
  resource_group_name = azurerm_resource_group.rg_atividade.name
}