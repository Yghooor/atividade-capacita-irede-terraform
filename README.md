# 🌐 Provisionamento de Infraestrutura Isolada na AWS com Terraform

Este repositório contém a entrega da atividade prática do módulo intermediário do **Curso Provisionamento de Serviços Computacionais (PSC)** ofertado pelo **iRede** através do programa **Capacita iRede**. 
O objetivo deste projeto é demonstrar o provisionamento automatizado de uma infraestrutura de rede e computação isolada na AWS utilizando **Infraestrutura como Código (IaC)** com Terraform, estabelecendo um paralelo direto com o Console Web da AWS.

---

## 👨🏽‍💻 Arquitetura AWS: Automatizando com Código vs. Console ☁️

Nos tópicos abaixo descrevo o papel de cada recurso criado na arquitetura para permitir o acesso seguro ao servidor. Também é feito o comparativo de como a informação foi declarada via Código (IaC), e como essa mesma informação será visualizada dentro do console da AWS e o seu papel dentro da infraestrutura.

### 1. Virtual Private Cloud (VPC)
* **No Código (`aws_vpc`):** Declara o bloco CIDR 10.0.0.0/16 com a tag de identificação vpc-lab, conforme solicitado na atividade.
* **No Console AWS:** É visualizada no painel da VPC como uma rede logicamente isolada. Ela funciona como uma "cerca digital", garantindo que nenhum recurso externo acesse o servidor sem rotas e permissões explícitas.

### 2. Sub-rede Pública (Subnet)
* **No Código (`aws_subnet`):** Define o escopo de rede 10.0.1.0/24. A propriedade map_public_ip_on_launch = true força a alocação automatizada de IPs públicos para as instâncias.
* **No Console AWS:** Representa a segmentação interna da VPC onde ficam os recursos públicos. No painel, equivale a marcar a caixa de seleção que ativa a atribuição automática de IPs públicos, permitindo que o servidor seja localizável na internet.

### 3. Internet Gateway (IGW)
* **No Código (`aws_internet_gateway`):** Cria o gateway, e já realiza o vínculo direto à nossa VPC (vpc_id) em uma única operação declarativa.
* **No Console AWS:** Representa a "porta da rua" da nossa infraestrutura. No painel, ele aparece como um componente que precisa ser criado individualmente e, depois, anexado manualmente à VPC para permitir a comunicação bidirecional com a internet. Sem este componente acoplado à VPC, a sub-rede permanece privada e sem qualquer comunicação com a internet externa.

### 4. Tabela de Rotas e Associação (Route Table)
* **No Código (`aws_route_table` & `aws_route_table_association`):** Cria a tabela que mapeia o destino `0.0.0.0/0` para o ID do Internet Gateway e, em seguida, vincula essa tabela à nossa sub-rede pública.
* **No Console AWS:** Atua como o "guarda de trânsito" da rede. No painel, ele direciona ativamente os pacotes que saem da sub-rede pública em direção à internet através do IGW, exigindo que seja configurado explicitamente as abas de "Rotas" e "Associações de Sub-rede".

### 5. Security Group (Firewall)
* **No Código (`aws_security_group`):** Abre a porta de entrada `22 (TCP/SSH)` aplicando o princípio do privilégio mínimo ao restringir o acesso exclusivamente ao IP do administrador (utilizando o sufixo `/32`).
* **No Console AWS:** Funciona como o "vigilante" na porta do servidor (atuando diretamente no nível da instância). No painel, configuramos a aba de "Regras de Entrada" (Inbound Rules) para que o tráfego SSH seja inspecionado e liberado apenas para a origem autorizada. 

### 6. Instância EC2 (Computação)
* **No Código (`aws_instance`):** Provisiona uma máquina virtual de tamanho `t3.micro` baseada na AMI Amazon Linux, vinculando-a diretamente à sub-rede pública e ao Security Group declarados anteriormente.
* **No Console AWS:** Representa o servidor virtualizado em execução. No painel do EC2, é onde monitoramos o status da máquina, visualizamos o IP público gerado e validamos as regras de segurança ativas no hardware.
 
**Nota:📄** Durante a atividade verifiquei que a instância `t2.micro`, conforme solicitado na atividade, não faz mais parte do plano Free Tier. Optei seguir utilizando a instância de geração mais próxima que é contemplada pelo Free Tier, no caso a `t3.micro`.
---

## 📸 Evidências do Provisionamento


### 1. VPC Criada
![VPC Criada](imagens/vpc.png)

### 2. Sub-rede Pública Configurada
![Sub-rede](imagens/subnet.png)

### 3. Tabela de Rotas Associada
![Tabela de Rotas](imagens/route_table.png)
![Tabela de Rotas](imagens/route_table_.png)

### 4. Security Group (Porta 22)
![Security Group input](imagens/security_group_input.png)
![Security Group output](imagens/security_group_output.png)

### 5. Instância EC2 em Execução
![Instância EC2](imagens/ec2.png)

### 6. Acesso SSH Efetuado com Sucesso via Terminal.👨🏽‍💻
![Acesso SSH](imagens/terminal.png)


## 🛠️ Como Executar este Projeto Localmente

1. Certifique-se de ter o **AWS CLI** e o **Terraform** instalados.
2. Autentique-se na sua conta através do terminal:
   ```bash
   aws configure