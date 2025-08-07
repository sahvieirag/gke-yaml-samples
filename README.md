# Testes de Conceitos no GKE com YAMLs

Este repositório contém uma coleção de arquivos YAML para demonstrar e testar diferentes conceitos no Google Kubernetes Engine (GKE). O fluxo abaixo foi projetado para guiá-lo através de cenários práticos, desde a execução de Jobs em diferentes modos de GKE até o gerenciamento avançado de recursos e agendamento de pods.

## Pré-requisitos

- Um cluster GKE ativo. Alguns exemplos são específicos para os modos `Autopilot` ou `Standard`.
- `kubectl` configurado para se conectar ao seu cluster.
- `gcloud` CLI autenticada e configurada com um projeto padrão.

## Fluxo de Testes

Siga os passos na ordem para uma compreensão progressiva dos conceitos.

### 1. Jobs em GKE Standard vs. Autopilot

Começamos com a execução de Jobs para entender as diferenças fundamentais entre os modos de operação do GKE.

#### GKE Standard

Neste modo, você gerencia os nós e precisa especificar os recursos que seus pods necessitam.

**Aplique o Job:**
```bash
kubectl apply -f job-standard.yaml
```

**Observe:**
- O pod do Job terá `requests` de CPU e memória definidos.
- O GKE agendará este pod em um nó que possa atender a essa solicitação de recursos.

#### GKE Autopilot

No Autopilot, o GKE gerencia os nós para você, e a especificação de recursos não é estritamente necessária para cargas de trabalho simples.

**Aplique o Job:**
```bash
kubectl apply -f job-autopilot.yaml
```

**Observe:**
- O GKE provisionará automaticamente a infraestrutura necessária para executar o Job, sem que você precise gerenciar os nós.

### 2. Classes de Qualidade de Serviço (QoS)

O Kubernetes classifica os pods em diferentes classes de QoS com base em seus `requests` e `limits` de recursos.

#### BestEffort

Pods `BestEffort` não têm `requests` nem `limits` de recursos definidos. Eles são os primeiros a serem terminados se os nós ficarem sem recursos.

**Aplique o Deployment:**
```bash
kubectl apply -f deploy-best-effort.yaml
```

**Verifique a classe de QoS (opcional):**
```bash
kubectl describe pod <NOME_DO_POD_HELLO-SERVER-BEST-EFFORT> | grep "QoS Class"
```
A saída será `BestEffort`.

### 3. Agendamento Avançado com Node Auto-Provisioning (NAP)

O NAP no GKE Standard cria e gerencia nós automaticamente com base nas especificações dos seus pods. Usamos `nodeSelector` para solicitar tipos específicos de nós.

#### Agendamento em Nós Spot

VMs Spot são mais baratas, mas podem ser preemptadas. São ideais para cargas de trabalho tolerantes a falhas.

**Aplique o Deployment:**
```bash
kubectl apply -f deploys-nap.yaml
```

**Observe:**
- O primeiro deployment (`hello-server-nap-spot`) solicita um nó Spot com o seletor `cloud.google.com/gke-spot: "true"`.
- O segundo (`hello-server-nap-t2d`) solicita um nó da família de máquinas T2D com `cloud.google.com/gke-machine-family: "t2d"`.
- Se não houver nós que atendam a esses seletores, e o NAP estiver ativado, o GKE criará novos node pools para você.

### 4. Criação de Node Pool para Cargas de Trabalho em Lote (Batch)

Para otimizar a execução de cargas de trabalho em lote (Jobs), podemos criar um `node pool` dedicado com VMs Spot, que são mais econômicas. O script `job-nodepool.sh` automatiza essa criação.

**Antes de executar, configure as variáveis de ambiente com seus dados:**
```bash
export PROJECT_ID="seu-gcp-project-id"
export CLUSTER_NAME="seu-cluster-gke"
export REGION="sua-regiao-gcp"
```

**Execute o script para criar o node pool:**
```bash
bash job-nodepool.sh
```

**Observe:**
- O script cria um `node pool` chamado `jobs-spot-pool` com VMs Spot.
- Ele utiliza `taints` e `labels` (`workload-type=batch`) para garantir que apenas pods com a `toleration` e `nodeSelector` correspondentes sejam agendados neste `node pool`. Isso isola as cargas de trabalho em lote.

### 5. Gerenciamento Automático de Recursos com Vertical Pod Autoscaler (VPA)

O VPA ajusta automaticamente os `requests` de CPU e memória dos pods em um deployment, otimizando o uso de recursos.

**Aplique o Deployment e o VPA:**
```bash
kubectl apply -f vpa-deploys.yaml
```

**Observe:**
- Um deployment `hello-server-vpa` é criado.
- Um objeto `VerticalPodAutoscaler` é configurado para monitorar e ajustar este deployment.
- Com o tempo, o VPA analisará o uso de recursos dos pods e os reiniciará com valores de `requests` mais adequados.

**Para verificar as recomendações do VPA:**
```bash
kubectl describe vpa hello-server-vpa
```

## Limpeza

Para remover todos os recursos criados durante este fluxo, execute os seguintes comandos. Para o `node pool`, certifique-se de usar as mesmas variáveis de ambiente que usou para a criação.

```bash
# Deleta os recursos do Kubernetes
kubectl delete -f job-standard.yaml
kubectl delete -f job-autopilot.yaml
kubectl delete -f deploy-best-effort.yaml
kubectl delete -f deploys-nap.yaml
kubectl delete -f vpa-deploys.yaml

# Deleta o node pool (use os mesmos valores de variáveis de ambiente da criação)
gcloud container node-pools delete jobs-spot-pool \
  --cluster ${CLUSTER_NAME} \
  --project ${PROJECT_ID} \
  --region ${REGION} \
  --quiet
```
