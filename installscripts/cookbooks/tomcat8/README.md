tomcat8 Cookbook
================
Chef 11 compatible cookbook that installs tomcat8 in a basic configuration.
Partially based on the tomcat_latest cookbook by Chendil Kumar Manoharan
<mkchendil@gmail.com> under the Apache 2.0 license

Only been tested on Ubuntu and may only work on Ubuntu and perhaps Debian

Requirements
------------
#### packages
- `java` - tomcat8 needs java before it can be installed.

Attributes
----------
#### tomcat8::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['tomcat8']['download_url']</tt></td>
    <td>String</td>
    <td>Where to download tomcat from</td>
    <td><tt>http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33.tar.gz</tt></td>
  </tr>
  <tr>
    <td><tt>['tomcat8']['install_location']</tt></td>
    <td>String</td>
    <td>Default install location></td>
    <td><tt>/var/tomcat8</tt></td>
  </tr>
  <tr>
    <td><tt>['tomcat8']['port']</tt></td>
    <td>Number</td>
    <td>Default port for tomcat to use</td>
    <td><tt>8080</tt></td>
  </tr>
  <tr>
    <td><tt>['tomcat8']['ssl_port']</tt></td>
    <td>Number</td>
    <td>Default ssl port for tomcat</td>
    <td><tt>8443</tt></td>
  </tr>
  <tr>
    <td><tt>['tomcat8']['ajp_port']</tt></td>
    <td>Number</td>
    <td>Default ajp port for tomcat</td>
    <td><tt>8009</tt></td>
  </tr>
  <tr>
    <td><tt>['tomcat8']['tomcat_user']</tt></td>
    <td>String</td>
    <td>Default user for tomcat</td>
    <td><tt>root</tt></td>
  </tr>
  <tr>
    <td><tt>['tomcat8']['autostart']</tt></td>
    <td>Boolean</td>
    <td>Whether to autostart tomcat</td>
    <td><tt>true></tt></td>
  </tr>
</table>

Usage
-----
#### tomcat8::default
Just include `tomcat8` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[tomcat8]"
  ]
}
```
