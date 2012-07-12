#
# Cookbook Name:: inmobi_cloud
# Recipe:: dns_add_record
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

# Creating dns directory for further use
directory "/opt/rightscale/dns" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
end

template "/opt/rightscale/dns/ultradns_add_record.rb" do
    source "ultradns_add_record.erb"
    owner "root"
    group "root"
    mode "0755"
end

local_ip = "#{node.inmobi_cloud.ec2_private_ip}"
hostname_fqdn = "#{node.inmobi_cloud.rs_hostname}".downcase
host_array = hostname_fqdn.split('.')
zone = host_array[-3..-1].join('.')
udns_user = node[:inmobi_cloud][:dns_username]
udns_passwd = node[:inmobi_cloud][:dns_password]
log "#{udns_user} #{udns_passwd}"
result = `/usr/bin/ruby /opt/rightscale/dns/ultradns_add_record.rb -i #{zone}:#{hostname_fqdn}  -u "#{node[:inmobi_cloud][:dns_username]}" -p "#{node[:inmobi_cloud][:dns_password]}" -a #{local_ip}`
puts "#{result}"

bash "set_DNS" do
    code <<-EOH
      /usr/bin/ruby /opt/rightscale/dns/ultradns_add_record.rb -i #{zone}:#{hostname_fqdn}  -u #{node[:inmobi_cloud][:dns_username]} -p #{node[:inmobi_cloud][:dns_password]} -a #{local_ip}
    EOH
end
