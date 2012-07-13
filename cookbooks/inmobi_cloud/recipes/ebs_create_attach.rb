#
# Cookbook Name:: inmobi_cloud
# Recipe:: ebs_create_attach 
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

#Define cloud IDs and API URLs
inmobi_acct_id = "55593"
cloud_def = {"us-east" => 1, "eu-west" => 2, "us-west" => 3, "ap-southeast" => 4}
inmobi_rs_url = "https://my.rightscale.com/api/acct/#{inmobi_acct_id}/login?api_version=1.0"
inmobi_rs_volume_url = "https://my.rightscale.com/api/acct/#{inmobi_acct_id}/ec2_ebs_volumes"
inmobi_rs_servers_url = "https://my.rightscale.com/api/acct/#{inmobi_acct_id}/servers"

#Detect zone and region
aws_zone = "#{node.inmobi_cloud.availability_zone}".split('-')
aws_region = aws_zone[0..1].join('-')
hostname_fqdn = "#{node.inmobi_cloud.rs_hostname}".downcase

bash "rightscale_info" do
    code <<-EOH
      /usr/bin/curl -c /tmp/mySavedCookies -u "#{node[:inmobi_cloud][:rscale_username]}":"#{node[:inmobi_cloud][:rscale_password]}" #{inmobi_rs_url}
      /usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" #{inmobi_rs_volume_url} | grep "#{hostname_fqdn}"-vol | cut -d'>' -f2 | cut -d'<' -f1 | wc -l > /tmp/vol_verify
      /usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" #{inmobi_rs_volume_url} | grep "#{hostname_fqdn}"-vol | tail -n 1 | cut -d'>' -f2 | cut -d'<' -f1 > /tmp/vol_lastvol
    EOH
end

vol_verify = `cat /tmp/vol_verify`.chomp
if vol_verify != "0"
      present_vol = `cat /tmp/vol_lastvol`.chomp
      last_chr_str = present_vol[-1,1]
      last_chr = last_chr_str.to_i
end

if vol_verify == "0"
      disk_val = 1
      limit = node[:inmobi_cloud][:number_of_volumes]
else
      disk_val = last_chr + 1
      limit = last_chr + node[:inmobi_cloud][:number_of_volumes]
end

bash "rightscale_info" do
    code <<-EOH
	while #{disk_val} <= #{limit}
	      curl -X POST -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" -d "ec2_ebs_volume[nickname]=#{hostname_fqdn}-vol#{disk_val}" -d "ec2_ebs_volume[description]=#{hostname_fqdn}-Volume#{disk_val}" -d "ec2_ebs_volume[ec2_availability_zone]=#{node[:inmobi_cloud][:availability_zone]}" -d "ec2_ebs_volume[aws_size]=#{node[:inmobi_cloud][:size_of_volume]}" #{inmobi_rs_volume_url}
       	      #{disk_val} += 1
	end
    EOH
end
