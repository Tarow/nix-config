lokiUrl: ''
  server:
    http_listen_port: 9080
    grpc_listen_port: 0

  positions:
    filename: /tmp/positions.yaml

  clients:
    - url: ${lokiUrl}/loki/api/v1/push

  scrape_configs:
    - job_name: docker_log_scrape
      docker_sd_configs:
        - host: unix:///var/run/docker.sock
          refresh_interval: 10s
          filters:
            - name: label
              values: ["logging.promtail=true"]
      relabel_configs:
        - source_labels: ['__meta_docker_container_name']
          regex: '/(.*)'
          target_label: 'container'
        - source_labels: ['__meta_docker_container_log_stream']
          target_label: 'logstream'
        - source_labels: ['__meta_docker_container_label_logging_jobname']
          target_label: 'job'
''
