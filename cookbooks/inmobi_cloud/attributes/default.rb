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

default[:inmobi_cloud][:rs_hostname] = nil
default[:inmobi_cloud][:ec2_private_ip] = nil
default[:inmobi_cloud][:availability_zone] = nil
default[:inmobi_cloud][:apache_port] = "9999"
default[:inmobi_cloud][:rs_login_url] = "https://my.rightscale.com/api/acct/55593/login?api_version=1.0"
default[:inmobi_cloud][:rs_server_url] = "https://my.rightscale.com/api/acct/55593/servers"
default[:inmobi_cloud][:rs_volume_url] = "https://my.rightscale.com/api/acct/55593/ec2_ebs_volumes"
