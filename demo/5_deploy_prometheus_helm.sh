#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -e

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
IAM_PROXY_PROMETHEUS_ROLE_ARN=arn:aws:iam::${AWS_ACCOUNT_ID}:role/amp-iamproxy-role
AWS_REGION=eu-west-1
AMP_ALIAS=demo-workspace
WORKSPACE_ID=$(aws amp list-workspaces --alias $AMP_ALIAS --query "workspaces[].workspaceId" --region eu-west-1 --output text --no-cli-pager)
NS=amp

# Add Prometheus community repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Install Prometheus helm chart
helm install prometheus prometheus-community/prometheus -n ${NS} -f ./prometheus_values.yaml \
    --set serviceAccounts.server.annotations."eks\.amazonaws\.com/role-arn"="${IAM_PROXY_PROMETHEUS_ROLE_ARN}" \
    --set server.remoteWrite[0].url="https://aps-workspaces.${AWS_REGION}.amazonaws.com/workspaces/${WORKSPACE_ID}/api/v1/remote_write" \
    --set server.remoteWrite[0].sigv4.region=${AWS_REGION}