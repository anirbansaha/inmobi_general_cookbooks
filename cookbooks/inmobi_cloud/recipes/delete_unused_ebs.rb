#
# Cookbook Name:: inmobi_cloud
# Recipe:: delete_unused_ebs
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
cloud_def = {"us-east" => 1, "eu-west" => 2, "us-west" => 3, "ap-southeast" => 4}
inmobi_rs_url = node[:inmobi_cloud][:rs_login_url]
inmobi_rs_volume_url = node[:inmobi_cloud][:rs_volume_url]

bash "volume_deletion" do
    code <<-EOH
	/usr/bin/curl -c /tmp/mySavedCookies -u "#{node[:inmobi_cloud][:rscale_username]}":"#{node[:inmobi_cloud][:rscale_password]}" #{inmobi_rs_url}	
	for cloud_id_num in {1..4}
	do
		curl -X GET -s -H "X-API-VERSION: 1.0" -b /tmp/mySavedCookies -d "cloud_id=$cloud_id_num" #{inmobi_rs_volume_url} | grep -A9 available | grep href | sed 's/href>/#/g' | cut -d'<' -f2 | sed 's/#//g' >> /tmp/volumes
	done
	for url in `cat /tmp/volumes`
    	do
        	curl -X DELETE -s -H "X-API-VERSION: 1.0" $url -b /tmp/mySavedCookies
    	done
	rm -f /tmp/volumes /tmp/mySavedCookies
    EOH
end

