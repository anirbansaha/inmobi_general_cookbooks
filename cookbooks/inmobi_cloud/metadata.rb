maintainer       "Anirban Saha"
maintainer_email "anirban.saha@inmobi.com"
license          "Apache 2.0"
description      "Installs/Configures inmobi_cloud"

version          "0.1"

recipe "inmobi_cloud::base_os_config", "Configures basic OS files"
recipe "inmobi_cloud::apt_repo_config", "Configures apt repo files"
recipe "inmobi_cloud::puppet_config", "Configures puppet and related services"
recipe "inmobi_cloud::dns_add_record", "Adds DNS entry in UltraDNS"
recipe "inmobi_cloud::dns_delete_record", "Removes DNS entry for UltraDNS"
recipe "inmobi_cloud::hostname_change_config", "Reconfigures instance on hostname change, has to be run after changing the nickname of the instance"
recipe "inmobi_cloud::ebs_create_attach", "Creates ebs volumes and attaches to the instance based on the inputs entered, i.e. number of volumes required and size of each volume"

attribute "inmobi_cloud/rs_hostname",
 :display_name => "Nickname of the instance",
 :description => "The FQDN of the instance to be launched, has to be set to the ENV variable RS_SERVER_NAME from RS dashboard inputs",
 :required => "required",
 :recipes => [ "inmobi_cloud::base_os_config", "inmobi_cloud::apt_repo_config", "inmobi_cloud::dns_add_record", "inmobi_cloud::dns_delete_record", "inmobi_cloud::hostname_change_config" ]

attribute "inmobi_cloud/ec2_private_ip",
 :display_name => "IP of the instance",
 :description => "The private IP of the instance to be launched, has to be set to the ENV variable PRIVATE_IP from RS dashboard inputs",
 :required => "required",
 :recipes => [ "inmobi_cloud::base_os_config", "inmobi_cloud::dns_add_record", "inmobi_cloud::dns_delete_record", "inmobi_cloud::hostname_change_config" ]

attribute "inmobi_cloud/availability_zone",
 :display_name => "Availability zone of the instance",
 :description => "The ec2 availability zone of the instance to be launched, has to be set to the ENV variable EC2_AVAILABILITY_ZONE from RS dashboard inputs",
 :required => "required",
 :recipes => [ "inmobi_cloud::base_os_config", "inmobi_cloud::hostname_change_config", "inmobi_cloud::ebs_create_attach" ]

attribute "inmobi_cloud/dns_username",
 :display_name => "UltraDNS username",
 :description => "The username required to make UltraDNS API call, has to be set to the CREDENTIAL variable UDNS_USER from RS dashboard inputs",
 :required => "required",
 :recipes => [ "inmobi_cloud::dns_add_record", "inmobi_cloud::dns_delete_record", "inmobi_cloud::hostname_change_config" ]

attribute "inmobi_cloud/dns_password",
 :display_name => "UltraDNS password",
 :description => "The password required to make UltraDNS API call, has to be set to the CREDENTIAL variable UDNS_PASSWD from RS dashboard inputs",
 :required => "required",
 :recipes => [ "inmobi_cloud::dns_add_record", "inmobi_cloud::dns_delete_record", "inmobi_cloud::hostname_change_config" ]

attribute "inmobi_cloud/rscale_username",
 :display_name => "RightScale username",
 :description => "The username required to make RightScale API call, has to be set to the CREDENTIAL variable RSCALE_USER from RS dashboard inputs",
 :required => "required",
 :recipes => [ "inmobi_cloud::ebs_create_attach" ]

attribute "inmobi_cloud/rscale_password",
 :display_name => "RightScale password",
 :description => "The password required to make RightScale API call, has to be set to the CREDENTIAL variable RSCALE_PASSWD from RS dashboard inputs",
 :required => "required",
 :recipes => [ "inmobi_cloud::ebs_create_attach" ]

attribute "inmobi_cloud/number_of_volumes",
 :display_name => "Number of EBS volumes required",
 :description => "Number of EBS volumes required to be created and attached to the instance",
 :required => "required",
 :recipes => [ "inmobi_cloud::ebs_create_attach" ]

attribute "inmobi_cloud/size_of_volume",
 :display_name => "Size of EBS volumes required",
 :description => "Size of EBS volumes required to be created and attached to the instance",
 :required => "required",
 :recipes => [ "inmobi_cloud::ebs_create_attach" ]
