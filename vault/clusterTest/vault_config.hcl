storage "raft" {
  path    = "/vault/data"
  node_id = "{{ ID }}"
}

listener "tcp" {
  address     = "{{ IP }}:8200"
  tls_disable = "true"
}

disable_mlock = true

api_addr = "http://{{ IP }}:8200"
cluster_addr = "https://{{ IP }}:8201"
ui = true