port: {
  auth_enabled = false;
  server = {
    http_listen_port = port;
    grpc_listen_port = 9096;
    http_server_read_timeout = "600s";
    http_server_write_timeout = "600s";
  };
  common = {
    path_prefix = "/loki";
    storage = {
      filesystem = {
        chunks_directory = "/loki/chunks";
        rules_directory = "/loki/rules";
      };
    };
    replication_factor = 1;
    ring = {
      instance_addr = "127.0.0.1";
      kvstore = {store = "inmemory";};
    };
  };
  query_range = {
    results_cache = {
      cache = {
        embedded_cache = {
          enabled = true;
          max_size_mb = 100;
        };
      };
    };
  };
  querier = {max_concurrent = 2048;};
  query_scheduler = {max_outstanding_requests_per_tenant = 2048;};
  schema_config = {
    configs = [
      {
        from = "2024-11-04";
        store = "tsdb";
        object_store = "filesystem";
        schema = "v13";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }
    ];
  };
  ruler = {alertmanager_url = "http://localhost:9093";};
  compactor = {
    working_directory = "/loki/retention";
    delete_request_store = "filesystem";
    compaction_interval = "10m";
    retention_enabled = true;
    retention_delete_delay = "2h";
    retention_delete_worker_count = 150;
  };
  limits_config = {
    retention_period = "180d";
    max_query_series = 100000;
  };
}
