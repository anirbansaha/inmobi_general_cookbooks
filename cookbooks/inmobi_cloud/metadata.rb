maintainer       "Anirban Saha"
maintainer_email "anirban.saha@inmobi.com"
license          "Apache 2.0"
description      "Installs/Configures inmobi_cloud"

version          "0.1"

recipe "inmobi_cloud::base_os_config", "Configures basic OS files"
recipe "inmobi_cloud::apt_repo_config", "Configures apt repo files"
recipe "inmobi_cloud::puppet_config", "Configures puppet and related services"

attribute "inmobi_cloud/rs_hostname",
 :display_name => "Nickname of the instance",
 :description => "The FQDN of the instance to be launched",
 :required => "required",
 :recipes => [ "inmobi_cloud::base_os_config", "inmobi_cloud::apt_repo_config" ]

attribute "inmobi_cloud/ec2_private_ip",
 :display_name => "IP of the instance",
 :description => "The private IP of the instance to be launched",
 :required => "required",
 :recipes => [ "inmobi_cloud::base_os_config" ]
