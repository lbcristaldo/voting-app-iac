#!/bin/bash

set -e

NAMESPACE="voting-app-dev"

echo "🗑️  Uninstalling Voting App from ${NAMESPACE}"
echo ""

helm uninstall result --namespace ${NAMESPACE} || true
helm uninstall worker --namespace ${NAMESPACE} || true
helm uninstall vote --namespace ${NAMESPACE} || true
helm uninstall db --namespace ${NAMESPACE} || true
helm uninstall redis --namespace ${NAMESPACE} || true

echo ""
echo "✅ All charts uninstalled"
echo ""
echo "PersistentVolumeClaims:"
kubectl get pvc -n ${NAMESPACE}
echo ""
echo "To delete PVCs: kubectl delete pvc --all -n ${NAMESPACE}"

chmod +x undeploy-dev.sh
