#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# PrivateLink
kubectl run -i --tty --rm debug --image=ubuntu --restart=Never -- bash
apt-get update
apt-get install -y dnsutils
dig aps-workspaces.eu-west-1.amazonaws.com

# Node-Exporter metrics
NODE_EXPORTER_POD=$(kubectl get pod -n amp -lcomponent=node-exporter --no-headers | head -1 | awk '{print $1}')
kubectl port-forward -n amp ${NODE_EXPORTER_POD} 9100:9100

# Prometheus remote_write
kubectl port-forward -n amp prometheus-0 9090:9090

# Grafana
GRAFANA_POD=$(kubectl get pod -n grafana -lapp.kubernetes.io/name=grafana --no-headers | awk '{print $1}')
kubectl port-forward -n grafana ${GRAFANA_POD} 3000:3000

# helm
helm show notes -n grafana grafana

# PromQL
# Basic 
prometheus_tsdb_head_series

# Number of pods per ns
count by (namespace)(sum by (namespace,pod,container)(kube_pod_container_info{container!=""}) unless sum by (namespace,pod,container)(kube_pod_container_resource_limits{resource="cpu"}))

# Pod restarts by namespace
sum by (namespace)(changes(kube_pod_status_ready{condition="true"}[5m]))

# Not ready pods
sum by (namespace) (kube_pod_status_ready{condition="false"})

# Ready nodes
sum(kube_node_status_condition{condition="Ready", status="true"}==1)

