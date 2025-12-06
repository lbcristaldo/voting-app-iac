#!/usr/bin/env bash
set -e

echo "[INFO] Instalando Helm..."

# 1. Intentar instalación con script oficial
if curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; then
  echo "[SUCCESS] Helm instalado con el script oficial 🎉"
else
  echo "[WARN] Falló el script oficial, intentando con Snap..."
  sudo snap install helm --classic
  echo "[SUCCESS] Helm instalado con Snap 🎉"
fi

# 2. Verificar instalación
echo "[INFO] Verificando versión instalada..."
helm version
