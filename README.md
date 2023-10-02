# Herramientas
Para desarrollar las soluciones ha sido necesario instalar y/o configurar las siguientes herramientas:

- Minikube
- Helm
- Terraform
- Homebrew
- Pingctl
- Chartmuseum
- Github runner

* * *

# Challenge 1
Modify the Ping Helm Chart to deploy the application on the following restrictions:
• Isolate specific node groups forbidding the pods scheduling in this node
groups.
• Ensure that a pod will not be scheduled on a node that already has a pod
of the same type.
• Pods are deployed across different availability zones.


## Solución
Se ha tomado como referencia una instalación básica con solo los deployments pingfederate-admin y pingfederate-engine como se indica en "https://helm.pingidentity.com/getting-started".

Los requisitos del reto solo serán aplicados sobre pingfederate-engine para mantener la simpleza de la prueba, pingfederate-admin solo será activado. Las mismas ideas podrían ser aplicadas al resto de deployments revisando las particularidades de cada uno o aplicándolas a nivel global.

Por como está desarrollado el chart de ping, solo es necesario crear un fichero values custom, no necesitamos realizar modificaciones más profundas. En este caso por la combinación con los challenges 2 y 3 solo será modificado el values.yaml por simpleza.

- **Isolate specific node groups:** En este supuesto, los nodos tendrán un label "group" y se evitará que los pods se desplieguen en los grupos de nodos prohibidos mediante normas de afinidad de nodo. "Solo puedes desplegarte en los nodos que no pertenezcan a determinado grupo".
- **Solo un pod del mismo tipo por nodo**: Mediante normas de anti afinidad de los pods podemos definir que un pod no debe desplegarse sobre un nodo que ya tenga un pod con determinado string, el nombre parcial del pod. Sería interesante implementar una solución más dinámica que pudiese configurarse de forma global.
- **Pods are deployed across different availability zones**: En este supuesto, los nodos tendrán el label "topology.kubernetes.io/zone" con eu-east, eu-west, etc, simulando una región. Mediante normal de afinidad de nodo podremos definir las regiones en las que queramos desplegar los pods. "Solo puedes desplegarte en los nodos de determinadas regiones"

**Nota:** Con esta configuración los nodos no "saltan" entre nodos según cambien las circunstancias(labels) una vez estén alojados.

**Ejecución:**
`helm install pf ./ --values ./values.yaml`

* * *

# Challenge 2
We have a private registry based on Azure Container Registry where we publish
all our Helm charts. Let’s call this registry reference.azurecr.io.
When we create an AKS cluster, we also create another Azure Container Registry
where we need to copy the Helm charts we are going to install in that AKS from
the reference registry. Let’s call this registry instance.azurecr.io and assume it
resides in an Azure subscription with ID c9e7611c-d508-4fbf-aede-0bedfabc1560.
As we work with Terraform to install our charts in our AKS cluster, we’ve
thought that it would be quite helpful to have a reusable module that allows us
to import a set of charts from the reference registry to the instance registry
using a local provisioner and install them on our AKS cluster.

You need to implement the reusable module. It should pass validations provided
by the terraform fmt and terraform validate commands.
You can assume the caller will be authenticated in Azure with enough permissions
to import Helm charts into the instance registry and will provide the module a
configured helm provider.


## Solución
Requisitos solicitados implementados.

Se parte de la idea de utilizar el chart con el values.yaml por defecto modificado, de forma que solo haya que setear los valores clave. En un caso real, values.yaml tendría una configuración más genérica, no tendría los grupos o regiones pre configurados. Se ha decidido mantenerlos así para seguir cumpliendo el challenge 1 por sí solo.

La idea de la lista de values para cada chart debería ser válida para todo tipo de datos, tanto strings como listas, de forma que podamos setear los grupos prohibidos o las regiones. No ha sido posible encontrar una solución para setear las listas dentro del tiempo establecido, por ese motivo están comentadas en el código. Es cuestión de tiempo encontrar una solución o alternativa.

Dado que se especifica  como requisito la obtención de los charts de un registry e importación de charts sobre otro, carece de sentido la duplicidad del registry a nivel de chart. Ya que nunca va a ser utilizado, este campo ha sido comentado por este motivo. Una posible utilidad y mejora para este campo podría ser la posibilidad de sobrescribir el repositorio de referencia si el chart tiene uno propio establecido. "Si un chart tiene un repositorio propio, utilízalo en lugar del global de referencia".

La solución pasa terraform fmt, validate y ha sido probado parcialmente, todo funcional, salvo la copia de charts del acr de referencia al acr de destino debido a la falta de acceso a 2 acrs.

**Ejecución:**
```
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

* * *

# Challenge 3
Create a Github workflow to allow installing helm chart from Challenge #1
using module from Challenge #2, into an AKS cluster (considering a preexisting
resource group and cluster name).


## Solución
Añadida github action para validar y desplegar el challenge 1 mediante el challenge 2.
Reacciona a las PRs y push de la rama master. Las PRs lanzarán la validación y añadirán un comentario con un resumen, mientras que un push validará y aplicará los cambios.
Actualmente, sería necesario obtener el .kube/config como base64 de un secret y guardarlo como fichero en la ruta adecuada y esperada por terraform en el contexto de la github action. Esto no cumple los requisitos del challenge 3 por falta de tiempo y de acceso a un aks para poder probarlo.

La pipeline se lanza correctamente aplicando los ficheros de terraform fallando en el punto de intentar copiar los charts del ACR de origen al ACR de destino.