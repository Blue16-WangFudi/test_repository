#!/bin/bash

echo "=== Docker ==="
docker compose up -d

echo "=== Containers ==="
docker ps

echo "=== Flutter ==="
flutter doctor

echo "=== Git ==="
git --version
gh --version

echo "=== NextJS Test ==="
cd nextjs-todo
npm test
cd ..

echo "=== SpringBoot Test ==="
cd springboot-todo
./mvnw test
cd ..

echo "=== Flutter Test ==="
cd flutter_todo
flutter test
cd ..

echo "=== Finished ==="
