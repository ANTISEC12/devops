docker-compose  -f "docker-compose.yaml" stop
cp atlassian-agent.jar atlassian-agent.jar.bck
docker-compose  -f "tools_restore_old.yaml" up 
cp atlassian-agent.jar.bck atlassian-agent.jar