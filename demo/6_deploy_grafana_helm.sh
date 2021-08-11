#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -e

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
sed -i'.BAK' "s|ACCOUNT_ID|$AWS_ACCOUNT_ID|" ./grafana_values.yaml

# Add Grafana Repo to helm
helm repo add grafana https://grafana.github.io/helm-charts

# Install Grafana chart
helm upgrade --install grafana grafana/grafana -n grafana -f ./grafana_values.yaml
