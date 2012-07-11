rs_utils_marker :begin

local_ip = "#{node.inmobi_cloud.ec2_private_ip}"
hostname_fqdn = "#{node.inmobi_cloud.rs_hostname}"
cloud_colo = {"us-east" => "ev1.inmobi.com", "eu-west" => "ir1.inmobi.com", "us-west" => "wc1.inmobi.com", "ap-southeast" => "sg1.inmobi.com"}
aws_zone = "#{node.inmobi_cloud.availability_zone}".split('-')
aws_region = aws_zone[0..1].join('-')
log "#{aws_region}"


rs_utils_marker :end
