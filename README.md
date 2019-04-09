# kubebck
[![Build Status](https://travis-ci.org/amimof/kubebck.svg?branch=master)](https://travis-ci.org/amimof/kubebck) 
---

Kubernetes resource backup and exporter. `kubbck` relies on `kubectl` to export kubernetes resources from one or more clusters. The exported resources are stored as `yaml` files on the filesystem.

# How to run
The easiest and best way of running kubebck is by using `Docker`. You need to provide a `kubeconfig` file to the container as well as a storage area for the exported data. We can use a volume mount for this.  
```
docker run \
  -d --privileged \
  -v /var/lib/kubebck/data/:/kubebck \
  -v /var/lib/kubebck/config:/config \
  amimof/kubebck:latest
```
This example will connect to the Kubernetes clusters using the contexts defined in the provided kubeconfig file and store exported data to `/var/lib/kubebck/data` on the container host. After the kubebck container is finished backing up all clusters, the container will terminate and the content of the output directory will look something like this.
```
├── minikube
|   ├── 2019-03-21
|   |   ├── clusterrolebindings.yaml 
|   |   ├── clusterroles.yaml
        ...
|   |   ├── groups.yaml
|   |   ├── namespaces                                                             
|   |   │   ├── default
|   |   |   |   ├── configmaps.yaml
|   |   |   |   ├── deployments.yaml
|   |   |   |   ├── pods.yaml
                ...
|   |   |   |   └── statefulsets.yaml      
|   |   |   ├── kube-public
|   |   │   └── kube-system
|   |   ├── namespaces.yaml
|   |   ├── nodes.yaml
        ...
|   |   └── persistentvolumes.yaml
|   ├── 2019-04-09
     ...
├── minishift
|   ├── 2019-03-21
    ...
```

# Contribute
All help in any form is highly appreciated and your are welcome participate in developing together. To contribute submit a Pull Request. If you want to provide feedback, open up a Github Issue or contact me personally.