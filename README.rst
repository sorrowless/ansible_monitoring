What this repository is about
=============================

This repository is a set of ansible playbooks and roles to easy install pretty
complex monitoring suite which is too tedious to install manually. This
monitoring suite consist of Prometheus (with carbon and Alertmanager),
Prometheus Graphite exporter (to be able of get data which was originally
created for Graphite), Graphite TSDB, Grafana and CollectD daemon. How it is
originally works:

#. You determine what you want to monitor (list of available monitoring
   entities is listed below.
#. Inventory files and group variable files are created by you.
#. CollectD daemon is originally set to the nodes which need to be monitored
   by it.
#. Special monitoring host is creating. It consists of CollectD daemon in
   Network Server mode, local Bind9 server, docker containers with Prometheus,
   Alertmanager, Prometheus Graphite Exporter, Graphite, Grafana, Docker-DDNS
   updater.
#. CollectD daemons start to send the data about monitored machines to the
   CollectD daemon which ran on monitor node via encrypted by CollectD network
   channel.
#. CollectD on monitor node gets the data and sends it to 2 places. First is
   a Graphite instance, which is saves the data to give it to the Grafana
   later. Second one is Prometheus Graphite Exporter instance (nowadays
   Prometheus is directly supported by CollectD, but Exporter is officially
   supported also and gives you an ability to use mappings with additional
   fields in it. Moreover, Prometheus CollectD Exporter is far better
   documented than CollectD write_prometheus plugin). This instance gives the
   data CollectD feed into it and converts it to the format understandable by
   Prometheus itself. Then it gives it to the Prometheus which takes it and
   stores in its internal TSDB called Carbon.
#. Prometheus constantly looks at the alert rules defined in its config and if
   something went wrong, send alerts to the Alertmanager.
#. Alertmanager gets the alerts and sends it to the targer user by email, Slack
   or webhook.

What can be monitored by this solution
======================================

CollectD role allows you monitor next data:

- CPU metrics. To do so, add ``collectd_cpu: true`` to the group variables file
- HTTP response time and code from the given URL. To do so, add
  ``collectd_curl: true`` and ``collectd_curl_pages:`` with list of pages you
  need to curl
- Disk space info. Add ``collectd_df: true`` to the group variables file
- Disk read and write stats. Add ``collectd_disk: true``
- Entropy info. Add ``collectd_entropy: true``
- Interfaces RX and TX info. Add ``collectd_interface: true``
- Load average info. Add ``collectd_load: true``
- Memory usage info. Add ``collectd_memory: true``
- Mysql DB usage info. Add ``collectd_mysql: true`` and
  ``collectd_mysql_databases:`` with list of hashes in next format as a value:

  ::
  
    -
     name: db name
     hostname: hostname of a db
     username: user with which you can connect to the db
     password: password for the username
     
- Be a network server (usually enabled only on monitor node). Add
  ``collectd_network_server: true``
- Be a network client. Add ``collectd_network_client: true``
- Ping of some node info. Add ``collectd_ping: true`` and
  ``collectd_ping_targets:`` with list of nodes to ping as a value
- Results of port check info. Add ``collectd_port_check: true`` and
  ``collectd_port_data:`` with list of hashes with target node info as a value:

  ::
  
    -
     host: host.domain
     port: port number
     timeout: how long to wait an answer
     
- Node processes info. Add ``collectd_processes: true``
- Systemd services status info. Add ``collectd_systemd: true`` and
  ``collectd_systemd_services:`` with list of services names as a value
- Swap usage info. Add ``collectd_swap: true``
- File data changes. Allows you to give the values from some file (like a log
  file) and send changed data, given to you by a regexp. Add ``collectd_tail:
  true`` and ``collectd_tail_files:`` with list of hashes as a value. Here is
  an example of such hash:

  ::
  
    -
     filename: /var/log/nginx/access.log
     instance: nginx
     matches:
       -
        regex: '^(.* ){5}\"(GET|POST).*HTTP/[12]\.[012]\" 2[0-9][0-9] [0-9]+ \"http(s)?://.*\" \".*\"$'
        dstype: CounterInc
        type: derive
        instance: code_2xx
        
- Node uptime info. Add ``collectd_uptime: true``
- Node logged users info. Add ``collectd_users: true``
- CollectD ability to use Graphite to write into. Add
  ``collectd_write_graphite: true`` and ``graphite_hosts:`` with list of hashes
  as value. Example of such hash:

  ::
  
    graphite_host:
      hostname: host name of Graphite instance
      port: port number of listening Graphite instance

How to add my own configuration?
================================

To add your own configuration of hosts to use, you need to create a new name
for group of hosts to use. Say, use name **damnawesome**. You will need to
create two files:

- *damnawesome.yml* in ``inventory`` directory. It is a usual inventory file.
  Some groups **must** be defined in it. Look at existing files in this dir and
  just create your own based on them.
- *damnawesome.yml* in ``group_vars`` directory. It is a yaml file with all
  the variables needed to your deployment. Look at *all.yml* and *testing.yml*
  files in that directory to understand which type of values you need. Also
  look at ``defaults`` directories of roles (especially at collectd one) to
  understand which types of values you should override for your deployment.

How to run all of this?
=======================

To run all of this, just run *run_monitoring.sh* script based in root directory
of this repository with your name (*damnawesome* from previous article, for
example). You will be asked of some connection questions and then some ansible
output will be shown. After this you will get full-fledged monitoring solution
on given nodes.


Something doesn't work, I don't know what to do!!
=================================================

Try to find a problem and create a pull-request. Or just file a new issue.
