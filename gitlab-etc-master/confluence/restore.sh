docker-compose  -f "docker-compose.yml" stop
cp atlassian-agent.jar atlassian-agent.jar.bck
docker-compose  -f "tools_restore.yaml" up 
cp atlassian-agent.jar.bck atlassian-agent.jar