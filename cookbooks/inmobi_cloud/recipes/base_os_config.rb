# Cookbook Name:: inmobi_cloud
# Recipe:: base_os_config
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
google_ip = "8.8.8.8"
colo_admbox = "puppet." + "#{zone}"
admbox_ip = `host #{colo_admbox} | tail -n 1 | awk '{ print $NF }'`.chomp
ops_zone = "ops." + "#{zone}"
gateway_ip = `cat /etc/resolv.conf | grep -i nameserver | head -1 | awk '{ print $2 }'`.chomp
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
    flags "-ex"
    code <<-EOH
      hostname #{hostname_fqdn}
    EOH
  end
else
  bash "set_hostname" do
    flags "-ex"
    code <<-EOH
      start hostname
    EOH
  end
end

log 'Setting resolv.conf file.'
template "/etc/resolv.conf" do
    source "resolv.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :domain => domain,
      :ops_zone => ops_zone,
      :zone => zone,
      :gateway_ip => gateway_ip,
      :admbox_ip => admbox_ip,
      :google_ip => google_ip
    )
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
