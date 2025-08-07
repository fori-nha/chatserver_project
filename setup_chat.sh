#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Rocket.Chat setup...${NC}"

# 1. Check Docker
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing..."
    sudo apt update && sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker is already installed."
fi

# 2. Check MongoDB container
if [ "$(docker ps -a -q -f name=rocketchat_db)" ]; then
    echo "MongoDB container already exists."
else
    echo "Creating MongoDB container..."
    docker pull mongo:6.0
    docker run -d \
        --name rocketchat_db \
        -v rocketchat_db_data:/data/db \
        mongo:6.0
fi

# 3. Check Rocket.Chat container
if [ "$(docker ps -a -q -f name=rocketchat_app)" ]; then
    echo "Rocket.Chat container already exists."
else
    echo "Creating Rocket.Chat container..."
    docker pull rocketchat/rocket.chat:latest
    docker run -d \
        --name rocketchat_app \
        --link rocketchat_db:db \
        -e MONGO_URL=mongodb://db:27017/rocketchat \
        -e ROOT_URL=http://localhost:3000 \
        -e PORT=3000 \
        -p 3000:3000 \
        rocketchat/rocket.chat:latest
fi

# 4. Show status
echo -e "${GREEN}Containers Running:${NC}"
docker ps

echo -e "${GREEN}Rocket.Chat is available at: http://<your-server-ip>:3000${NC}"
