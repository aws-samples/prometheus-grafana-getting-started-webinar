# Amazon Managed Service for Prometheus and Amazon Managed Grafana getting started

This repository is a walk through of scripts that were made to quickly set up [Amazon Managed service for Prometheus](https://aws.amazon.com/prometheus/) (AMP) and [Amazon Managed Grafana](https://aws.amazon.com/grafana/) in order to write metrics from an EKS cluster to AMP, and to access and query it from Amazon Managed Grafana.

The demo is based on an EKS cluster running [Graviton 2](https://aws.amazon.com/ec2/graviton/) instances, which are based on Arm64 architecture and [offers up to 30% better performance and 20% lower costs](https://aws.amazon.com/blogs/aws/new-m6g-ec2-instances-powered-by-arm-based-aws-graviton2/). The cluster is launched using `eksctl`, but this demo can run on an existing EKS cluster, and on x86 instances.

## Query AMP using Grafana

There are two options for querying and plotting Prometheus data in Grafana:

1. Using self-managed Grafana installed in EKS - Requires Grafana => 7.3.5
2. Using Amazon Managed Grafana

## Requirements

This demo is configured to run in `eu-west-1`. If you need to run it in a different region, edit the `AWS_REGION` variable in all the scripts.

As for the command line tools:

1. `awscli` => 2.2.25
2. `eksctl` => 0.59
3. Helm => v3.6.3

### Demo walkthrough

1. If you don't have an EKS cluster up and running, launch a new cluster `./demo/1_launch_eks.sh`
2. Create an Amazon managed service for Prometheus (AMP) `./demo/2_create_amp_workspace.sh`
3. Create 2 dedicated EKS namespaces for Prometheus and Grafana `./demo/3_namespaces.sh`, Prometheus will be installed in `amp` namespace, and Grafana will be installed in `grafana` namespace, both will be installed using their helm charts
4. Create the appropriate IAM permissions `./demo/4_permissions.sh`
5. Deploy Prometheus Helm chart, with ingest permission, and set the remote write endpoint of AMP `./demo/5_deploy_prometheus_helm.sh`
6. Deploy Grafana Helm chart, with query permission `./demo/6_deploy_grafana_helm.sh`
7. Connect to Grafana chart and configure AMP query endpoint data source
8. Import a Grafana dashboard

### How AMP ingest data

Ingesting metrics is being done by using the Prometheus [remote write](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_write) interface.

### Ingesting data privately using AWS PrivateLink

By default, AMP will ingest data over the internet. In order to ingest data privately without traversing to the internet, we will setup a private endpoint powered by [AWS PrivateLink](https://aws.amazon.com/privatelink/) in the EKS cluster VPC.

Go to VPC -> Endpoints -> Create Endpoint -> we will choose the service com.amazonaws.{region}.aps-workspaces

>You do not need to change the settings for AMP. AMP calls other AWS services using either public endpoints or private interface VPC endpoints, whichever are in use. For example, if you create an interface VPC endpoint for AMP, and you already have metrics flowing to AMP from resources located on your VPC, these metrics begin flowing through the interface VPC endpoint by default.

### Amazon Managed Grafana

1. In order to assign users with access to Grafana instances, Amazon Managed Grafana supports both [AWS SSO and SAMLv2](https://docs.aws.amazon.com/grafana/latest/userguide/authentication-in-AMG.html). For AWS SSO you need to have AWS Organizations enabled in your AWS account.
2. Go to Amazon Managed Grafana in AWS console and create a workspace, and provide a name for the workspace.
3. In the permission type, select "Service Managed".
4. In the service managed permission select "Current Account", select the data resource "Amazon Managed Service for Prometheus", and create the workspace.
5. After creating Amazon Managed Grafana workspace, add a user or group with Admin permissions, that will grant write permissions.

Configure AMP data source:

1. Go to configuration and choose data sources tab.
2. Click the `add data source` button and select Prometheus.
3. In the URL put the AMP Endpoint query URL from the AMP workspace console, and remove the `/api/v1/query` from the end.
4. Enable the SigV4 auth and select the default region (your AMP region) and click `Save & Test` button.

### Grafana dashboard examples

To import dashboards into Grafana, we will need to import them using their ID's.

* ID: 10856 - K8 Cluster Detail Dashboard
* ID: 12740 - Kubernetes Monitoring Dashboard
* ID: 14518 - Kubernetes Cluster Overall Dashboard
* ID: 11074 - 1 Node Exporter for Prometheus Dashboard EN v20201010
* ID: 11623 - 1 Node Exporter for Prometheus Dashboard English version UPDATE 1102by kimyou
* ID: 3119 - Kubernetes cluster monitoring (via Prometheus)
* ID: 6417 - Kubernetes Cluster (Prometheus)

To import to dashboard into Grafana:

1. Go to Dashboard and click Manage.
2. Click Import and place the ID in the `import via grafana.com text box`.
3. Click load and select the Prometheus data source.
4. Click Import.

If you're interested in further recipes around Amazon Managed Grafana, check out the respective section in the [AWS Observability Recipes](https://aws-observability.github.io/aws-o11y-recipes/amg/).

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
