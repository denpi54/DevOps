Kubernetes logging:
- Apply ingress-nginx via manifest or Helm.
- Apply Fluent Bit ConfigMap and DaemonSet from `k8s/logging/fluent-bit/`.
- Replace `REPLACE_WITH_SRV_IP` in fluent-bit config with actual srv IP.
