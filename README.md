# FLUXO — DevOps Tools & Cloud Computing

## 1. Sobre o projeto

O FLUXO é uma plataforma desenvolvida para a Global Solution 2026/2 da FIAP, com o objetivo de monitorar a lotação de metrôs e trens, auxiliando passageiros e operadores na identificação de situações de superlotação.

Na disciplina de DevOps, realizamos a implantação de uma API .NET 8 integrada a um banco Oracle, utilizando containers Docker em uma máquina virtual Linux hospedada no Microsoft Azure.

## 2. Integrantes

| Nome | RM |
| --- | --- |
| Isabely Marques da Silva | 566663 |
| Luana Alves de Oliveira | 566621 |
| Mateus Ribeiro Azevedo | 566630 |
| Paulo Gustavo Moraes de Sousa | 568580 |

**Turma:** 2TDSPR

## 3. Tecnologias utilizadas

- C# e ASP.NET Core 8
- Entity Framework Core
- Oracle Database Free
- Docker e Docker Compose
- Microsoft Azure Virtual Machines
- Azure CLI e Cloud Shell
- Linux Ubuntu 24.04
- Git, GitHub e Postman

## 4. Arquitetura

A aplicação utiliza dois containers Docker executados em uma máquina virtual Ubuntu no Microsoft Azure.

O container `fluxo-api` executa a API .NET 8 na porta 8080, enquanto o `fluxo-oracle` armazena os dados no Oracle, utilizando a porta interna 1521.

Os serviços se comunicam pela rede `fluxo-network`. A persistência dos dados é garantida pelo volume Docker `fluxo-oracle-data`.

A API utiliza um Dockerfile multi-stage e executa com usuário não-root.

**Diagrama de arquitetura:** será disponibilizado na pasta `docs`.

## 5. Funcionalidades da API

| Método | Endpoint | Descrição |
| --- | --- | --- |
| GET | `/api/Estacao` | Listar estações |
| POST | `/api/Estacao` | Cadastrar estação |
| GET | `/api/Plataforma` | Listar plataformas |
| POST | `/api/Plataforma` | Cadastrar plataforma |
| GET | `/api/Trem` | Listar trens |
| POST | `/api/Trem` | Cadastrar trem |
| GET | `/api/Vagao` | Listar vagões |
| POST | `/api/Vagao` | Cadastrar vagão |
| GET | `/api/Trem/{id}/lotacao` | Consultar lotação do trem |

As entidades também possuem operações de consulta por ID, atualização e exclusão.

## 6. Execução com Docker

Após clonar o repositório na VM Ubuntu, instale o Docker:

```bash
bash scripts/instalar-docker.sh
```

Configure a permissão do usuário para executar Docker e reconecte-se à VM:

```bash
sudo usermod -aG docker "$USER"
```

Crie o arquivo de variáveis de ambiente:

```bash
cp .env.example .env
nano .env
chmod 600 .env
```

Substitua a senha de exemplo por uma senha forte.

Execute a implantação:

```bash
bash scripts/deploy.sh
```

O script constrói a API, inicia os containers e aplica as migrations do Entity Framework Core no Oracle.

Para verificar:

```bash
docker compose ps
docker compose logs --tail 20 api
docker exec fluxo-api id
docker volume ls
```

## 7. Provisionamento no Azure

A infraestrutura é criada utilizando a Azure CLI, por meio do script `scripts/azure-cli.sh`.

No Azure Cloud Shell (Bash):

```bash
git clone https://github.com/ismrqs/fluxo-gs-devops.git
cd fluxo-gs-devops

bash scripts/azure-cli.sh
```

O script cria o grupo de recursos, provisiona a VM Ubuntu e libera a porta 8080 para a API.

Após a criação, consulte o IP público e conecte-se à VM:

```bash
az vm list-ip-addresses \
  --resource-group rg-fluxo-video \
  --name vm-fluxo-video \
  --output table
```

```bash
ssh azureuser@IP_PUBLICO
```

Dentro da VM, clone novamente o repositório e siga as instruções da seção 6.

## 8. Testes em nuvem e persistência

A API pode ser acessada pelo IP público da VM:

```bash
curl -i http://IP_PUBLICO:8080/api/Trem
curl -i http://IP_PUBLICO:8080/api/Vagao
```

Os testes CRUD são realizados pelo Postman, incluindo cadastro, consulta, atualização e exclusão de registros.

Para consultar diretamente o Oracle:

```bash
docker exec -i fluxo-oracle sqlplus -s / as sysdba <<'SQL'
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT * FROM FLUXO.TBL_TRENS_2TDSPR;
SELECT * FROM FLUXO.TBL_VAGOES_2TDSPR;
EXIT;
SQL
```

A persistência pode ser demonstrada recriando os containers sem excluir o volume:

```bash
docker compose down
docker compose up -d --wait
```

Os registros cadastrados devem permanecer disponíveis.

## 9. Como Docker e Cloud Computing podem ser utilizados na solução proposta pelo grupo?

O Docker permite executar a API do FLUXO e o banco Oracle em ambientes isolados, facilitando a implantação e a comunicação entre os serviços. Com o Docker Compose, conseguimos gerenciar os containers e preservar os dados utilizando um volume persistente.

Já o Cloud Computing permite disponibilizar a aplicação pela internet. A utilização de uma máquina virtual no Microsoft Azure demonstra como o FLUXO pode ser hospedado na nuvem, servindo como base para futuras integrações com sensores, sistemas de monitoramento e alertas de superlotação.
