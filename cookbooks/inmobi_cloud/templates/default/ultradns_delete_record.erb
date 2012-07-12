#!/bin/env ruby
# == Synopsis 
# 
# Update UltraDNS with the local address of the instance. Based on
# dyndns_set.rb from the RightScript DNS Tools install suite
# 
# == Usage 
# 
# ruby ultradns_set.rb 
#      -i | --dnsid DNS_DNSID
#      [ -u | --user DNS_USER ] (Default: ENV['DNS_USER'] )
#      [ -p | --password DNS_PASSWORD ] (Default: ENV['DNS_PASSWORD'] )
#      [ -h | --help ] 
# 
# == Author 
# Anirban Saha, InMobi Inc
# 
# == Copyright 
# Copyright (c) 2012 InMobi, Inc, All Rights Reserved Worldwide.
#
# THIS PROGRAM IS CONFIDENTIAL AND PROPRIETARY TO RIGHTSCALE
# AND CONSTITUTES A VALUABLE TRADE SECRET.  Any unauthorized use,
# reproduction, modification, or disclosure of this program is
# strictly prohibited.  Any use of this program by an authorized
# licensee is strictly subject to the terms and conditions,
# including confidentiality obligations, set forth in the applicable
# License Agreement between RightScale.com, Inc. and
# the licensee.


# Rdoc related
require 'optparse' 

#require '/var/spool/ec2/meta-data.rb'
#require '/var/spool/ec2/user-data.rb'

def usage(code=0)
  out = $0.split(' ')[0] + " usage: \n"
  out << "  -i | --dnsid DNSID (For UltraDNS this is the fqdn you are setting) \n"
  out << "  [ -u | --user DNS_USER ] (Default: ENV['DNS_USER'] ) \n"
  out << "  [ -p | --password DNS_PASSWORD ] (Default: ENV['DNS_PASSWORD'] ) \n"
  out << "  [ -h | --help ]   "
  puts out
  Kernel.exit( code )
end

#Default options
options = { 
  :user => ENV['DNS_USER'],
  :password => ENV['DNS_PASSWORD']
}
opts = OptionParser.new 
opts.on("-h", "--help") { raise "Usage:" } 
opts.on("-i ", "--dnsid DNSID") {|str| options[:dnsid] = str } 
opts.on("-u ", "--user DNS_USER") {|str| options[:user] = str } 
opts.on("-p ", "--password DNS_PASS") {|str| options[:password] = str } 
begin
  opts.parse(ARGV) 
rescue Exception => e
  puts e 
  usage(-1) 
end

# Required options: DNSID
usage(-1) unless options[:dnsid] && options[:user] && options[:password]

zone_id,hostname=options[:dnsid].split(':')
username=options[:user]
password=options[:password]

modify_cmd=<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v01="http://webservice.api.ultra.neustar.com/v01/" xmlns:v011="http://schema.ultraservice.neustar.com/v01/">

<soapenv:Header>
<wsse:Security soapenv:mustUnderstand='1' xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>
<wsse:UsernameToken wsu:Id='UsernameToken-16318950' xmlns:wsu='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'>
<wsse:Username>#{username}</wsse:Username>
<wsse:Password Type='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'>#{password}</wsse:Password></wsse:UsernameToken>
</wsse:Security>
</soapenv:Header>

<soapenv:Body>
<v01:getResourceRecordList>
  <resourceRecord ZoneName="#{zone_id}." Type="0" DName="#{hostname}.">
  <v011:InfoValues Info1Value="?">?</v011:InfoValues>
  </resourceRecord>
</v01:getResourceRecordList>
</soapenv:Body>

</soapenv:Envelope>
EOF
cmd_filename="/tmp/modify.xml"
File.open(cmd_filename, "w") { |f| f.write modify_cmd }

ultra_url="https://ultra-api.ultradns.com/UltraDNS_WS/v01?wsdl"

result = ""
# Simple retry loop, sometimes the DNS call will flake out..
5.times do
  result = `curl -s -H 'Content-Type: text/xml;charset=UTF-8' -d @#{cmd_filename} '#{ultra_url}' | sed 's/Guid="/#/g' - | cut -d'#' -f2 | cut -d'"' -f1`
  break unless result =~ /fault/
end
modify_cmd_2=<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v01="http://webservice.api.ultra.neustar.com/v01/" xmlns:v011="http://schema.ultraservice.neustar.com/v01/">

<soapenv:Header>
<wsse:Security soapenv:mustUnderstand='1' xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>
<wsse:UsernameToken wsu:Id='UsernameToken-16318950' xmlns:wsu='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'>
<wsse:Username>#{username}</wsse:Username>
<wsse:Password Type='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'>#{password}</wsse:Password></wsse:UsernameToken>
</wsse:Security>
</soapenv:Header>

<soapenv:Body>
	<v01:deleteResourceRecord>
	<transactionID></transactionID>
	<guid>#{result}</guid>
	</v01:deleteResourceRecord>
</soapenv:Body>

</soapenv:Envelope>
EOF
cmd_filename="/tmp/modify.xml"
File.open(cmd_filename, "w") { |f| f.write modify_cmd_2 }

result_2 = ""
# Simple retry loop, sometimes the DNS call will flake out..
5.times do
  result_2 = `curl -s -H 'Content-Type: text/xml;charset=UTF-8' -d @#{cmd_filename} '#{ultra_url}'`
  break unless result_2 =~ /fault/
end
