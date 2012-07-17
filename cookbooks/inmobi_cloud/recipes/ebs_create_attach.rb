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
#template "/tmp/vol_lastvol" do
#    source "blankfile.erb"
#    owner "root"
#    group "root"
#    mode "0644"
#end
#template "/tmp/vol_verify" do
#    source "blankfile.erb"
#    owner "root"
#    group "root"
#    mode "0644"
#end
#template "/tmp/server_url" do
#    source "blankfile.erb"
#    owner "root"
#    group "root"
#    mode "0644"
#end
#template "/tmp/disk" do
#    source "blankfile.erb"
#    owner "root"
#    group "root"
#    mode "0644"
#end

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
    EOH
end
last_chr = 0
disk_val = 0
limit = 0
vol_verify_out = `/usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" #{inmobi_rs_volume_url} | grep "#{hostname_fqdn}"-vol | cut -d'>' -f2 | cut -d'<' -f1 | wc -l`.chomp
vol_verify = vol_verify_out.to_s
log "#{vol_verify}"
#if File.exist?("/tmp/vol_verify")
#	f_vol = File.open("/tmp/vol_verify")
#	vol_verify_out_raw = f_vol.read
#	vol_verify_out = vol_verify_out_raw.chomp
#	f_vol.close
#	vol_verify = vol_verify_out.to_s
#end

if vol_verify != "0"
#   if File.exist?("/tmp/vol_lastvol")
#      f_present_vol = File.open("/tmp/vol_lastvol")
#      present_vol_raw = f_present_vol.read
#      present_vol = present_vol_raw.chomp
#      f_present_vol.close
      present_vol = `/usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" #{inmobi_rs_volume_url} | grep "#{hostname_fqdn}"-vol | tail -n 1 | cut -d'>' -f2 | cut -d'<' -f1`.chomp
      last_chr_str = present_vol[-1,1]
      last_chr = last_chr_str.to_i
#   end
end
log "#{last_chr}"

if vol_verify == "0"
      disk_val = 1
      limit = node[:inmobi_cloud][:number_of_volumes].to_i
else
      disk_val = last_chr + 1
      limit = last_chr + node[:inmobi_cloud][:number_of_volumes].to_i
end

log "#{disk_val} #{limit}"

bash "volume_creation" do
    code <<-EOH
	for (( num=#{disk_val}; num<=#{limit}; num++ ))
	do
	      /usr/bin/curl -X POST -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" -d "ec2_ebs_volume[nickname]=#{hostname_fqdn}-vol$num" -d "ec2_ebs_volume[description]=#{hostname_fqdn}-Volume$num" -d "ec2_ebs_volume[ec2_availability_zone]=#{node[:inmobi_cloud][:availability_zone]}" -d "ec2_ebs_volume[aws_size]=#{node[:inmobi_cloud][:size_of_volume]}" #{inmobi_rs_volume_url}
	done
    EOH
end

sleep(200)
server_id = `/usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies #{inmobi_rs_servers_url} | grep -A2 #{hostname_fqdn} | grep href | sed 's/href>/#/g' | cut -d'<' -f2 | sed 's/#//g' | cut -d'/' -f8`.chomp
#if File.exist?("/tmp/server_url")
#	f_server = File.open("/tmp/server_url")
#	this_server_url_raw = f_server.read
#	this_server_url = this_server_url_raw.chomp
#	f_server.close
#end
this_server_volume_url = "#{inmobi_rs_servers_url}" + "/#{server_id}" + "/attach_volume"
log "#{this_server_url}"
log "#{this_server_volume_url}"

bash "get_volume_list" do
    code <<-EOH
	/usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" #{inmobi_rs_volume_url} | grep -A9 available | grep -A3 #{hostname_fqdn} | grep href | sed 's/href>/#/g' | cut -d'<' -f2 | sed 's/#//g' > /tmp/volumes
    EOH
end

first_device = ""
last_device = `ls -l /dev | grep disk | grep sd | awk '{ print $NF }' | sort | grep -A20 sdk | tail -n 1`.chomp
#if File.exist?("/tmp/disk")
#	f_device = File.open("/tmp/disk")
#	last_device_raw = f_device.read
#	last_device = last_device_raw.chomp
#	f_device.close
#end
if last_device == ""
    first_device = "sdk"
else
    disk_verify_val = last_device[-1]
    new_device_val = disk_verify_val + 1
    new_device_chr = new_device_val.chr 
    first_device = "sd" + "#{new_device_chr}"
end
log "#{first_device}"
device_val = first_device[-1]
device_limit = device_val + node[:inmobi_cloud][:number_of_volumes].to_i

bash "volume_attachment" do
    code <<-EOH
	for (( num=#{device_val}; num<#{device_limit}; num++ ))
	    do
       		for url in `cat /tmp/volumes`
          	do
              		export AVALUE_LDISK=$num
              		DISKCHR=`perl -e 'printf "%c\n", $ENV{'AVALUE_LDISK'};'`
              		DEVICE=/dev/sd$DISKCHR
              		/usr/bin/curl -X POST  -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "server[ec2_ebs_volume_href]=$url" -d "server[device]=$DEVICE" #{this_server_volume_url}
             	 	sed -i '1,1d' /tmp/volumes
              		break
          	done
	    done
    EOH
end
sleep(240)
