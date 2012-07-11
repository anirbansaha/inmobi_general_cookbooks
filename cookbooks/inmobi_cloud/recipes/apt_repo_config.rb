# Cookbook Name:: inmobi_cloud
# Recipe:: apt_repo_config 
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
hostname_fqdn = "#{node.inmobi_cloud.rs_hostname}".downcase
host_array = hostname_fqdn.split('.')
zone = host_array[-3..-1].join('.')
apache_port = "#{node.inmobi_cloud.apache_port}"
pkg_host_url = "pkg." + "#{zone}" + ":#{node.inmobi_cloud.apache_port}"

log 'Setting repo files.'
if platform?('ubuntu', 'debian')
  template "/etc/apt/sources.list" do
    source "sources.list.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :pkg_host_url => pkg_host_url
    )
  end
end
