
#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-fluxo-video"
LOCATION="spaincentral"
VM_NAME="vm-fluxo-video"
VM_SIZE="Standard_B2s_v2"
ADMIN_USER="azureuser"

echo "===== CRIANDO GRUPO DE RECURSOS ====="

az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

echo "===== CRIANDO VM UBUNTU ====="

az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --location "$LOCATION" \
  --zone 1 \
  --image Ubuntu2404 \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --storage-sku Standard_LRS \
  --output table

echo "===== LIBERANDO PORTA 8080 ====="

az vm open-port \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --port 8080 \
  --priority 1010

echo "===== OBTENDO IP PUBLICO ====="

az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --show-details \
  --query publicIps \
  --output tsv

echo "===== VM CRIADA COM SUCESSO ====="
