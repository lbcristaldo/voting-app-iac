#!/bin/bash

set -e

NAMESPACE="voting-app-dev"

echo "Deploying Voting App to ${NAMESPACE}"
echo ""

# Check namespace exists
if ! kubectl get namespace ${NAMESPACE} &> /dev/null; then
    echo "❌ Namespace ${NAMESPACE} not found"
    echo "Run: cd ../terraform/environments/dev && terraform apply"
    exit 1
fi

# Deploy in dependency order
echo "1️⃣  Installing Redis..."
helm upgrade --install redis ./redis \
  -f redis/values-dev.yaml \
  --namespace ${NAMESPACE} \
  --wait

echo "2️⃣  Installing PostgreSQL..."
helm upgrade --install db ./db \
  -f db/values-dev.yaml \
  --namespace ${NAMESPACE} \
  --wait

echo "3️⃣  Installing Vote frontend..."
helm upgrade --install vote ./vote \
  -f vote/values-dev.yaml \
  --namespace ${NAMESPACE} \
  --wait

echo "4️⃣  Installing Worker..."
helm upgrade --install worker ./worker \
  -f worker/values-dev.yaml \
  --namespace ${NAMESPACE} \
  --wait

echo "5️⃣  Installing Result dashboard..."
helm upgrade --install result ./result \
  -f result/values-dev.yaml \
  --namespace ${NAMESPACE} \
  --wait

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Status:"
kubectl get pods -n ${NAMESPACE}
echo ""
echo "Access services:"
echo "  Vote:   kubectl port-forward -n ${NAMESPACE} svc/vote 5000:5000"
echo "  Result: kubectl port-forward -n ${NAMESPACE} svc/result 5001:5001"
echo ""
echo "  Then open:"
echo "  - http://localhost:5000 (vote)"
echo "  - http://localhost:5001 (results)"

chmod +x deploy-dev.sh
