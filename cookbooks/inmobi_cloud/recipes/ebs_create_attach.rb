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
size = node[:inmobi_cloud][:size_of_volume].to_i
vol_qty = node[:inmobi_cloud][:number_of_volumes].to_i
aws_zone = "#{node.inmobi_cloud.availability_zone}"
aws_zone_array = aws_zone.split('-')
aws_region = aws_zone_array[0..1].join('-')
hostname_fqdn = "#{node.inmobi_cloud.rs_hostname}".downcase


bash "volume_creation" do
    code <<-EOH
      /usr/bin/curl -c /tmp/mySavedCookies -u "#{node[:inmobi_cloud][:rscale_username]}":"#{node[:inmobi_cloud][:rscale_password]}" #{inmobi_rs_url}
      /usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" #{inmobi_rs_servers_url} | grep -A2 #{hostname_fqdn} | grep href | sed 's/href>/#/g' | cut -d'<' -f2 | sed 's/#//g' > /tmp/server_id
      server_id=`cat /tmp/server_id`
      server_url=$server_id"/attach_volume"
      echo $server_url > /tmp/server_url
      vol_verify=`/usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" #{inmobi_rs_volume_url} | grep "#{hostname_fqdn}"-vol | wc -l`
      vol_lastvol=`/usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" #{inmobi_rs_volume_url} | grep "#{hostname_fqdn}"-vol | tail -n 1 | cut -d'>' -f2 | cut -d'<' -f1`
      vol_lastvol_chr=${vol_lastvol#${vol_lastvol%?}}
      if [ $vol_verify = "0" ]
      then
      	disk_val=1
      	limit=#{vol_qty}
      else
      	disk_val=`expr $vol_lastvol_chr + 1`
      	limit=`expr $vol_lastvol_chr + #{vol_qty}`
      fi

      for (( num=$disk_val; num<=$limit; num++ ))
      do
        curl -X POST -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" -d "ec2_ebs_volume[nickname]=#{hostname_fqdn}-vol$num" -d "ec2_ebs_volume[description]=#{hostname_fqdn}-Volume$num" -d "ec2_ebs_volume[ec2_availability_zone]=#{aws_zone}" -d "ec2_ebs_volume[aws_size]=#{size}" #{inmobi_rs_volume_url}
      done
    EOH
end

sleep(200)
bash "get_volume_list" do
    code <<-EOH
	/usr/bin/curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=#{cloud_def[aws_region]}" #{inmobi_rs_volume_url} | grep -A9 available | grep -A3 #{hostname_fqdn} | grep href | sed 's/href>/#/g' | cut -d'<' -f2 | sed 's/#//g' > /tmp/volumes
    EOH
end

first_device = ""
last_device = `ls -l /dev | grep disk | grep sd | awk '{ print $NF }' | sort | grep -A20 sdk | tail -n 1`.chomp
if last_device == ""
    first_device = "sdk"
else
    disk_verify_val = last_device[-1]
    new_device_val = disk_verify_val + 1
    new_device_chr = new_device_val.chr 
    first_device = "sd" + "#{new_device_chr}"
end
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
              		/usr/bin/curl -X POST  -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "server[ec2_ebs_volume_href]=$url" -d "server[device]=$DEVICE" `cat /tmp/server_url`
             	 	sed -i '1,1d' /tmp/volumes
              		break
          	done
	    done
	rm -f /tmp/vol* /tmp/server* /tmp/mySavedCookies
    EOH
end
