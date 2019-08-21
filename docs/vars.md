# Configurable Parameters in KubeSphere

installer configuration, used when install a KubeSphere
```yaml
# kubernetes apiserver configuration
apiserver:
  endpoints:
    - https://192.168.0.2:6443
    - https://192.168.0.3:6443
    - https://192.168.0.3:6443

# etcd configuration
etcd:
  caFile: /etc/kubernetes/etcd/etcd.ca
  certFile: /etc/kubernetes/etcd/etcd.crt
  keyFile: /etc/kubernetes/etcd/etcd.key
  endpoints:
    - https://192.168.0.8:2379
    - https://192.168.0.9:2379
    - https://192.168.0.7:2379

metricsServer:
  # install has three values ["interal","external","disable"]
  # internal means installed defaultly by installer
  # external means provider by user 
  # disable means disable this component entirely. 
  # When type is external, user is responsible for providing required info, such endpoint address/authentiation etc.
  install: "internal"

# Kubesphere 
kubesphere:
  ks-console:
    disableMultiLogin: True  # enable/disable multi login

  mysql:
    install: "internal"/"external"/"disable"
  
  redis:
    install: "internal"/"external"/"disable"
    address: redis.kubesphere-system.svc:6379
    password: $@$!#!#

  monitoring:
    install: "internal"  
    replicas: 2  
    volumeSize: 20G
    endpoint: http://prometheus.kubesphere.svc:8088
  
  logging:
    install: "internal"
    elkPrefix: logstash
    volumeSize: 20G
    logMaxAge: 7d
    containerLogPath: /var/log/containers
    endpoint: http://elasticsearch-logging.kubesphere-system.svc:9200
  
  openPitrix:
    install: "internal"
    apigateway:
      endpoint: http://api.openpitrix.svc:9100
  
  devops:
    install: "internal"
    endpoint: http://devops.kubesphere-system.svc:9000
    sonarqube:
      type: "internal"

  servicemesh:
    install: "internal"
    
  notification:
    install: "internal"

  alert:
    install: "internal"
  
  storage:
    storageClass: ""
```


KubeSphere Configuration, shared by kubesphere component. Installer is response for creating this configmap. If there is no configuration section in kubesphere.yaml, means component is disabled.
```yaml
apiVersion: v1
data:
  kubesphere.yaml: |
    # kubernetes apiserver configuration
    apiserver:
      endpoints:
        - https://192.168.0.2:6443
        - https://192.168.0.3:6443
        - https://192.168.0.3:6443
    
    # etcd configuration
    etcd:
      caFile: /etc/kubernetes/etcd/etcd.ca
      certFile: /etc/kubernetes/etcd/etcd.crt
      keyFile: /etc/kubernetes/etcd/etcd.key
      endpoints:
        - https://192.168.0.8:2379
        - https://192.168.0.9:2379
        - https://192.168.0.7:2379
    
    metricsServer:
      endpoint: http://metrics-server.kubernetes.svc:6603
    
    # Kubesphere 
    kubesphere:
      ks-console:
        disableMultiLogin: True  # enable/disable multi login

      mysql:
        username: root
        password: #@$%$#
        address: mysql.kubesphere-system.svc:3306
      
      redis:
        address: redis.kubesphere-system.svc:6379
        password: $@$!#!#

      monitoring:
        endpoint: http://prometheus.kubesphere.svc:8088
      
      logging:
        endpoint: http://elasticsearch-logging.kubesphere-system.svc:9200
      
      openpitrix:
        apigateway:
          endpoint: http://api.openpitrix.svc:9100
      
      devops:
        endpoint: http://devops.kubesphere-system.svc:9000
        sonarqube:
          token: 
          endpoint: http://sonarqube.kubesphere-system.svc:9000

      servicemesh:
        tracing:
          endpoint: http://jaeger.kubesphere-system.svc:8000
        moinitoring:
          endpoint: http://prometheus.kubesphere-system.svc:8008
        
      notification:
        endpoint: http://notification.kubesphere-system.svc:9000

      alert:
        endpoint: http://alert.kubesphere-system.svc:8000
      
      storage:
        storageClass: "csi-qingcloud"

kind: ConfigMap
metadata:
  name: kubesphere-config
  namespace: kubesphere-system
```
