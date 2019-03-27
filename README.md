# kubernetes-crd-test
To test various Kubernetes CRD configurations

## Requirements to run the tests
- Kubernetes v1.14 with ```--feature-gates=CustomResourcePublishOpenAPI=true``` as documented here https://kubernetes.io/docs/tasks/access-kubernetes-api/custom-resources/custom-resource-definitions/#publish-validation-schema-in-openapi-v2
- kubectl v1.14

## Test Case #1
Basic CRD without any openAPI spec
```yaml
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
  version: v1
  scope: Namespaced
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
```
```sh
>sh -x test.sh crontab-crd-no-spec.yaml
+ kubectl delete crontabs --all --ignore-not-found=true
No resources found
+ kubectl delete crd crontabs.stable.example.com --ignore-not-found=true
customresourcedefinition.apiextensions.k8s.io "crontabs.stable.example.com" deleted
+ kubectl apply -f crontab-crd-no-spec.yaml
customresourcedefinition.apiextensions.k8s.io/crontabs.stable.example.com created
+ sleep 3
+ kubectl explain crontab --recursive
KIND:     CronTab
VERSION:  stable.example.com/v1

DESCRIPTION:
     <empty>
```

## Test Case #2
CRD with openAPI but spec type not set to anything
```yaml
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
  version: v1
  scope: Namespaced
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
  validation:
    openAPIV3Schema:
      properties:
        spec:
          properties:
            cronSpec:
              type: string
              pattern: '^(\d+|\*)(/\d+)?(\s+(\d+|\*)(/\d+)?){4}$'
            replicas:
              type: integer
              minimum: 1
              maximum: 10
```
```sh
sh -x test.sh crontab-crd-non-object-spec.yaml
+ kubectl delete crontabs --all --ignore-not-found=true
No resources found
+ kubectl delete crd crontabs.stable.example.com --ignore-not-found=true
customresourcedefinition.apiextensions.k8s.io "crontabs.stable.example.com" deleted
+ kubectl apply -f crontab-crd-non-object-spec.yaml
customresourcedefinition.apiextensions.k8s.io/crontabs.stable.example.com created
+ sleep 3
+ kubectl explain crontab --recursive
KIND:     CronTab
VERSION:  stable.example.com/v1

DESCRIPTION:
     <empty>

FIELDS:
   apiVersion	<string>
   kind	<string>
   metadata	<Object>
      annotations	<map[string]string>
      clusterName	<string>
      creationTimestamp	<string>
      deletionGracePeriodSeconds	<integer>
      deletionTimestamp	<string>
      finalizers	<[]string>
      generateName	<string>
      generation	<integer>
      initializers	<Object>
         pending	<[]Object>
            name	<string>
         result	<Object>
            apiVersion	<string>
            code	<integer>
            details	<Object>
               causes	<[]Object>
                  field	<string>
                  message	<string>
                  reason	<string>
               group	<string>
               kind	<string>
               name	<string>
               retryAfterSeconds	<integer>
               uid	<string>
            kind	<string>
            message	<string>
            metadata	<Object>
               continue	<string>
               resourceVersion	<string>
               selfLink	<string>
            reason	<string>
            status	<string>
      labels	<map[string]string>
      managedFields	<[]Object>
         apiVersion	<string>
         fields	<map[string]>
         manager	<string>
         operation	<string>
         time	<string>
      name	<string>
      namespace	<string>
      ownerReferences	<[]Object>
         apiVersion	<string>
         blockOwnerDeletion	<boolean>
         controller	<boolean>
         kind	<string>
         name	<string>
         uid	<string>
      resourceVersion	<string>
      selfLink	<string>
      uid	<string>
   spec	<>
```

## Test Case #3
CRD with openAPI plus spec.type = object.  It's a small change from #2 but as you will see it makes a huge difference.
```yaml
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
  version: v1
  scope: Namespaced
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
  validation:
    openAPIV3Schema:
      properties:
        spec:
          type: object
          properties:
            cronSpec:
              type: string
              pattern: '^(\d+|\*)(/\d+)?(\s+(\d+|\*)(/\d+)?){4}$'
            replicas:
              type: integer
              minimum: 1
              maximum: 10
```
```sh
sh -x test.sh crontab-crd-object-spec.yaml
+ kubectl delete crontabs --all --ignore-not-found=true
No resources found
+ kubectl delete crd crontabs.stable.example.com --ignore-not-found=true
customresourcedefinition.apiextensions.k8s.io "crontabs.stable.example.com" deleted
+ kubectl apply -f crontab-crd-object-spec.yaml
customresourcedefinition.apiextensions.k8s.io/crontabs.stable.example.com created
+ sleep 3
+ kubectl explain crontab --recursive
KIND:     CronTab
VERSION:  stable.example.com/v1

DESCRIPTION:
     <empty>

FIELDS:
   apiVersion	<string>
   kind	<string>
   metadata	<Object>
      annotations	<map[string]string>
      clusterName	<string>
      creationTimestamp	<string>
      deletionGracePeriodSeconds	<integer>
      deletionTimestamp	<string>
      finalizers	<[]string>
      generateName	<string>
      generation	<integer>
      initializers	<Object>
         pending	<[]Object>
            name	<string>
         result	<Object>
            apiVersion	<string>
            code	<integer>
            details	<Object>
               causes	<[]Object>
                  field	<string>
                  message	<string>
                  reason	<string>
               group	<string>
               kind	<string>
               name	<string>
               retryAfterSeconds	<integer>
               uid	<string>
            kind	<string>
            message	<string>
            metadata	<Object>
               continue	<string>
               resourceVersion	<string>
               selfLink	<string>
            reason	<string>
            status	<string>
      labels	<map[string]string>
      managedFields	<[]Object>
         apiVersion	<string>
         fields	<map[string]>
         manager	<string>
         operation	<string>
         time	<string>
      name	<string>
      namespace	<string>
      ownerReferences	<[]Object>
         apiVersion	<string>
         blockOwnerDeletion	<boolean>
         controller	<boolean>
         kind	<string>
         name	<string>
         uid	<string>
      resourceVersion	<string>
      selfLink	<string>
      uid	<string>
   spec	<Object>
      cronSpec	<string>
      replicas	<integer>
```
