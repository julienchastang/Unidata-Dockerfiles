<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#orgheadline1">1. Preamble</a></li>
<li><a href="#orgheadline11">2. Preliminary Setup on Azure</a>
<ul>
<li><a href="#orgheadline2">2.1. <code>docker-machine</code></a></li>
<li><a href="#orgheadline3">2.2. Create a VM on Azure.</a></li>
<li><a href="#orgheadline4">2.3. Configure Unix Shell to Interact with New Azure VM.</a></li>
<li><a href="#orgheadline5">2.4. <code>ssh</code> into VM with <code>docker-machine</code></a></li>
<li><a href="#orgheadline6">2.5. Install Package(s) with <code>apt-get</code></a></li>
<li><a href="#orgheadline7">2.6. Add <code>ubuntu</code> User to <code>docker</code> Group and Restart Docker</a></li>
<li><a href="#orgheadline8">2.7. Restart Azure VM</a></li>
<li><a href="#orgheadline9">2.8. <code>ssh</code> into VM</a></li>
<li><a href="#orgheadline10">2.9. Install <code>docker-compose</code> on VM</a></li>
</ul>
</li>
<li><a href="#orgheadline27">3. LDM and TDS Configuration</a>
<ul>
<li><a href="#orgheadline14">3.1. Background</a>
<ul>
<li><a href="#orgheadline12">3.1.1. <code>Unidata-Dockerfiles</code></a></li>
<li><a href="#orgheadline13">3.1.2. <code>TDSConfig</code></a></li>
</ul>
</li>
<li><a href="#orgheadline15">3.2. <code>git clone</code> Repositories</a></li>
<li><a href="#orgheadline24">3.3. Configuring the LDM</a>
<ul>
<li><a href="#orgheadline16">3.3.1. LDM Directories on Docker Host</a></li>
<li><a href="#orgheadline22">3.3.2. LDM Configuration Files</a></li>
<li><a href="#orgheadline23">3.3.3. Upstream Data Feed from Unidata or Elsewhere</a></li>
</ul>
</li>
<li><a href="#orgheadline26">3.4. Configuring the TDS</a>
<ul>
<li><a href="#orgheadline25">3.4.1. Edit TDS catalog.xml Files</a></li>
</ul>
</li>
</ul>
</li>
<li><a href="#orgheadline30">4. Setting up Data Volumes</a>
<ul>
<li><a href="#orgheadline28">4.1. Check Free Disk Space</a></li>
<li><a href="#orgheadline29">4.2. Create <code>/data</code> Directory</a></li>
</ul>
</li>
<li><a href="#orgheadline31">5. Opening Ports</a></li>
<li><a href="#orgheadline32">6. Tomcat Logging for TDS and RAMADDA</a></li>
<li><a href="#orgheadline37">7. Starting the LDM TDS RAMADDA TDM</a>
<ul>
<li>
<ul>
<li><a href="#orgheadline33">7.0.1. RAMADDA Preconfiguration</a></li>
<li><a href="#orgheadline34">7.0.2. Final Edit to <code>docker-compose.yml</code></a></li>
<li><a href="#orgheadline35">7.0.3. Pull Down Images from the DockerHub Registry</a></li>
<li><a href="#orgheadline36">7.0.4. Start the LDM, TDS, TDM, RAMADDA</a></li>
</ul>
</li>
</ul>
</li>
<li><a href="#orgheadline43">8. Check What is Running</a>
<ul>
<li><a href="#orgheadline38">8.1. Docker Process Status</a></li>
<li><a href="#orgheadline39">8.2. TDS and RAMADDA URLs</a></li>
<li><a href="#orgheadline42">8.3. Viewing Data with the IDV</a>
<ul>
<li><a href="#orgheadline40">8.3.1. Access TDS with the IDV</a></li>
<li><a href="#orgheadline41">8.3.2. Access RAMADDAA with the IDV</a></li>
</ul>
</li>
</ul>
</li>
</ul>
</div>
</div>


# Preamble<a id="orgheadline1"></a>

The following instructions describe how to configure a [Microsoft Azure VM](https://azure.microsoft.com) serving data with the [LDM](http://www.unidata.ucar.edu/software/ldm/), [TDS](http://www.unidata.ucar.edu/software/thredds/current/tds/), and [RAMADDA](http://sourceforge.net/projects/ramadda/). This document assumes you have access to Azure resources though these instructions should be fairly similar on other cloud providers (e.g., Amazon). They also assume familiarity with Unix, Docker, and Unidata technology in general. You will have to be comfortable entering command at the Unix command line. We will be using Docker images defined at the [Unidata-Dockerfiles repository](https://github.com/Unidata/Unidata-Dockerfiles) in addition to a configuration specifically planned for AMS 2016 demonstrations  project [AMS 2016 demonstrations  project](https://github.com/Unidata/Unidata-Dockerfiles/tree/master/ams2016).

# Preliminary Setup on Azure<a id="orgheadline11"></a>

The instructions assume we will create an Azure VM called `unidata-server.cloudapp.net` abbreviated to `unidata-server`. Tailor the VM name for your purposes when following this document. This VM will be our **Docker Host** from where we will run Docker containers for the LDM, TDS, and RAMADDA.

## `docker-machine`<a id="orgheadline2"></a>

[Install](https://docs.docker.com/machine/install-machine/) `docker-machine` on your local computer. `docker-machine` is a command line tool that gives users the ability to create Docker VMs on your local computer or on a cloud provider such as Azure.

## Create a VM on Azure.<a id="orgheadline3"></a>

The following `docker-machine` command will create a Docker VM on Azure in which you will run various Docker containers. It will take a few minutes to run (between 5 and 10 minutes). You will have to supply `azure-subscription-id` and `azure-subscription-cert` path. See these Azure `docker-machine` [instructions](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-docker-machine/), if you have questions about this process.

    docker-machine -D create -d azure \
                   --azure-subscription-id="3.141" \
                   --azure-subscription-cert="/path/to/mycert.pem" \
                   --azure-size="ExtraLarge" unidata-server

## Configure Unix Shell to Interact with New Azure VM.<a id="orgheadline4"></a>

Execute the following command in your local computer shell environment.

    eval "$(docker-machine env unidata-server)"

## `ssh` into VM with `docker-machine`<a id="orgheadline5"></a>

    docker-machine ssh unidata-server

## Install Package(s) with `apt-get`<a id="orgheadline6"></a>

At the very least, we will need `unzip` on the Azure Docker host.

    sudo apt-get -qq update
    sudo apt-get -qq install unzip

## Add `ubuntu` User to `docker` Group and Restart Docker<a id="orgheadline7"></a>

    sudo usermod -G docker ubuntu
    sudo service docker restart

## Restart Azure VM<a id="orgheadline8"></a>

At this point, we want to restart the VM to get a fresh start. This command may take a little while&#x2026;

    docker-machine restart unidata-server
    eval "$(docker-machine env unidata-server)"

## `ssh` into VM<a id="orgheadline9"></a>

    docker-machine ssh unidata-server

## Install `docker-compose` on VM<a id="orgheadline10"></a>

`docker-compose` is a tool for defining and running multi-container Docker applications. In our case, we will be running the LDM, TDS, TDM (THREDDS Data Manager) and RAMADDA so `docker-compose` is perfect for this scenario. Install `docker-compose` on the Azure Docker host.

"You may have to update version (currently at `1.5.2`).

     curl -L \
    https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` \
          > docker-compose
     sudo mv docker-compose /usr/local/bin/
     sudo chmod +x /usr/local/bin/docker-compose

# LDM and TDS Configuration<a id="orgheadline27"></a>

## Background<a id="orgheadline14"></a>

At this point, we have done the preliminary legwork to tackle the next step in this process. We will now want to clone two repositories that will allow us to configure and start running the the LDM, TDS, and RAMADDA. In particular, we will be cloning:

-   [`github.com/Unidata/Unidata-Dockerfiles`](https://github.com/Unidata/Unidata-Dockerfiles)
-   [`github.com/Unidata/TdsConfig`](https://github.com/Unidata/TdsConfig)

### `Unidata-Dockerfiles`<a id="orgheadline12"></a>

The `Unidata-Dockerfiles` repository contains a number of Dockerfiles that pertain to various Unidata technologies (e.g., the LDM) and also projects (e.g., ams2016). As a matter of background information, a `Dockerfile` is a text file that contains commands to build a Docker image containing, for example, a working LDM. These Docker images can subsequently be run by `docker` command line tools, or `docker-compose` commands that rely on a `docker-compose.yml` file. A `docker-compose.yml` file is a text file that captures exactly how one or more containers run including directory mappings (from outside to within the container), port mappings (from outside to within the container), and other information.

### `TDSConfig`<a id="orgheadline13"></a>

The `TDSConfig` repository is a project that captures THREDDS and LDM configuration files (e.g., `catalog.xml`, `pqact.conf`) for the TDS at <http://thredds.ucar.edu>. Specifically, these TDS and LDM configurations were meant to work in harmony with one another. We can re-use this configuration with some minor adjustments for running the TDS on the Azure cloud.

## `git clone` Repositories<a id="orgheadline15"></a>

With that background information out of the way, let's clone those repositories by creating `~/git` directory where our repositories will live and issuing some `git` commands.

    mkdir -p /home/ubuntu/git
    git clone https://github.com/Unidata/Unidata-Dockerfiles \
        /home/ubuntu/git/Unidata-Dockerfiles
    git clone https://github.com/Unidata/TdsConfig /home/ubuntu/git/TdsConfig

## Configuring the LDM<a id="orgheadline24"></a>

### LDM Directories on Docker Host<a id="orgheadline16"></a>

For anyone who has worked with the LDM, you may be familiar with the following directories:

    etc/
    var/data
    var/logs
    var/queue

The LDM `etc` directory is where you will find configuration files related to the LDM including `ldmd.conf`, `pqact` files, `registry.xml`, and  `scour.conf`. We will need the ability to easily observe and manipulate the files from **outside** the running LDM container. To that end, we need to find a home for `etc` on the Docker host. The same is true for the `var/data` and `var/logs` directories. Later, we will use Docker commands that have been written on your behalf to mount these directories from **outside** to within the container. The `var/queues` directory will remain inside the container.

    mkdir -p ~/var/logs 
    mkdir -p ~/etc/TDS

`var/data` is a bit different in that it needs to be mounted on data volume on the Docker host. We will be handling that step further on.

### LDM Configuration Files<a id="orgheadline22"></a>

There is a generic set of LDM configuration files located here `~/git/Unidata-Dockerfiles/ldm/etc/`. However, we will just grab `netcheck.conf` which will remain unmodified.

    cp ~/git/Unidata-Dockerfiles/ldm/etc/netcheck.conf ~/etc

The rest of the LDM configuration files will come from our `ams2016` project directory.

Also, remember that these files will be used **inside** the LDM container that we will set up shortly. We will now be working with these files:

-   `ldmd.conf`
-   `registry.xml`
-   `scour.conf`

1.  `ldmd.conf`

        cp ~/git/Unidata-Dockerfiles/ams2016/ldmd.conf ~/etc/
    
    This `ldmd.conf` has been setup for the AMS 2016 demonstration serving the following data feeds:
    
    -   [13km Rapid Refresh](http://rapidrefresh.noaa.gov/)
    -   [NESDIS GOES Satellite Data](http://www.nesdis.noaa.gov/imagery_data.html)
    -   Unidata NEXRAD Composites
    
    In addition, there is a `~/git/TdConfig/idd/pqacts/README.txt` file that may be helpful in writing a suitable `ldmd.conf` file.

2.  `registry.xml`

        cp ~/git/Unidata-Dockerfiles/ams2016/registry.xml ~/etc/
    
    This file has been set up for the AMS 2016 demonstration. Otherwise you would have to edit the `registry.xml` to ensure the `hostname` element is correct. For your own cloud VMs, work with `support-idd@unidata.ucar.edu` to devise a correct `hostname` element so that LDM statistics get properly reported. Here is an example `hostname` element `unidata-server.azure.unidata.ucar.edu`.

3.  `scour.conf`

    You need to scour data or else your disk will full up. The crontab entry that runs scour is in the [LDM Docker container](https://github.com/Unidata/Unidata-Dockerfiles/blob/master/ldm/crontab). Scouring is invoked once per day.
    
        cp ~/git/Unidata-Dockerfiles/ams2016/scour.conf ~/etc/

4.  `pqact.conf` and TDS configuration

    In the `ldmd.conf` file we copied just a moment ago there is a reference to a `pqact` file; `etc/TDS/pqact.forecastModels`. We need to ensure that file exists by doing the following instructions. Specifically, explode `~/git/TdsConfig/idd/config.zip` into `~/tdsconfig` and `cp -r` the `pqacts` directory into `~/etc/TDS`. **Note** do NOT use soft links. Docker does not like them.
    
        mkdir -p ~/tdsconfig/
        cp ~/git/TdsConfig/idd/config.zip ~/tdsconfig/
        unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
        cp -r ~/tdsconfig/pqacts/* ~/etc/TDS

5.  Edit `ldmfile.sh`

    As the top of this file indicates, you must edit the `logfile` to suit your needs. Change the 
    
        logfile=logs/ldm-mcidas.log
    
    line to
    
        logfile=var/logs/ldm-mcidas.log
    
    This will ensure `ldmfile.sh` can properly invoked from the `pqact` files.

### Upstream Data Feed from Unidata or Elsewhere<a id="orgheadline23"></a>

The LDM operates on a push data model. You will have to find someone who will agree to push you the data. If you are part of the American academic community please send a support email to `support-idd@unidata.ucar.edu` to discuss your LDM data requirements.

## Configuring the TDS<a id="orgheadline26"></a>

### Edit TDS catalog.xml Files<a id="orgheadline25"></a>

The `catalog.xml` files for TDS configuration are contained within the `~/tdsconfig` directory. Search for all files terminating in `.xml` in that directory. Edit the xml files for what data you wish to server. See the [TDS Documentation](http://www.unidata.ucar.edu/software/thredds/current/tds/catalog/index.html) for more information on editing these XML files.

Let's see what is available in the `~/tdsconfig` directory.

    find ~/tdsconfig -type f -name "*.xml"

    /home/ubuntu/tdsconfig/idd/forecastModels.xml
    /home/ubuntu/tdsconfig/idd/radars.xml
    /home/ubuntu/tdsconfig/idd/obsData.xml
    /home/ubuntu/tdsconfig/idd/forecastProdsAndAna.xml
    /home/ubuntu/tdsconfig/idd/satellite.xml
    /home/ubuntu/tdsconfig/radar/CS039_L2_stations.xml
    /home/ubuntu/tdsconfig/radar/CS039_stations.xml
    /home/ubuntu/tdsconfig/radar/RadarNexradStations.xml
    /home/ubuntu/tdsconfig/radar/RadarTerminalStations.xml
    /home/ubuntu/tdsconfig/radar/RadarL2Stations.xml
    /home/ubuntu/tdsconfig/radar/radarCollections.xml
    /home/ubuntu/tdsconfig/catalog.xml
    /home/ubuntu/tdsconfig/threddsConfig.xml
    /home/ubuntu/tdsconfig/wmsConfig.xml

# Setting up Data Volumes<a id="orgheadline30"></a>

As alluded to earlier, we will have to set up data volumes so that the LDM can
write data, and the TDS and RAMADDA can have access to that data. The `/mnt`
volume on Azure is a good place to store data. Check with Azure about the
assurances Azure makes about the reliability of storing your data there for the
long term. For the LDM this should not be too much of a problem, but for RAMADDA
you may wish to be careful.

## Check Free Disk Space<a id="orgheadline28"></a>

Let's first display the free disk space with the `df` command. 

    df -H

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-right" />

<col  class="org-left" />

<col  class="org-right" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">Filesystem</td>
<td class="org-left">Size</td>
<td class="org-right">Used</td>
<td class="org-left">Avail</td>
<td class="org-right">Use%</td>
<td class="org-left">Mounted</td>
<td class="org-left">on</td>
</tr>


<tr>
<td class="org-left">/dev/sda1</td>
<td class="org-left">31G</td>
<td class="org-right">2.0G</td>
<td class="org-left">28G</td>
<td class="org-right">7%</td>
<td class="org-left">/</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">none</td>
<td class="org-left">4.1k</td>
<td class="org-right">0</td>
<td class="org-left">4.1k</td>
<td class="org-right">0%</td>
<td class="org-left">/sys/fs/cgroup</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">udev</td>
<td class="org-left">7.4G</td>
<td class="org-right">8.2k</td>
<td class="org-left">7.4G</td>
<td class="org-right">1%</td>
<td class="org-left">/dev</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">tmpfs</td>
<td class="org-left">1.5G</td>
<td class="org-right">394k</td>
<td class="org-left">1.5G</td>
<td class="org-right">1%</td>
<td class="org-left">/run</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">none</td>
<td class="org-left">5.3M</td>
<td class="org-right">0</td>
<td class="org-left">5.3M</td>
<td class="org-right">0%</td>
<td class="org-left">/run/lock</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">none</td>
<td class="org-left">7.4G</td>
<td class="org-right">0</td>
<td class="org-left">7.4G</td>
<td class="org-right">0%</td>
<td class="org-left">/run/shm</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">none</td>
<td class="org-left">105M</td>
<td class="org-right">0</td>
<td class="org-left">105M</td>
<td class="org-right">0%</td>
<td class="org-left">/run/user</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">none</td>
<td class="org-left">66k</td>
<td class="org-right">0</td>
<td class="org-left">66k</td>
<td class="org-right">0%</td>
<td class="org-left">/etc/network/interfaces.dynamic.d</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">/dev/sdb1</td>
<td class="org-left">640G</td>
<td class="org-right">73M</td>
<td class="org-left">607G</td>
<td class="org-right">1%</td>
<td class="org-left">/mnt</td>
<td class="org-left">&#xa0;</td>
</tr>
</tbody>
</table>

## Create `/data` Directory<a id="orgheadline29"></a>

Create a `/data` directory where the LDM can write data soft link to the `/mnt` directory. Also, create a `/repository` directory where RAMADDA data will reside.

    sudo ln -s /mnt /data
    sudo mkdir /mnt/ldm/
    sudo chown -R ubuntu:docker /data/ldm
    sudo mkdir /mnt/repository/
    sudo chown -R ubuntu:docker /data/repository

These directories will be used by the LDM, TDS, and RAMADDA docker containers when we mount diretories from the Docker host into these containers.

# Opening Ports<a id="orgheadline31"></a>

Ensure these ports are open on the VM where these containers will run. Ask the cloud administrator for these ports to be open.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Service</th>
<th scope="col" class="org-right">External Port</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">HTTP</td>
<td class="org-right">80</td>
</tr>


<tr>
<td class="org-left">TDS</td>
<td class="org-right">8080</td>
</tr>


<tr>
<td class="org-left">RAMADDA</td>
<td class="org-right">8081</td>
</tr>


<tr>
<td class="org-left">SSL TDM</td>
<td class="org-right">8443</td>
</tr>


<tr>
<td class="org-left">LDM</td>
<td class="org-right">388</td>
</tr>
</tbody>
</table>

Note the TDM is an application that works in conjunction with the TDS. It creates indexes for GRIB data in the background, and notifies the TDS via port 8443 when data have been updated or changed. See [here](https://www.unidata.ucar.edu/software/thredds/current/tds/reference/collections/TDM.html) to learn more about the TDM.

# Tomcat Logging for TDS and RAMADDA<a id="orgheadline32"></a>

It is a good idea to mount Tomcat logging directories outside the container so that they can be managed for both the TDS and RAMADDA.

    mkdir -p ~/logs/ramadda-tomcat
    mkdir -p ~/logs/tds-tomcat

Note there is also a logging directory in `~/tdsconfig/logs`. All these logging directories should be looked at periodically, not the least to ensure that log files are not filling up your system.

# Starting the LDM TDS RAMADDA TDM<a id="orgheadline37"></a>

### RAMADDA Preconfiguration<a id="orgheadline33"></a>

When you start RAMADDA for the very first time, you must have  a `password.properties` file in the RAMADDA home directory which is `/data/repository/`. See [RAMADDA documentation](http://ramadda.org//repository/userguide/toc.html) for more details on setting up RAMADDA. Here is a `pw.properties` file to get you going. Change password below to something more secure!

    echo ramadda.install.password=changeme! > /data/repository/pw.properties

### Final Edit to `docker-compose.yml`<a id="orgheadline34"></a>

When the TDM communicates to the TDS concerning changes in data it observes with data supplied by the LDM, it will communicate via the `tdm` tomcat user. Edit the `docker-compose.yml` file and change the `TDM_PW` to `MeIndexer`. This is not as insecure as it would seem since the tdm user has few privileges. Optimally, one could change the password hash for the TDM user in the `tomcat-users.xml` file.

### Pull Down Images from the DockerHub Registry<a id="orgheadline35"></a>

At this point you are almost ready to run the whole kit and caboodle. But first  pull the relevant docker images to make this easier for the subsequent `docker-compose` command.

    docker pull unidata/ldmtds:latest
    docker pull unidata/tdm:latest
    docker pull unidata/tds:latest
    docker pull unidata/ramadda:latest

### Start the LDM, TDS, TDM, RAMADDA<a id="orgheadline36"></a>

We are now finally ready to start the LDM, TDS, TDM, RAMADDA with the following `docker-compose` command.

    docker-compose -f ~/git/Unidata-Dockerfiles/ams2016/docker-compose.yml up -d

# Check What is Running<a id="orgheadline43"></a>

At this point, you should have these services running:

-   LDM
-   TDS
-   TDM
-   RAMADDA

Next, we will check our work through various means.

## Docker Process Status<a id="orgheadline38"></a>

From the shell where you started `docker-machine` earlier you can execute the following `docker ps` command to list the containers on your docker host. It should look something like the output below.

    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}"

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-right" />

<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">CONTAINER</td>
<td class="org-left">ID</td>
<td class="org-left">IMAGE</td>
<td class="org-right">STATUS</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">4ed1c4c18814</td>
<td class="org-left">unidata/ramadda:latest</td>
<td class="org-left">Up</td>
<td class="org-right">17</td>
<td class="org-left">seconds</td>
</tr>


<tr>
<td class="org-left">bdfcf5590bc6</td>
<td class="org-left">unidata/ldmtds:latest</td>
<td class="org-left">Up</td>
<td class="org-right">18</td>
<td class="org-left">seconds</td>
</tr>


<tr>
<td class="org-left">aee044cf8e66</td>
<td class="org-left">unidata/tdm:latest</td>
<td class="org-left">Up</td>
<td class="org-right">20</td>
<td class="org-left">seconds</td>
</tr>


<tr>
<td class="org-left">4d0208f85b22</td>
<td class="org-left">unidata/tds:latest</td>
<td class="org-left">Up</td>
<td class="org-right">21</td>
<td class="org-left">seconds</td>
</tr>
</tbody>
</table>

## TDS and RAMADDA URLs<a id="orgheadline39"></a>

Verify what you have the TDS and RAMADDA running by navigating to: <http://unidata-server.cloudapp.net/thredds/catalog.html> and <http://unidata-server.cloudapp.net:8081/repository>. If you are going to RAMADDA for the first time, you will have to do some [RAMADDA set up](http://ramadda.org//repository/userguide/toc.html).

## Viewing Data with the IDV<a id="orgheadline42"></a>

Another way to verify your work is run the [Unidata Integrated Data Viewer](https://www.unidata.ucar.edu/software/idv/).

### Access TDS with the IDV<a id="orgheadline40"></a>

In the [IDV Dashboard](https://www.unidata.ucar.edu/software/idv/docs/userguide/data/choosers/CatalogChooser.html), you should be able to enter the catalog XML URL: <http://unidata-server.cloudapp.net/thredds/catalog.xml>.  

### Access RAMADDAA with the IDV<a id="orgheadline41"></a>

RAMADDA has good integration with the IDV and the two technologies work well together. You may wish to install the [RAMADDA IDV plugin](http://www.unidata.ucar.edu/software/idv/docs/workshop/savingstate/Ramadda.html) to publish IDV bundles to RAMADDA. RAMADDA also has access to the `/data/ldm` directory so you may want to set up [server-side view of this part of the file system](http://ramadda.org//repository/userguide/developer/filesystem.html). Finally,  you can enter this catalog URL in the IDV dashboard to examine data holdings shared bundles, etc. on RAMADDA <http://unidata-server.cloudapp.net:8081/repository?output=thredds.catalog>.
