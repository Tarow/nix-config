# To see all available options, please visit the docs:
# https://docs.fossorial.io/Pangolin/Configuration/config
config: domain: ''
  app:
      dashboard_url: "https://pangolin.${domain}"
      log_level: "info"
      save_logs: false

  domains:
      domain1:
          base_domain: "${domain}"
          cert_resolver: "letsencrypt"

  server:
      external_port: 3000
      internal_port: 3001
      next_port: 3002
      internal_hostname: "pangolin"
      session_cookie_name: "p_session_token"
      resource_access_token_param: "p_token"
      resource_session_request_param: "p_session_request"
      cors:
          origins: ["https://pangolin.${domain}"]
          methods: ["GET", "POST", "PUT", "DELETE", "PATCH"]
          headers: ["X-CSRF-Token", "Content-Type"]
          credentials: false

  traefik:
      cert_resolver: "letsencrypt"
      http_entrypoint: "web"
      https_entrypoint: "websecure"

  gerbil:
      start_port: 51820
      base_endpoint: "pangolin.${domain}"
      use_subdomain: false
      block_size: 24
      site_block_size: 30
      subnet_group: 100.89.137.0/20

  rate_limits:
      global:
          window_minutes: 1
          max_requests: 100

  users:
      server_admin:
          email: ${config.sops.placeholder."pangolin/email"}
          password: ${config.sops.placeholder."pangolin/password"}

  flags:
      require_email_verification: false
      disable_signup_without_invite: true
      disable_user_create_org: false
      allow_raw_resources: true
      allow_base_domain_resources: true
''
