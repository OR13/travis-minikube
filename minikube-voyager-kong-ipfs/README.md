# Setup Minikube

[Install Minikube](https://kubernetes.io/docs/setup/minikube/)

# Install Voyager

```
curl -fsSL https://raw.githubusercontent.com/appscode/voyager/7.2.0/hack/deploy/voyager.sh | bash -s -- --provider=minikube
```

Confirm its working:

```
kubectl get pods -n kube-system | grep voyager-operator
```

# Install Kong

Note, we are turning kong proxy TLS off. Voyager, will handle TLS.

```
helm install --name travis-minikube-kong --set proxy.useTLS=false stable/kong 
```

Confirm admin API is working from outside the cluster:

```
KONG_ADMIN_API_URL=$(minikube service --url travis-minikube-kong-kong-admin | sed 's,http://,https://,g')
curl -k $KONG_ADMIN_API_URL/apis/
```

You should see:

```
{"total":0,"data":[]}
```

# Install IPFS

```
helm install --name travis-minikube-ipfs stable/ipfs
```

Configure Kong to route traffic to IPFS API

```
curl -k -X POST \
  --url $KONG_ADMIN_API_URL/apis/ \
  --data 'name=ipfs' \
  --data 'hosts=ipfs.travis.minikube' \
  --data 'upstream_url=http://travis-minikube-ipfs-ipfs.default:5001/'
```

Confirm it is working from outside the cluster:

```
KONG_PROXY_URL=$(minikube service --url travis-minikube-kong-kong-proxy | sed 's,http://,https://,g')
curl -k $KONG_PROXY_URL/api/v0/id -H 'Host: ipfs.travis.minikube'
```

# Configure Voyager Ingress to Kong

```
kubectl apply -f kong-simple-ingress.yaml
```

Confirm its working from outside the cluster:

```
VOYAGER_URL=$(minikube service --url voyager-kong-simple-ingress )
curl -k $VOYAGER_URL/api/v0/id -H 'Host: ipfs.travis.minikube'
```
