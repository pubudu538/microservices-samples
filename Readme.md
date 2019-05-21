# Microservice sample

![alt text](https://raw.githubusercontent.com/pubudu538/microservices-samples/master/services.png)

*Note:* Tested on Ballerina v0.991.0 version.

```
- Use EXTERNAL-IP as INGRESS_GATEWAY_IP from the following command
kubectl get svc istio-ingressgateway -n istio-system

- Use the output of the above as INGRESS_GATEWAY_PORT
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}'

Note: In Docker for Mac INGRESS_GATEWAY_PORT is port 80.
```

