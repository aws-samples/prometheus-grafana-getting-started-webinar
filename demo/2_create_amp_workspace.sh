#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

AWS_REGION='eu-west-1'

aws amp create-workspace --region ${AWS_REGION} --alias demo-workspace