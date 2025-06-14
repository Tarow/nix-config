lokiUrl: prometheusUrl: {
  apiVersion = 1;
  datasources = [
    {
      name = "Loki";
      type = "loki";
      access = "proxy";
      url = lokiUrl;
      version = 1;
      editable = false;
      isDefault = true;
    }
    {
      name = "Prometheus";
      type = "prometheus";
      access = "proxy";
      url = prometheusUrl;
      version = 1;
      editable = false;
      isDefault = false;
    }
  ];
}
