docker-compose  -f "docker-compose.yaml" stop
docker-compose  -f "tools_backup.yaml" up 
docker-compose  -f "docker-compose.yaml" up -d