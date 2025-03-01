lokiUrl: ''
  discovery.docker "docker_log_scrape" {
  	host             = "unix:///var/run/docker.sock"
  	refresh_interval = "10s"

  	filter {
  		name   = "label"
  		values = ["logging.alloy=true"]
  	}
  }

  discovery.relabel "docker_log_scrape" {
  	targets = []

  	rule {
  		source_labels = ["__meta_docker_container_name"]
  		regex         = "/(.*)"
  		target_label  = "container"
  	}

  	rule {
  		source_labels = ["__meta_docker_container_log_stream"]
  		target_label  = "logstream"
  	}

  	rule {
  		source_labels = ["__meta_docker_container_label_logging_jobname"]
  		target_label  = "job"
  	}
  }

  loki.source.docker "docker_log_scrape" {
  	host             = "unix:///var/run/docker.sock"
  	targets          = discovery.docker.docker_log_scrape.targets
  	forward_to       = [loki.write.default.receiver]
  	relabel_rules    = discovery.relabel.docker_log_scrape.rules
  	refresh_interval = "10s"
  }

  loki.write "default" {
  	endpoint {
  		url = "${lokiUrl}/loki/api/v1/push"
  	}
  	external_labels = {}
  }
''
