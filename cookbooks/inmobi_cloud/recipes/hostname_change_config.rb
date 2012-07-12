# Cookbook Name:: inmobi_cloud
# Recipe:: hostname_change_config
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

old_hostname = `cat /etc/hostname`.chomp
local_ip = "#{node.inmobi_cloud.ec2_private_ip}"
hostname_fqdn = "#{node.inmobi_cloud.rs_hostname}".downcase
cloud_colo = {"us-east" => "ev1.inmobi.com", "eu-west" => "ir1.inmobi.com", "us-west" => "wc1.inmobi.com", "ap-southeast" => "sg1.inmobi.com"}
aws_zone = "#{node.inmobi_cloud.availability_zone}".split('-')
aws_region = aws_zone[0..1].join('-')

#Check if colo provided is correct
host_array = hostname_fqdn.split('.')
zone = host_array[-3..-1].join('.')
if zone != cloud_colo[aws_region]
    log "Colo naming convention is not correct as per region. Exiting.."
    exit(1)
end

#Check if hostname contains underscore
if hostname_fqdn.include? "_"
    log "Hostname cannot contain underscores. Please fix. Exiting.."
    exit(1)
end

#Setting domain, IPs and other data
domain = host_array[-2..-1].join('.')
first_name = host_array[0]
hosts_list = "#{hostname_fqdn} #{first_name}"

log 'Setting hostname files.'
if platform?('centos', 'redhat')
  template "/etc/sysconfig/network" do
    source "network.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :hostname_fqdn => hostname_fqdn
    )
  end
else
  template "/etc/hostname" do
    source "hostname.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :hostname_fqdn => hostname_fqdn
    )
  end
end

log 'Setting hostname.'
if platform?('centos', 'redhat')
  bash "set_hostname" do
    code <<-EOH
      hostname #{hostname_fqdn}
    EOH
  end
else
  bash "set_hostname" do
    code <<-EOH
      start hostname
    EOH
  end
end

log 'Setting hosts file.'
template "/etc/hosts" do
    source "hosts.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :local_ip => local_ip,
      :hosts_list => hosts_list
    )
end

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

template "/opt/rightscale/dns/ultradns_delete_record.rb" do
    source "ultradns_delete_record.erb"
    owner "root"
    group "root"
    mode "0755"
end

bash "change_DNS" do
    code <<-EOH
      /bin/rm -r /var/lib/puppet/ssl
      /usr/bin/ruby /opt/rightscale/dns/ultradns_delete_record.rb -i #{zone}:#{old_hostname}  -u "#{node[:inmobi_cloud][:dns_username]}" -p "#{node[:inmobi_cloud][:dns_password]}"
      /usr/bin/ruby /opt/rightscale/dns/ultradns_add_record.rb -i #{zone}:#{hostname_fqdn}  -u "#{node[:inmobi_cloud][:dns_username]}" -p "#{node[:inmobi_cloud][:dns_password]}" -a #{local_ip}
    EOH
end
