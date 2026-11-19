
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "ERRO: configure o arquivo .env antes."
  exit 1
fi

echo "===== VALIDANDO COMPOSE ====="
docker compose config --quiet

echo "===== CONSTRUINDO E INICIANDO ====="
docker compose up -d --build --wait

echo "===== CONSTRUINDO FERRAMENTA EF CORE ====="
docker build \
  -f Dockerfile.migrations \
  -t fluxo-migrations:1.0 .

echo "===== APLICANDO MIGRATIONS ====="

docker run --rm \
  --network fluxo-network \
  --env-file .env \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__OracleConnection="User Id=FLUXO;Password=$(sed -n 's/^ORACLE_PASSWORD=//p' .env);Data Source=oracle:1521/FREEPDB1" \
  fluxo-migrations:1.0 database update

echo "===== CONTAINERS ====="
docker compose ps

echo "===== TESTANDO API ====="
curl --fail --show-error \
  http://localhost:8080/api/Trem

echo
echo "===== DEPLOY FINALIZADO ====="
