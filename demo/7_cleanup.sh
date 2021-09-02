#!/bin/bash

REGION='eu-west-1'
AMP_ALIAS='demo-workspace'
cluster_name='amp-demo'

# AMP
WORKSPACE_ID=$(aws amp list-workspaces --alias $AMP_ALIAS --query "workspaces[].workspaceId" --region eu-west-1 --output text --no-cli-pager)
aws amp delete-workspace --region ${REGION} --workspace-id ${WORKSPACE_ID}

# EKS
kubectl delete ns amp grafana
eksctl delete cluster --name ${cluster_name}

echo "Make sure to delete grafana workspace"