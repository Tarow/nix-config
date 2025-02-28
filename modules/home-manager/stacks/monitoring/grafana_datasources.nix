lokiUrl: ''
  apiVersion: 1

  datasources:
    - name: Loki
      type: loki
      access: proxy
      url: ${lokiUrl}
      version: 1
      editable: false
      isDefault: true
''
