# Cookbook Name:: inmobi_cloud
# Recipe:: puppet_config
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
puppet_ssl_dir = "/var/lib/puppet/ssl"

#Check if puppet already running
if `ps aux | grep service-puppe[t]` != ""
    if File.exist?(puppet_ssl_dir)
         system "/bin/rm -r #{puppet_ssl_dir}"
         exit(0)
    else
         exit(0)
    end
end

if platform?('ubuntu', 'debian')
  bash "install_puppet_services" do
    code <<-EOH
      /usr/bin/apt-get -y --force-yes install puppet > /dev/null 2>&1
      /usr/bin/apt-get -y --force-yes install service-puppet > /dev/null 2>&1
    EOH
  end
end
