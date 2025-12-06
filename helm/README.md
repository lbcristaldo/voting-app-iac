# Helm Charts

Application deployment for the voting app.

## Charts

- **redis**: In-memory queue
- **db**: PostgreSQL database
- **vote**: Python Flask frontend
- **worker**: .NET processor
- **result**: Node.js dashboard

## Deploy All
```bash
./deploy-dev.sh
```

## Undeploy All
```bash
./undeploy-dev.sh
```

## Manual Deployment
```bash
helm install redis ./redis -f redis/values-dev.yaml -n voting-app-dev
helm install db ./db -f db/values-dev.yaml -n voting-app-dev
helm install vote ./vote -f vote/values-dev.yaml -n voting-app-dev
helm install worker ./worker -f worker/values-dev.yaml -n voting-app-dev
helm install result ./result -f result/values-dev.yaml -n voting-app-dev
```

## Verify
```bash
kubectl get all -n voting-app-dev
```

## Access
```bash
kubectl port-forward -n voting-app-dev svc/vote 5000:5000 &
kubectl port-forward -n voting-app-dev svc/result 5001:5001 &
```

Open http://localhost:5000 and http://localhost:5001
