# FLUXO - DevOps Tools & Cloud Computing

## 1. Sobre o projeto

O FLUXO é uma plataforma desenvolvida para a Global Solution 2026/2 da FIAP, com o objetivo de monitorar a lotação de metrôs e trens, auxiliando passageiros e operadores na identificação de situações de superlotação.

Na disciplina de DevOps Tools & Cloud Computing, realizamos a implantação de uma API .NET 8 integrada a um banco Oracle, utilizando containers Docker em uma máquina virtual Linux hospedada no Microsoft Azure.

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
- Azure CLI e Azure Cloud Shell
- Linux Ubuntu 24.04
- Git e GitHub
- Postman

## 4. Arquitetura

A aplicação utiliza dois containers Docker executados em uma máquina virtual Ubuntu 24.04 no Microsoft Azure.

O container `fluxo-api` executa a API .NET 8 na porta 8080, enquanto o `fluxo-oracle` armazena os dados no Oracle, utilizando a porta interna 1521.

Os serviços se comunicam pela rede Docker `fluxo-network`. A persistência dos dados é garantida pelo volume `fluxo-oracle-data`, que mantém os registros mesmo após a remoção dos containers.

A API utiliza um Dockerfile multi-stage, separando as etapas de compilação e execução, e é executada com um usuário não-root.

O acesso externo ocorre pelo IP público da VM, utilizando a porta 8080, liberada por uma regra do Network Security Group (NSG).

**Diagrama de arquitetura:**

<img width="739" height="365" alt="image" src="https://github.com/user-attachments/assets/183eb0b9-d70d-489c-8b5a-5b1f0222c123" />


## 5. API

A API do FLUXO foi desenvolvida utilizando C#, ASP.NET Core 8, Entity Framework Core e Oracle.

Código original disponível no repositório: [FLUXO_GS_2026_NET](https://github.com/pgmoraesdev/FLUXO_GS_2026_NET).

Para esta entrega, a API foi utilizada como base para a conteinerização, integração com o Oracle em Docker e implantação no Microsoft Azure.

## 6. Funcionalidades da API

A API disponibiliza operações CRUD para estações, plataformas, trens e vagões.

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
| GET | `/api/Vagao/{id}/lotacao` | Consultar lotação do vagão |
| GET | `/api/Plataforma/{id}/avaliar-capacidade?tremId={idDoTrem}` | Avaliar capacidade disponível |

As entidades também possuem operações de consulta por ID, atualização e exclusão.

## 7. Provisionamento no Azure

A infraestrutura é criada utilizando a Azure CLI, por meio do script `scripts/azure-cli.sh`.

No Portal do Azure, abra o **Azure Cloud Shell** e selecione Bash.

### Clonar o repositório

```bash
git clone https://github.com/ismrqs/fluxo-gs-devops.git
cd fluxo-gs-devops
```

### Criar a infraestrutura

```bash
bash scripts/azure-cli.sh
```

O script realiza:

- Criação do grupo de recursos `rg-fluxo-video`.
- Provisionamento da VM `vm-fluxo-video` com Ubuntu 24.04.
- Configuração de autenticação por SSH.
- Liberação da porta 8080 para acesso à API.

### Verificar a VM

```bash
az vm show \
  --resource-group rg-fluxo-video \
  --name vm-fluxo-video \
  --show-details \
  --output table
```

Consultar o IP público:

```bash
az vm list-ip-addresses \
  --resource-group rg-fluxo-video \
  --name vm-fluxo-video \
  --output table
```

### Conectar à VM

```bash
ssh azureuser@IP_PUBLICO
```

Substitua `IP_PUBLICO` pelo endereço retornado pela Azure CLI. O acesso SSH pela porta 22 deve estar permitido no NSG para a origem utilizada.

## 8. Implantação com Docker

Os comandos desta seção devem ser executados **dentro da máquina virtual Ubuntu**.

### Clonar o projeto

```bash
git clone https://github.com/ismrqs/fluxo-gs-devops.git
cd fluxo-gs-devops
```

### Instalar o Docker

```bash
bash scripts/instalar-docker.sh
```

Adicionar o usuário ao grupo Docker:

```bash
sudo usermod -aG docker "$USER"
```

Encerre a conexão SSH e conecte-se novamente para aplicar a permissão. O grupo Docker concede privilégios elevados ao usuário.

Verifique a instalação:

```bash
docker --version
docker compose version
docker run --rm hello-world
```

### Executar a implantação

Após configurar o banco conforme a seção 9, valide o Compose e execute:

```bash
docker compose config --quiet
bash scripts/deploy.sh
```

O script constrói a imagem da API, inicia os containers, aguarda a inicialização do Oracle, aplica as migrations do Entity Framework Core e testa a comunicação com a aplicação.

### Verificar os containers e imagens

```bash
docker ps
docker compose ps
docker images
```

Os containers esperados são:

- `fluxo-api`: API ASP.NET Core 8.
- `fluxo-oracle`: Oracle Database Free.

### Verificar os logs

```bash
docker logs --tail 50 fluxo-api
docker logs --tail 50 fluxo-oracle
```

Para acompanhar os logs em tempo real:

```bash
docker compose logs -f
```

Pressione `Ctrl + C` para interromper.

### Verificar o usuário não-root

```bash
docker exec fluxo-api id
```

O resultado deve apresentar um UID diferente de zero, confirmando que a API não está sendo executada como root.

### Verificar a rede Docker

```bash
docker network ls
docker network inspect fluxo-network
```

A rede `fluxo-network` permite a comunicação interna entre a API e o Oracle, sem expor a porta 1521 publicamente.

## 9. Banco de dados Oracle

O projeto utiliza o Oracle Database Free, executado em um container Docker.

Não é necessário instalar o Oracle diretamente na máquina virtual ou criar manualmente as tabelas.

### Configurar o banco

Dentro da pasta do projeto, crie o arquivo `.env`:

```bash
cp .env.example .env
nano .env
```

Configure a variável:

```env
ORACLE_PASSWORD=SUA_SENHA_FORTE
```

Salve o arquivo e proteja suas permissões:

```bash
chmod 600 .env
```

O arquivo `.env` não deve ser enviado ao GitHub.

### Configurações utilizadas

| Configuração | Valor |
| --- | --- |
| Banco | Oracle Database Free |
| Container | `fluxo-oracle` |
| Usuário | `FLUXO` |
| Serviço | `FREEPDB1` |
| Porta interna | `1521` |
| Endereço utilizado pela API | `oracle:1521/FREEPDB1` |
| Volume | `fluxo-oracle-data` |

Ao executar `bash scripts/deploy.sh`, o Docker Compose inicia o banco e configura o usuário `FLUXO`. O script também aplica as migrations, responsáveis pela criação e atualização das tabelas da aplicação.

### Consultar as tabelas

```bash
docker exec -i fluxo-oracle sqlplus -s / as sysdba <<'SQL'
ALTER SESSION SET CONTAINER = FREEPDB1;

SELECT table_name
FROM all_tables
WHERE owner = 'FLUXO'
ORDER BY table_name;

EXIT;
SQL
```

### Consultar os registros cadastrados

```bash
docker exec -i fluxo-oracle sqlplus -s / as sysdba <<'SQL'
ALTER SESSION SET CONTAINER = FREEPDB1;

SELECT * FROM FLUXO.TBL_TRENS_2TDSPR;
SELECT * FROM FLUXO.TBL_VAGOES_2TDSPR;

EXIT;
SQL
```

Essas consultas permitem verificar diretamente no Oracle os registros enviados pela API.

## 10. Testes da API com Postman

O Postman é utilizado para demonstrar as operações CRUD da API, incluindo cadastro, consulta, atualização e exclusão de registros.

O repositório disponibiliza duas coleções:

- `Fluxo.postman_collection.json`: coleção completa, com CRUDs, validações e consultas de lotação.
- `Fluxo.demonstracao.postman_collection.json`: coleção reduzida, preparada para a apresentação.

### Importar a coleção

1. Abra o Postman e clique em **Import**.
2. Selecione `Fluxo.demonstracao.postman_collection.json`.
3. Abra a coleção importada e acesse **Variables**.
4. Configure a variável `baseUrl`:

```text
http://IP_PUBLICO:8080
```

5. Salve a configuração e execute as requisições na ordem indicada pela coleção.

### Operações CRUD

| Método | Endpoint | Resultado esperado |
| --- | --- | --- |
| POST | `/api/Trem` | Cadastrar trem — `201 Created` |
| GET | `/api/Trem` | Listar trens — `200 OK` |
| PUT | `/api/Trem/{id}` | Atualizar trem — `204 No Content` |
| POST | `/api/Vagao` | Cadastrar vagão vinculado ao trem — `201 Created` |
| GET | `/api/Vagao` | Consultar vagões — `200 OK` |
| PUT | `/api/Vagao/{id}` | Atualizar vagão — `204 No Content` |
| DELETE | `/api/Vagao/{id}` | Excluir vagão — `204 No Content` |
| DELETE | `/api/Trem/{id}` | Excluir trem — `204 No Content` |

Os IDs devem corresponder aos registros criados durante os testes.

O Postman envia as requisições HTTP para a API hospedada na Azure. A API processa as operações e utiliza o Entity Framework Core para armazenar ou consultar os dados no Oracle.

Para comprovar a integração, os registros cadastrados pelo Postman também são consultados diretamente no banco utilizando `docker exec` e comandos SQL.

## 11. Volume e persistência dos dados

O Oracle utiliza o volume Docker `fluxo-oracle-data`, responsável por preservar os registros mesmo após a remoção dos containers.

### Verificar o volume

```bash
docker volume ls
docker volume inspect fluxo-oracle-data
```

### Demonstrar a persistência

Primeiro, cadastre um trem e um vagão utilizando o Postman.

Consulte os registros:

```bash
curl http://localhost:8080/api/Trem
curl http://localhost:8080/api/Vagao
```

Pare e remova os containers:

```bash
docker compose down
```

Confirme que o volume continua disponível:

```bash
docker volume ls
```

Inicie novamente os serviços:

```bash
docker compose up -d --wait
```

Consulte os mesmos registros:

```bash
curl http://localhost:8080/api/Trem
curl http://localhost:8080/api/Vagao
```

Os dados cadastrados anteriormente devem permanecer disponíveis, demonstrando a persistência do banco Oracle.

**Importante:** não utilize `docker compose down -v`, pois essa opção remove o volume declarado pelo projeto.

## 12. Testes em nuvem e evidências técnicas

Após a implantação, a API pode ser acessada pelo IP público da máquina virtual:

```bash
curl -i http://IP_PUBLICO:8080/api/Trem
curl -i http://IP_PUBLICO:8080/api/Vagao
```

O retorno `HTTP 200 OK` indica que os endpoints estão respondendo corretamente.

### Evidências da implantação

| Evidência | Comando ou ferramenta |
| --- | --- |
| Provisionamento da VM | Azure CLI |
| VM criada e IP público | `az vm show` |
| Containers em execução | `docker compose ps` |
| Imagens Docker | `docker images` |
| Logs da aplicação | `docker logs fluxo-api` |
| Logs do banco | `docker logs fluxo-oracle` |
| Usuário não-root | `docker exec fluxo-api id` |
| Rede interna | `docker network inspect fluxo-network` |
| Volume persistente | `docker volume inspect fluxo-oracle-data` |
| Acesso externo à API | `curl` pelo IP público |
| Operações CRUD | Postman |
| Registros no Oracle | `docker exec` e `SELECT` |
| Persistência dos dados | `docker compose down` e `up` |

Essas verificações demonstram o funcionamento da infraestrutura, a integração entre os containers e a persistência dos registros no banco de dados.

## 13. Encerramento dos recursos Azure

Após finalizar os testes e salvar as evidências, os recursos podem ser excluídos pelo Azure Cloud Shell:

```bash
az group delete --name rg-fluxo-video --yes
```

Para confirmar a exclusão:

```bash
az group exists --name rg-fluxo-video
```

Após a conclusão, o resultado esperado é `false`.

A exclusão do grupo de recursos remove a máquina virtual e os recursos associados, incluindo os discos. Esse procedimento deve ser realizado somente após a conclusão da demonstração.

## 14. Como Docker e Cloud Computing podem ser utilizados na solução proposta pelo grupo?

O Docker permite executar a API do FLUXO e o banco Oracle em ambientes isolados, facilitando a implantação e a comunicação entre os serviços. Com o Docker Compose, conseguimos gerenciar os containers e preservar os dados utilizando um volume persistente.

Já o Cloud Computing permite disponibilizar a aplicação pela internet. A utilização de uma máquina virtual no Microsoft Azure demonstra como o FLUXO pode ser hospedado na nuvem, servindo como base para futuras integrações com sensores, sistemas de monitoramento e alertas de superlotação.
