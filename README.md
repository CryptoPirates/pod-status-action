# Pod Status Action
Checks to see if a given pod is running in GKE.

## Inputs

### `gkeApplicationCredentials`

**Required** The service account credentials JSON file encoded as a base64 string to access the GKE API.

### `gkeNamespace`

**Required** The Kubernetes cluster's namespace.

### `gkeProjectID`

**Required** The GKE project identifier (kube-cluster-12345).

### `gkeClusterName`

**Required** The name of the Kubernetes cluster.

### `gkeLocationZone`

**Required** The cluster's location zone.

### `podName`

**Required** A pod name to check.

## Example usage

```yaml
uses: cryptopirates/pod-status-action@master
with:
    gkeApplicationCredentials: ${{ secrets.GKE_APPLICATION_CREDENTIALS }}
    gkeNamespace: ${{ secrets.GKE_NAMESPACE }}
    gkeProjectID: ${{ secrets.GKE_PROJECT_ID }}
    gkeClusterName: ${{ secrets.GKE_CLUSTER_NAME }}
    gkeLocationZone: ${{ secrets.GKE_LOCATION_ZONE }}
    podName: ${{ secrets.POD_NAME }}
```