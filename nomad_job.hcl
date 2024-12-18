job "grafana" {
  datacenters = ["ap-southeast-1-staging"]
  type        = var.type

  node_pool = "ops-prometheus"

  group "monitoring" {
    count = 1

    network {

      port "grafana-http" {
        to = 3000
      }
    }

    task "grafana" {
      driver = "docker"

      template {
        change_mode = "noop"
        destination = "local/grafana/datasources.yaml"

        data = <<EOH
---
apiVersion: 1

datasources:
 - name: Prometheus
   type: prometheus
   {{ range service "prometheus" }}
   url: http://{{ .Address }}:{{ .Port }}
   {{ end }}
   isDefault: false
   access: proxy

 - name: CloudWatch
   type: cloudwatch
   jsonData:
     authType: default
     defaultRegion: ap-southeast-1

 - name: AWS-Prometheus
   type: prometheus
   url: https://aps-workspaces.ap-southeast-1.amazonaws.com/workspaces/ws-40581516-0b56-4e56-aace-17ec6499c139/
   isDefault: true
   access: proxy
   basicAuth: false
   jsonData:
     sigV4Auth: true
     sigV4Region: ap-southeast-1
     sigV4AuthType: default
  
EOH
    }


    template {
        change_mode = "noop"
        destination = "local/grafana/grafana.ini"

        data = <<EOH
app_mode = production

# Directories
[paths]
data = /var/lib/grafana
logs = /var/log/grafana
provisioning = /etc/grafana/provisioning

# Database
[database]
type = mysql
host = cb-staging-db-mariadb.c5vr00mu3lp8.ap-southeast-1.rds.amazonaws.com:3306
name = grafana_db
user = g4ap7anaDBus3r
password = g4ap7anaDBp@ss
ssl_mode = true
ca_cert_path = /etc/ssl/certs/aws.global-bundle.pem
server_cert_name = cb-staging-db-mariadb.c5vr00mu3lp8.ap-southeast-1.rds.amazonaws.com

# Security
[security]
admin_user = admin
admin_password = c3!c8u22op$r3dbu!!

[server]
root_url = https://monitor-aws.cbuzz.dev

# Users manangement and registration
[users]
default_theme = dark
allow_sign_up = False
auto_assign_org_role = Viewer

[emails]
welcome_email_on_sign_up = False

# Authentication
[auth]
login_cookie_name = grafana_session
disable_login_form = False
disable_signout_menu = False

[auth.google]
enabled = True
scopes = `https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email`
allowed_domains = cricbuzz.com
token_url = `https://accounts.google.com/o/oauth2/token`
allow_sign_up = True
auth_url = `https://accounts.google.com/o/oauth2/auth`
api_url = `https://openidconnect.googleapis.com/v1/userinfo`
client_id = `1073567991026-ormkskgqv27cj7ue6vo97t1mvjs6tnve.apps.googleusercontent.com`
client_secret = cLigf4uaPLTnfVFhyEI1TQmw
disable_login_form = True   

# Analytics
[analytics]
reporting_enabled = "True"

[dashboards.json]
enabled = true
path = /etc/grafana/provisioning/dashboards

# Alerting
[unified_alerting]
enabled = true

# Logging
[log]
mode = console file
level = debug

[aws]
assume_role_enabled = false

EOH
    }

    template {
        change_mode = "noop"
        destination = "/local/grafana/provisioning/dashboards/dashboards.yaml"

        data        = <<EOF
apiVersion: 1
providers:
  - name: cbdashboard
    type: file
    updateIntervalSeconds: 30
    options:
      foldersFromFilesStructure: true
      path: /etc/grafana/provisioning/dashboards
EOF
    }

      service {
        name     = "grafana-web"
        port     = "grafana-http"
        tags = [
          "grafana", "web", "ops-prometheus",
          "traefik.enable=true",
          "traefik.http.routers.grafana.rule=Host(`monitor-aws.cbuzz.dev`)"
        ]
        check {
          name     = "Grafana HTTP"
          type     = "http"
          path     = "/api/health"
          port = "grafana-http"
          interval = "5s"
          timeout  = "2s"
           check_restart {
            limit = 2
            grace = "60s"
            ignore_warnings = false
          }
        }
      }

      env {
        GF_LOG_LEVEL          = "DEBUG"
        GF_LOG_MODE           = "console"
        GF_SERVER_HTTP_PORT   = "${NOMAD_PORT_http}"
        GF_SERVER_DOMAIN="monitor-aws.cbuzz.dev"
        AWS_SDK_LOAD_CONFIG   = "true"
        GF_AUTH_SIGV4_AUTH_ENABLED = "true"
      }

      config {
        image = "grafana/grafana-oss:11.0.0-ubuntu"
        ports = ["grafana-http"]
        auth_soft_fail = true

        volumes = [
            "/root/certificates/aws.global-bundle.pem:/etc/ssl/certs/aws.global-bundle.pem",
            "local/grafana/grafana.ini:/etc/grafana/grafana.ini",
            "local/grafana/datasources.yaml:/etc/grafana/provisioning/datasources/datasources.yaml",
            "local/grafana/provisioning/dashboards/dashboards.yaml:/etc/grafana/provisioning/dashboards/dashboards.yaml"
        ]
      }

      resources {
        cpu    = 512
        memory = 512
      }
    }
  }
}
