# Qdrant Cluster

## How to Start

start first node

```
sudo docker compose up qdrant-node-1
```

you can access `http://localhost:7333/dashboard`
check `http://localhost:7333/cluster`

then, add followers

```
sudo docker compose up qdrant-node-2
sudo docker compose up qdrant-node-3
```

check `http://localhost:7333/cluster`
check `http://localhost:8333/cluster`
check `http://localhost:9333/cluster`
