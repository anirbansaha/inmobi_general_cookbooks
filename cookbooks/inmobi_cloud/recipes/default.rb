#
# Cookbook Name:: inmobi_cloud
# Recipe:: default
#
# Copyright 2012, InMobi Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
rs_utils_marker :begin

local_ip = "#{node.inmobi_cloud.ec2_private_ip}"
hostname_fqdn = "#{node.inmobi_cloud.rs_hostname}"
cloud_colo = {"us-east" => "ev1.inmobi.com", "eu-west" => "ir1.inmobi.com", "us-west" => "wc1.inmobi.com", "ap-southeast" => "sg1.inmobi.com"}
aws_zone = "#{node.inmobi_cloud.availability_zone}".split('-')
aws_region = aws_zone[0..1].join('-')
log "#{aws_region}"


rs_utils_marker :end
