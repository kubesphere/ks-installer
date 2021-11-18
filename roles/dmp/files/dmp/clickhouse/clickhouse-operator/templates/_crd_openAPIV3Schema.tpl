{{- define "clickhouseinstallations.openAPIV3Schema" }}
openAPIV3Schema:
  x-kubernetes-preserve-unknown-fields: true
  type: object
  properties:
    spec:
      type: object
      properties:
        # Need to be StringBool
        stop:
          type: string
          enum:
            # List StringBoolXXX constants from model
            - ""
            - "0"
            - "1"
            - "False"
            - "false"
            - "True"
            - "true"
            - "No"
            - "no"
            - "Yes"
            - "yes"
            - "Off"
            - "off"
            - "On"
            - "on"
            - "Disabled"
            - "disabled"
            - "Enabled"
            - "enabled"
        namespaceDomainPattern:
          type: string
        templating:
          type: object
          properties:
            policy:
              type: string
        reconcilling:
          type: object
          properties:
            policy:
              type: string
        defaults:
          type: object
          properties:
            # Need to be StringBool
            replicasUseFQDN:
              type: string
              enum:
                # List StringBoolXXX constants from model
                - ""
                - "0"
                - "1"
                - "False"
                - "false"
                - "True"
                - "true"
                - "No"
                - "no"
                - "Yes"
                - "yes"
                - "Off"
                - "off"
                - "On"
                - "on"
                - "Disabled"
                - "disabled"
                - "Enabled"
                - "enabled"
            distributedDDL:
              type: object
              properties:
                profile:
                  type: string
            templates:
              type: object
              properties:
                hostTemplate:
                  type: string
                podTemplate:
                  type: string
                dataVolumeClaimTemplate:
                  type: string
                logVolumeClaimTemplate:
                  type: string
                serviceTemplate:
                  type: string
                clusterServiceTemplate:
                  type: string
                shardServiceTemplate:
                  type: string
                replicaServiceTemplate:
                  type: string
        configuration:
          type: object
          properties:
            zookeeper:
              type: object
              properties:
                nodes:
                  type: array
                  nullable: true
                  items:
                    type: object
                    #required:
                    #  - host
                    properties:
                      host:
                        type: string
                      port:
                        type: integer
                        minimum: 0
                        maximum: 65535
                session_timeout_ms:
                  type: integer
                operation_timeout_ms:
                  type: integer
                root:
                  type: string
                identity:
                  type: string
                install:
                  type: boolean
                replica:
                  type: integer
                  minimum: 0
                  maximum: 9
                port:
                  type: integer
                  minimum: 0
                  maximum: 65535
            users:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            profiles:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            quotas:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            settings:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            files:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            clusters:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                properties:
                  name:
                    type: string
                    minLength: 1
                    # See namePartClusterMaxLen const
                    maxLength: 15
                    pattern: "^[a-zA-Z0-9-]{0,15}$"
                  zookeeper:
                    type: object
                    properties:
                      nodes:
                        type: array
                        nullable: true
                        items:
                          type: object
                          #required:
                          #  - host
                          properties:
                            host:
                              type: string
                            port:
                              type: integer
                              minimum: 0
                              maximum: 65535
                      session_timeout_ms:
                        type: integer
                      operation_timeout_ms:
                        type: integer
                      root:
                        type: string
                      identity:
                        type: string
                      install:
                        type: boolean
                      replica:
                        type: integer
                      port:
                        type: integer
                        minimum: 0
                        maximum: 65535
                  settings:
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
                  files:
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
                  templates:
                    type: object
                    properties:
                      hostTemplate:
                        type: string
                      podTemplate:
                        type: string
                      dataVolumeClaimTemplate:
                        type: string
                      logVolumeClaimTemplate:
                        type: string
                      serviceTemplate:
                        type: string
                      clusterServiceTemplate:
                        type: string
                      shardServiceTemplate:
                        type: string
                      replicaServiceTemplate:
                        type: string
                  layout:
                    type: object
                    properties:
                      # DEPRECATED - to be removed soon
                      type:
                        type: string
                      shardsCount:
                        type: integer
                      replicasCount:
                        type: integer
                      shards:
                        type: array
                        nullable: true
                        items:
                          type: object
                          properties:
                            name:
                              type: string
                              minLength: 1
                              # See namePartShardMaxLen const
                              maxLength: 15
                              pattern: "^[a-zA-Z0-9-]{0,15}$"
                            # DEPRECATED - to be removed soon
                            definitionType:
                              type: string
                            weight:
                              type: integer
                            # Need to be StringBool
                            internalReplication:
                              type: string
                              enum:
                                # List StringBoolXXX constants from model
                                - ""
                                - "0"
                                - "1"
                                - "False"
                                - "false"
                                - "True"
                                - "true"
                                - "No"
                                - "no"
                                - "Yes"
                                - "yes"
                                - "Off"
                                - "off"
                                - "On"
                                - "on"
                                - "Disabled"
                                - "disabled"
                                - "Enabled"
                                - "enabled"
                            settings:
                              type: object
                              x-kubernetes-preserve-unknown-fields: true
                            files:
                              type: object
                              x-kubernetes-preserve-unknown-fields: true
                            templates:
                              type: object
                              properties:
                                hostTemplate:
                                  type: string
                                podTemplate:
                                  type: string
                                dataVolumeClaimTemplate:
                                  type: string
                                logVolumeClaimTemplate:
                                  type: string
                                serviceTemplate:
                                  type: string
                                clusterServiceTemplate:
                                  type: string
                                shardServiceTemplate:
                                  type: string
                                replicaServiceTemplate:
                                  type: string
                            replicasCount:
                              type: integer
                              minimum: 1
                            replicas:
                              type: array
                              nullable: true
                              items:
                                # Host
                                type: object
                                properties:
                                  name:
                                    type: string
                                    minLength: 1
                                    # See namePartReplicaMaxLen const
                                    maxLength: 15
                                    pattern: "^[a-zA-Z0-9-]{0,15}$"
                                  tcpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  httpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  interserverHttpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  settings:
                                    type: object
                                    x-kubernetes-preserve-unknown-fields: true
                                  files:
                                    type: object
                                    x-kubernetes-preserve-unknown-fields: true
                                  templates:
                                    type: object
                                    properties:
                                      hostTemplate:
                                        type: string
                                      podTemplate:
                                        type: string
                                      dataVolumeClaimTemplate:
                                        type: string
                                      logVolumeClaimTemplate:
                                        type: string
                                      serviceTemplate:
                                        type: string
                                      clusterServiceTemplate:
                                        type: string
                                      shardServiceTemplate:
                                        type: string
                                      replicaServiceTemplate:
                                        type: string
                      replicas:
                        type: array
                        nullable: true
                        items:
                          type: object
                          properties:
                            name:
                              type: string
                              minLength: 1
                              # See namePartShardMaxLen const
                              maxLength: 15
                              pattern: "^[a-zA-Z0-9-]{0,15}$"
                            settings:
                              type: object
                              x-kubernetes-preserve-unknown-fields: true
                            files:
                              type: object
                              x-kubernetes-preserve-unknown-fields: true
                            templates:
                              type: object
                              properties:
                                hostTeampate:
                                  type: string
                                podTemplate:
                                  type: string
                                dataVolumeClaimTemplate:
                                  type: string
                                logVolumeClaimTemplate:
                                  type: string
                                serviceTemplate:
                                  type: string
                                clusterServiceTemplate:
                                  type: string
                                shardServiceTemplate:
                                  type: string
                                replicaServiceTemplate:
                                  type: string
                            shardsCount:
                              type: integer
                              minimum: 1
                            shards:
                              type: array
                              nullable: true
                              items:
                                # Host
                                type: object
                                properties:
                                  name:
                                    type: string
                                    minLength: 1
                                    # See namePartReplicaMaxLen const
                                    maxLength: 15
                                    pattern: "^[a-zA-Z0-9-]{0,15}$"
                                  tcpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  httpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  interserverHttpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  settings:
                                    type: object
                                    x-kubernetes-preserve-unknown-fields: true
                                  files:
                                    type: object
                                    x-kubernetes-preserve-unknown-fields: true
                                  templates:
                                    type: object
                                    properties:
                                      hostTemplate:
                                        type: string
                                      podTemplate:
                                        type: string
                                      dataVolumeClaimTemplate:
                                        type: string
                                      logVolumeClaimTemplate:
                                        type: string
                                      serviceTemplate:
                                        type: string
                                      clusterServiceTemplate:
                                        type: string
                                      shardServiceTemplate:
                                        type: string
                                      replicaServiceTemplate:
                                        type: string
        templates:
          type: object
          properties:
            hostTemplates:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                properties:
                  name:
                    type: string
                  portDistribution:
                    type: array
                    nullable: true
                    items:
                      type: object
                      #required:
                      #  - type
                      properties:
                        type:
                          type: string
                          enum:
                            # List PortDistributionXXX constants
                            - ""
                            - "Unspecified"
                            - "ClusterScopeIndex"
                  spec:
                    # Host
                    type: object
                    properties:
                      name:
                        type: string
                        minLength: 1
                        # See namePartReplicaMaxLen const
                        maxLength: 15
                        pattern: "^[a-zA-Z0-9-]{0,15}$"
                      tcpPort:
                        type: integer
                        minimum: 1
                        maximum: 65535
                      httpPort:
                        type: integer
                        minimum: 1
                        maximum: 65535
                      interserverHttpPort:
                        type: integer
                        minimum: 1
                        maximum: 65535
                      settings:
                        type: object
                        x-kubernetes-preserve-unknown-fields: true
                      files:
                        type: object
                        x-kubernetes-preserve-unknown-fields: true
                      templates:
                        type: object
                        properties:
                          hostTemplate:
                            type: string
                          podTemplate:
                            type: string
                          dataVolumeClaimTemplate:
                            type: string
                          logVolumeClaimTemplate:
                            type: string
                          serviceTemplate:
                            type: string
                          clusterServiceTemplate:
                            type: string
                          shardServiceTemplate:
                            type: string
                          replicaServiceTemplate:
                            type: string
            podTemplates:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                properties:
                  name:
                    type: string
                  generateName:
                    type: string
                  zone:
                    type: object
                    #required:
                    #  - values
                    properties:
                      key:
                        type: string
                      values:
                        type: array
                        nullable: true
                        items:
                          type: string
                  distribution:
                    # DEPRECATED
                    type: string
                    enum:
                      - ""
                      - "Unspecified"
                      - "OnePerHost"
                  podDistribution:
                    type: array
                    nullable: true
                    items:
                      type: object
                      #required:
                      #  - type
                      properties:
                        type:
                          type: string
                          enum:
                            # List PodDistributionXXX constants
                            - ""
                            - "Unspecified"
                            - "ClickHouseAntiAffinity"
                            - "ShardAntiAffinity"
                            - "ReplicaAntiAffinity"
                            - "AnotherNamespaceAntiAffinity"
                            - "AnotherClickHouseInstallationAntiAffinity"
                            - "AnotherClusterAntiAffinity"
                            - "MaxNumberPerNode"
                            - "NamespaceAffinity"
                            - "ClickHouseInstallationAffinity"
                            - "ClusterAffinity"
                            - "ShardAffinity"
                            - "ReplicaAffinity"
                            - "PreviousTailAffinity"
                            - "CircularReplication"
                        scope:
                          type: string
                          enum:
                            # list PodDistributionScopeXXX constants
                            - ""
                            - "Unspecified"
                            - "Shard"
                            - "Replica"
                            - "Cluster"
                            - "ClickHouseInstallation"
                            - "Namespace"
                        number:
                          type: integer
                          minimum: 0
                          maximum: 65535
                  metadata:
                    # TODO specify ObjectMeta
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
                  spec:
                    # TODO specify PodSpec
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
            volumeClaimTemplates:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                #  - spec
                properties:
                  name:
                    type: string
                  reclaimPolicy:
                    type: string
                    enum:
                      - ""
                      - "Retain"
                      - "Delete"
                  spec:
                    # TODO specify PersistentVolumeClaimSpec
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
            serviceTemplates:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                #  - spec
                properties:
                  name:
                    type: string
                  generateName:
                    type: string
                  metadata:
                    # TODO specify ObjectMeta
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
                  spec:
                    # TODO specify ServiceSpec
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
        useTemplates:
          type: array
          nullable: true
          items:
            type: object
            #required:
            #  - name
            properties:
              name:
                type: string
              namespace:
                type: string
              useType:
                type: string
                enum:
                  # List useTypeXXX constants from model
                  - ""
                  - "merge"
{{- end }}


{{- define "clickhouseinstallationtemplates.openAPIV3Schema" }}
openAPIV3Schema:
  x-kubernetes-preserve-unknown-fields: true
  type: object
  properties:
    spec:
      type: object
      properties:
        # Need to be StringBool
        stop:
          type: string
          enum:
            # List StringBoolXXX constants from model
            - ""
            - "0"
            - "1"
            - "False"
            - "false"
            - "True"
            - "true"
            - "No"
            - "no"
            - "Yes"
            - "yes"
            - "Off"
            - "off"
            - "On"
            - "on"
            - "Disabled"
            - "disabled"
            - "Enabled"
            - "enabled"
        namespaceDomainPattern:
          type: string
        templating:
          type: object
          properties:
            policy:
              type: string
        reconcilling:
          type: object
          properties:
            policy:
              type: string
        defaults:
          type: object
          properties:
            # Need to be StringBool
            replicasUseFQDN:
              type: string
              enum:
                # List StringBoolXXX constants from model
                - ""
                - "0"
                - "1"
                - "False"
                - "false"
                - "True"
                - "true"
                - "No"
                - "no"
                - "Yes"
                - "yes"
                - "Off"
                - "off"
                - "On"
                - "on"
                - "Disabled"
                - "disabled"
                - "Enabled"
                - "enabled"
            distributedDDL:
              type: object
              properties:
                profile:
                  type: string
            templates:
              type: object
              properties:
                hostTemplate:
                  type: string
                podTemplate:
                  type: string
                dataVolumeClaimTemplate:
                  type: string
                logVolumeClaimTemplate:
                  type: string
                serviceTemplate:
                  type: string
                clusterServiceTemplate:
                  type: string
                shardServiceTemplate:
                  type: string
                replicaServiceTemplate:
                  type: string
        configuration:
          type: object
          properties:
            zookeeper:
              type: object
              properties:
                nodes:
                  type: array
                  nullable: true
                  items:
                    type: object
                    #required:
                    #  - host
                    properties:
                      host:
                        type: string
                      port:
                        type: integer
                        minimum: 0
                        maximum: 65535
                session_timeout_ms:
                  type: integer
                operation_timeout_ms:
                  type: integer
                root:
                  type: string
                identity:
                  type: string
                install:
                  type: boolean
                replica:
                  type: integer
                  minimum: 0
                  maximum: 9
                port:
                  type: integer
                  minimum: 0
                  maximum: 65535
            users:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            profiles:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            quotas:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            settings:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            files:
              type: object
              x-kubernetes-preserve-unknown-fields: true
            clusters:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                properties:
                  name:
                    type: string
                    minLength: 1
                    # See namePartClusterMaxLen const
                    maxLength: 15
                    pattern: "^[a-zA-Z0-9-]{0,15}$"
                  zookeeper:
                    type: object
                    properties:
                      nodes:
                        type: array
                        nullable: true
                        items:
                          type: object
                          #required:
                          #  - host
                          properties:
                            host:
                              type: string
                            port:
                              type: integer
                              minimum: 0
                              maximum: 65535
                      session_timeout_ms:
                        type: integer
                      operation_timeout_ms:
                        type: integer
                      root:
                        type: string
                      identity:
                        type: string
                      install:
                        type: boolean
                      replica:
                        type: integer
                      port:
                        type: integer
                        minimum: 0
                        maximum: 65535
                  settings:
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
                  files:
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
                  templates:
                    type: object
                    properties:
                      hostTemplate:
                        type: string
                      podTemplate:
                        type: string
                      dataVolumeClaimTemplate:
                        type: string
                      logVolumeClaimTemplate:
                        type: string
                      serviceTemplate:
                        type: string
                      clusterServiceTemplate:
                        type: string
                      shardServiceTemplate:
                        type: string
                      replicaServiceTemplate:
                        type: string
                  layout:
                    type: object
                    properties:
                      # DEPRECATED - to be removed soon
                      type:
                        type: string
                      shardsCount:
                        type: integer
                      replicasCount:
                        type: integer
                      shards:
                        type: array
                        nullable: true
                        items:
                          type: object
                          properties:
                            name:
                              type: string
                              minLength: 1
                              # See namePartShardMaxLen const
                              maxLength: 15
                              pattern: "^[a-zA-Z0-9-]{0,15}$"
                            # DEPRECATED - to be removed soon
                            definitionType:
                              type: string
                            weight:
                              type: integer
                            # Need to be StringBool
                            internalReplication:
                              type: string
                              enum:
                                # List StringBoolXXX constants from model
                                - ""
                                - "0"
                                - "1"
                                - "False"
                                - "false"
                                - "True"
                                - "true"
                                - "No"
                                - "no"
                                - "Yes"
                                - "yes"
                                - "Off"
                                - "off"
                                - "On"
                                - "on"
                                - "Disabled"
                                - "disabled"
                                - "Enabled"
                                - "enabled"
                            settings:
                              type: object
                              x-kubernetes-preserve-unknown-fields: true
                            files:
                              type: object
                              x-kubernetes-preserve-unknown-fields: true
                            templates:
                              type: object
                              properties:
                                hostTemplate:
                                  type: string
                                podTemplate:
                                  type: string
                                dataVolumeClaimTemplate:
                                  type: string
                                logVolumeClaimTemplate:
                                  type: string
                                serviceTemplate:
                                  type: string
                                clusterServiceTemplate:
                                  type: string
                                shardServiceTemplate:
                                  type: string
                                replicaServiceTemplate:
                                  type: string
                            replicasCount:
                              type: integer
                              minimum: 1
                            replicas:
                              type: array
                              nullable: true
                              items:
                                # Host
                                type: object
                                properties:
                                  name:
                                    type: string
                                    minLength: 1
                                    # See namePartReplicaMaxLen const
                                    maxLength: 15
                                    pattern: "^[a-zA-Z0-9-]{0,15}$"
                                  tcpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  httpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  interserverHttpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  settings:
                                    type: object
                                    x-kubernetes-preserve-unknown-fields: true
                                  files:
                                    type: object
                                    x-kubernetes-preserve-unknown-fields: true
                                  templates:
                                    type: object
                                    properties:
                                      hostTemplate:
                                        type: string
                                      podTemplate:
                                        type: string
                                      dataVolumeClaimTemplate:
                                        type: string
                                      logVolumeClaimTemplate:
                                        type: string
                                      serviceTemplate:
                                        type: string
                                      clusterServiceTemplate:
                                        type: string
                                      shardServiceTemplate:
                                        type: string
                                      replicaServiceTemplate:
                                        type: string
                      replicas:
                        type: array
                        nullable: true
                        items:
                          type: object
                          properties:
                            name:
                              type: string
                              minLength: 1
                              # See namePartShardMaxLen const
                              maxLength: 15
                              pattern: "^[a-zA-Z0-9-]{0,15}$"
                            settings:
                              type: object
                              x-kubernetes-preserve-unknown-fields: true
                            files:
                              type: object
                              x-kubernetes-preserve-unknown-fields: true
                            templates:
                              type: object
                              properties:
                                hostTeampate:
                                  type: string
                                podTemplate:
                                  type: string
                                dataVolumeClaimTemplate:
                                  type: string
                                logVolumeClaimTemplate:
                                  type: string
                                serviceTemplate:
                                  type: string
                                clusterServiceTemplate:
                                  type: string
                                shardServiceTemplate:
                                  type: string
                                replicaServiceTemplate:
                                  type: string
                            shardsCount:
                              type: integer
                              minimum: 1
                            shards:
                              type: array
                              nullable: true
                              items:
                                # Host
                                type: object
                                properties:
                                  name:
                                    type: string
                                    minLength: 1
                                    # See namePartReplicaMaxLen const
                                    maxLength: 15
                                    pattern: "^[a-zA-Z0-9-]{0,15}$"
                                  tcpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  httpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  interserverHttpPort:
                                    type: integer
                                    minimum: 1
                                    maximum: 65535
                                  settings:
                                    type: object
                                    x-kubernetes-preserve-unknown-fields: true
                                  files:
                                    type: object
                                    x-kubernetes-preserve-unknown-fields: true
                                  templates:
                                    type: object
                                    properties:
                                      hostTemplate:
                                        type: string
                                      podTemplate:
                                        type: string
                                      dataVolumeClaimTemplate:
                                        type: string
                                      logVolumeClaimTemplate:
                                        type: string
                                      serviceTemplate:
                                        type: string
                                      clusterServiceTemplate:
                                        type: string
                                      shardServiceTemplate:
                                        type: string
                                      replicaServiceTemplate:
                                        type: string
        templates:
          type: object
          properties:
            hostTemplates:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                properties:
                  name:
                    type: string
                  portDistribution:
                    type: array
                    nullable: true
                    items:
                      type: object
                      #required:
                      #  - type
                      properties:
                        type:
                          type: string
                          enum:
                            # List PortDistributionXXX constants
                            - ""
                            - "Unspecified"
                            - "ClusterScopeIndex"
                  spec:
                    # Host
                    type: object
                    properties:
                      name:
                        type: string
                        minLength: 1
                        # See namePartReplicaMaxLen const
                        maxLength: 15
                        pattern: "^[a-zA-Z0-9-]{0,15}$"
                      tcpPort:
                        type: integer
                        minimum: 1
                        maximum: 65535
                      httpPort:
                        type: integer
                        minimum: 1
                        maximum: 65535
                      interserverHttpPort:
                        type: integer
                        minimum: 1
                        maximum: 65535
                      settings:
                        type: object
                        x-kubernetes-preserve-unknown-fields: true
                      files:
                        type: object
                        x-kubernetes-preserve-unknown-fields: true
                      templates:
                        type: object
                        properties:
                          hostTemplate:
                            type: string
                          podTemplate:
                            type: string
                          dataVolumeClaimTemplate:
                            type: string
                          logVolumeClaimTemplate:
                            type: string
                          serviceTemplate:
                            type: string
                          clusterServiceTemplate:
                            type: string
                          shardServiceTemplate:
                            type: string
                          replicaServiceTemplate:
                            type: string
            podTemplates:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                properties:
                  name:
                    type: string
                  generateName:
                    type: string
                  zone:
                    type: object
                    #required:
                    #  - values
                    properties:
                      key:
                        type: string
                      values:
                        type: array
                        nullable: true
                        items:
                          type: string
                  distribution:
                    # DEPRECATED
                    type: string
                    enum:
                      - ""
                      - "Unspecified"
                      - "OnePerHost"
                  podDistribution:
                    type: array
                    nullable: true
                    items:
                      type: object
                      #required:
                      #  - type
                      properties:
                        type:
                          type: string
                          enum:
                            # List PodDistributionXXX constants
                            - ""
                            - "Unspecified"
                            - "ClickHouseAntiAffinity"
                            - "ShardAntiAffinity"
                            - "ReplicaAntiAffinity"
                            - "AnotherNamespaceAntiAffinity"
                            - "AnotherClickHouseInstallationAntiAffinity"
                            - "AnotherClusterAntiAffinity"
                            - "MaxNumberPerNode"
                            - "NamespaceAffinity"
                            - "ClickHouseInstallationAffinity"
                            - "ClusterAffinity"
                            - "ShardAffinity"
                            - "ReplicaAffinity"
                            - "PreviousTailAffinity"
                            - "CircularReplication"
                        scope:
                          type: string
                          enum:
                            # list PodDistributionScopeXXX constants
                            - ""
                            - "Unspecified"
                            - "Shard"
                            - "Replica"
                            - "Cluster"
                            - "ClickHouseInstallation"
                            - "Namespace"
                        number:
                          type: integer
                          minimum: 0
                          maximum: 65535
                  metadata:
                    # TODO specify ObjectMeta
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
                  spec:
                    # TODO specify PodSpec
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
            volumeClaimTemplates:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                #  - spec
                properties:
                  name:
                    type: string
                  reclaimPolicy:
                    type: string
                    enum:
                      - ""
                      - "Retain"
                      - "Delete"
                  spec:
                    # TODO specify PersistentVolumeClaimSpec
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
            serviceTemplates:
              type: array
              nullable: true
              items:
                type: object
                #required:
                #  - name
                #  - spec
                properties:
                  name:
                    type: string
                  generateName:
                    type: string
                  metadata:
                    # TODO specify ObjectMeta
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
                  spec:
                    # TODO specify ServiceSpec
                    type: object
                    x-kubernetes-preserve-unknown-fields: true
        useTemplates:
          type: array
          nullable: true
          items:
            type: object
            #required:
            #  - name
            properties:
              name:
                type: string
              namespace:
                type: string
              useType:
                type: string
                enum:
                  # List useTypeXXX constants from model
                  - ""
                  - "merge"
{{- end }}


{{- define "clickhouseoperatorconfigurations.openAPIV3Schema" }}
openAPIV3Schema:
  type: object
  properties:
    spec:
      type: object
      x-kubernetes-preserve-unknown-fields: true
      properties:
        watchNamespaces:
          type: array
          items:
            type: string
        chCommonConfigsPath:
          type: string
        chHostConfigsPath:
          type: string
        chUsersConfigsPath:
          type: string
        chiTemplatesPath:
          type: string
        statefulSetUpdateTimeout:
          type: integer
        statefulSetUpdatePollPeriod:
          type: integer
        onStatefulSetCreateFailureAction:
          type: string
        onStatefulSetUpdateFailureAction:
          type: string
        chConfigUserDefaultProfile:
          type: string
        chConfigUserDefaultQuota:
          type: string
        chConfigUserDefaultNetworksIP:
          type: array
          items:
            type: string
        chConfigUserDefaultPassword:
          type: string
        chUsername:
          type: string
        chPassword:
          type: string
        chPort:
          type: integer
          minimum: 1
          maximum: 65535
        logtostderr:
          type: string
        alsologtostderr:
          type: string
        v:
          type: string
        stderrthreshold:
          type: string
        vmodule:
          type: string
        log_backtrace_at:
          type: string
        reconcileThreadsNumber:
          type: integer
          minimum: 1
          maximum: 65535
        reconcileWaitExclude:
          type: string
        reconcileWaitInclude:
          type: string
{{- end }}