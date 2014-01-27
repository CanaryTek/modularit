Description
===========

ModularIT is a set of utils for managing a big number of servers

Requirements
============

Cookbooks
---------

The modularit cookbook uses the following cookbooks

##### Rasca

A cookbook for managing the Rasca monitoring framework

Roles
=====

The ModularIT cookbook uses the following roles:

ModularIT basic roles
---------------------

* modularit_base: base ModularIT role. All modularit servers should have this role
* modularit_security: Hosts with ModularIT security checks
* monitoring: Monitoring servers (used by Nagios cookbook)
* tripwire: Hosts with tripwire checks
* private: This role means that the host is not reachable from the monitoring server because it's behind a firewall
* not_exposed: Hosts with no services exposed to public. Will not run security checks
* not_ssh_exposed: Hosts with SSH not exposed to public. Will not run SSH security checks

Organizational roles
--------------------

These roles are only for organizational purposes. We use a role for each client we manage.

Service roles
-------------

* apache_server
* nginx_server
* postgres_server
* modularit_security
* mysql_server
* postfix_server

Attributes
==========

Usage
=====

