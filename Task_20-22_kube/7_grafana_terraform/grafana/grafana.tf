# DATASOURCES
# resource "grafana_data_source" "prometheus" {
#   name                = "prometheus"
#   type                = "prometheus"
#   url                 = "http://62.84.127.199:9090"
#   # basic_auth_enabled  = true
#   # basic_auth_username = "username"
#   # secure_json_data_encoded = jsonencode({
#   #   basicAuthPassword = "password"
#   # })
# }

# resource "grafana_data_source" "loki" {
#   name                = "loki"
#   type                = "loki"
#   url                 = "http://62.84.127.199:3100"
# }


# CONTACT POINTS
resource "grafana_contact_point" "slack" {
    name = "slack"
    slack {
        url = "http://api.slack.com/apps/A08K2EGUL3S/incoming-webhooks"
    }
}

# ALERT POLICY
resource "grafana_notification_policy" "slack" {
    group_by      = ["alertname"]
    contact_point = grafana_contact_point.slack.name
}


# CREATE FOLDERS
resource "grafana_folder" "rules" {
  title = "Rules"
}

resource "grafana_folder" "logs" {
  title = "Logs"
}

# RULES
resource "grafana_rule_group" "prometheus_alerts" {
  name             = "Prometheus Alert Rules"
  folder_uid       = grafana_folder.rules.uid
  org_id           = 1
  interval_seconds = 30

  # make provisioned resources editable in the Grafana UI, enable the disable_provenance
  # disable_provenance = true

  rule {
    name        = "HostHighCpuLoad"
    for         = "5s"
    condition   = "A"
    annotations = {
      summary     = "High CPU usage on {{ $labels.instance }}"
      description = "VALUE = {{ $value }}\nLABELS = {{ $labels }}"
    }
    labels = {
      severity = "warning"
    }
    is_paused = false
    data {
      ref_id          = "A"
      datasource_uid  = grafana_data_source.prometheus.uid
      model           = "{\"datasource\":{\"type\":\"prometheus\",\"uid\":\"cegt7wv2xidxce\"},\"editorMode\":\"code\",\"expr\":\"100 * (1 - avg by(instance) (irate(node_cpu_seconds_total{mode=\\\"idle\\\"}[1m]))) > 0.001\",\"hide\":false,\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
      relative_time_range {
        from = 600
        to   = 0
      }
    }
  }

  rule {
    name        = "HostOutOfMemory"
    for         = "5s"
    condition   = "B"
    annotations = {
      summary     = "Host out of memory (instance {{ $labels.instance }})"
      description = "Node memory is filling up\nVALUE = {{ $value }}\nLABELS = {{ $labels }}"
    }
    labels = {
      severity = "warning"
    }
    data {
      ref_id          = "B"
      datasource_uid  = grafana_data_source.prometheus.uid
      model           = "{\"datasource\":{\"type\":\"prometheus\",\"uid\":\"cegt7wv2xidxce\"},\"editorMode\":\"code\",\"expr\":\"100 * (1 - ((avg_over_time(node_memory_MemFree_bytes[1m]) + avg_over_time(node_memory_Cached_bytes[1m]) + avg_over_time(node_memory_Buffers_bytes[1m])) / avg_over_time(node_memory_MemTotal_bytes{job=\\\"vm\\\"}[1m]))) > 10\",\"hide\":false,\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
      relative_time_range {
        from = 600
        to   = 0
      }
    }
  }

  rule {
    name        = "AlwaysFiringAlert"
    for         = "20s"
    condition   = "C"
    annotations = {
      summary     = "This alert always fires!"
      description = "The `up` metric is always 1, meaning the service is up."
    }
    labels = {
      severity = "critical"
    }
    data {
      ref_id          = "C"
      datasource_uid  = grafana_data_source.prometheus.uid
      model           = "{\"datasource\":{\"type\":\"prometheus\",\"uid\":\"cegt7wv2xidxce\"},\"hide\":false,\"instant\":true,\"refId\":\"A\"}"
      relative_time_range {
        from = 600
        to   = 0
      }
    }
  }
}

# DASHBOARDS
resource "grafana_dashboard" "nginx_logs" {
  folder = grafana_folder.logs.uid
  config_json = jsonencode({
    "id": null,
    "uid": "nginx-logs-dashboard",
    "title": "Nginx Logs",
    "tags": ["nginx", "logs"],
    "timezone": "browser",
    "panels": [
      {
        "type": "logs",
        "title": "Nginx Logs",
        "datasource": "${grafana_data_source.loki.name}",
        "targets": [
          {
            "expr": "{job=\"nginx\"}",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "mappings": [],
            "custom": {}
          },
          "overrides": []
        },
        "options": {
          "showTime": true
        }
      }
    ]
  })
}

# Define Apache panel on the dashboard
resource "grafana_dashboard" "apache_logs" {
  folder = grafana_folder.logs.uid  # Use folder UID here
  config_json = jsonencode({
      "id": null,
      "uid": "apache-logs-dashboard",
      "title": "Apache Logs",
      "tags": ["apache", "logs"],
      "timezone": "browser",
      "panels": [
        {
          "type": "logs",
          "title": "Apache Logs",
          "datasource": "${grafana_data_source.loki.name}",
          "targets": [
            {
              "expr": "{job=\"apache\"}",
              "refId": "A"
            }
          ],
          "fieldConfig": {
            "defaults": {
              "mappings": [],
              "custom": {}
            },
            "overrides": []
          },
          "options": {
            "showTime": true
          }
        }
      ]
    }
  )
}
