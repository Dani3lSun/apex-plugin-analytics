# APEX Analytics

[![APEX Community](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/78c5adbe/badges/apex-community-badge.svg)](https://github.com/Dani3lSun/apex-github-badges) [![APEX Plugin](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/b7e95341/badges/apex-plugin-badge.svg)](https://github.com/Dani3lSun/apex-github-badges)
[![APEX Built with Love](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/7919f913/badges/apex-love-badge.svg)](https://github.com/Dani3lSun/apex-github-badges)

APEX Analytics is a complete bundle which helps you collecting many client side information from your different APEX applications in a central place. Purpose is to give you a deeper understanding of your audience and users and how your applications are used. The bundle contains the following components:

- **APEX Dynamic Action plugin** - Collects the client side information from all of your different applications
- **ORDS RESTful service** - Gets all the information collected by the DA plugin in a central place and saves it
- **APEX Analytics app** - Displays the information which are stored by the RESTful service (with dashboard, tables, custom analytic queries etc.)


- [APEX Analytics](#apex-analytics)
	- [How it works](#how-it-works)
	- [Preview](#preview)
	- [Install](#install)
		- [Database objects and APEX Analytics app](#database-objects-and-apex-analytics-app)
		- [ORDS RESTful service](#ords-restful-service)
		- [APEX Dynamic Action plugin](#apex-dynamic-action-plugin)
		- [Installation note](#installation-note)
	- [Application settings](#application-settings)
	- [Plugin settings](#plugin-settings)
		- [Application-wide settings](#application-wide-settings)
		- [Component settings](#component-settings)
		- [Plugin Events](#plugin-events)
		- [How to use](#how-to-use)
	- [Demo Application](#demo-application)
	- [Changelog](#changelog)
	- [License](#license)


## How it works
![](https://github.com/Dani3lSun/apex-plugin-analytics/blob/master/misc/apex_analytics_diagram.png)


## Preview

<p align="center">
  <img src="https://github.com/Dani3lSun/apex-plugin-analytics/blob/master/misc/screen1.png" width="400" />
  <img src="https://github.com/Dani3lSun/apex-plugin-analytics/blob/master/misc/screen2.png" width="400" />
</p>
<p align="center">
  <img src="https://github.com/Dani3lSun/apex-plugin-analytics/blob/master/misc/screen3.png" width="400" />
  <img src="https://github.com/Dani3lSun/apex-plugin-analytics/blob/master/misc/screen4.png" width="400" />
</p>
<p align="center">
  <img src="https://github.com/Dani3lSun/apex-plugin-analytics/blob/master/misc/screen5.png" width="400" />
  <img src="https://github.com/Dani3lSun/apex-plugin-analytics/blob/master/misc/screen6.png" width="400" />
</p>


## Install

### Database objects and APEX Analytics app

Connect to the target DB as APEX workspace schema and execute the main install script

```
cd path/to/unzipped/apex-plugin-analytics/app/db
sqlplus workspace_schema@database
@install.sql
```

After that go to APEX and import the application export file from *path/to/unzipped/apex-plugin-analytics/app/f280.sql*

*Note: APEX Analytics app requires at least a APEX 18.2 installation!*

### ORDS RESTful service

When your schema is already REST enabled then just import the RESTful export script from *path/to/unzipped/apex-plugin-analytics/app/ORDS_REST_APEX_ANALYTICS_ALL.sql*

Otherwise first REST enable your schema either by using APEX SQL Workshop > RESTful Services or Oracle SQL Developer or using the PL/SQL API *ORDS.enable_schema*

### APEX Dynamic Action plugin
- Import plugin file "dynamic_action_plugin_de_danielh_apexanalytics.sql" from **plugin/dist** directory into your application
- *Optional:* Deploy the JS/CSS files from **plugin/src/files** directory on your web server and change the "Plugin File Prefix" to web servers folder path.
- *Optional:* Compile the plugin PL/SQL package in your APEX parsing schema and change the plugin render/ajax function to include the package object name. The package files are located in **plugin/src/db** directory.

*Note: The DA plugin is shipped in 2 versions, one is compatible with APEX 5.1 and the other with APEX 18.2!*

### Installation note
If you plan to change the application id (APP_ID) of APEX Analytics app (default 280) please change 2 scripts to reflect your APP_ID changes. Change the current value 280 to your APP_ID:
- path/to/unzipped/apex-plugin-analytics/app/ORDS_REST_APEX_ANALYTICS_ALL.sql
- path/to/unzipped/apex-plugin-analytics/app/db/jobs/create_geolocation_scheduler_job.sql

*Please do this step before installing the DB objects or importing ORDS RESTful service*


## Application settings
After installation navigate to Administration > Application Settings (in APEX Analytics app), there you can change several settings:

- **Show Login Page Background Image** - This option enables or disables the background image shown on login page
- **Show colored JET Bar Charts** - This option enables or disables colored Oracle JET bar charts on dashboard page
- **Enable Anonymous IP Tracking** - This option enables tracking & logging of IP addresses. Additionally the geolocation feature is also enabled by this setting. IP addresses are stored in a privacy-friendly manner, so the last bytes of each address are masked, e.g. 192.168.2.100 > 192.168.2.xxx or 192.168.xxx.xxx
- **Bytes to remove & mask from IP address** - This option controls how privacy-friendly IP addresses are masked. Either 1 byte: 192.168.2.xxx or 2 bytes: 192.168.xxx.xxx. 1 byte is way more accurate when it comes to geolocating. 2 bytes are more privacy-friendly
- **ipstack Geolocation API - Base URL** - This site is using ipstack as service provider for geolocation. The masked IP address is transferred to them. They return the continent and country name of this IP address. This setting is the base URL of their API endpoint, if you choose one of the commercial plans, you can use https instead of plain http
- **ipstack Geolocation API - API Key** - This setting is for the API key which ipstack provides to you after sign up
- **ipstack Geolocation API - Wallet Path** - If you have an commercial ipstack plan and you are using a https base URL, then you have to create a Oracle wallet containing the sites certificates. Enter the file system path of the Oracle wallet
- **ipstack Geolocation API - Wallet Password** - Enter the password of your Oracle wallet

*Note: The geolocation feature runs asynchronously via a Oracle Scheduler Job (default: every 15 mins). The default @install.sql script installs this job, please read the installation note above before installing!*


## Plugin settings

### Application-wide settings
- **Analytics REST Web Service URL** - URL of the APEX Analytics server side REST endpoint (ORDS)

### Component settings
- **Additional Info Item** - Next to the standard information which the plugin collects and sends to the REST endpoint, you have the possibility to send additional information to the server side, which are saved there
- **Encode Web Service Call** - The plugin sends a JSON payload via a RESTful POST call. Please decide if this payload is sent with plain information or base64 encoded to hide certain information on first sight
- **Stop on max. Error Count** - If the REST endpoint is not reachable for some reason or there are other problems, an error counter is set in browsers session storage. If the counter value in session storage exceeds the max allowed counter value, collection & sending information to the server side stops
- **Respect DoNotTrack Setting** - Respect the users browser DoNotTrack setting and do not collect & send information to the REST endpoint

### Plugin Events
- **Web Service Call Success** - DA event that fires when all information are successfully sent to ORDS REST endpoint, *this.data holds the server response object*
- **Web Service Call Error** - DA event that fires when the REST call to ORDS endpoint was not successful, *this.data holds the error object*


### How to use
- New DA on an certain event, e.g *Page Load* or *Click*
- New Action: *APEX Analytics*
- Choose best fitting settings

*Best would be to include the plugin just once on the global page on page load with a high sequence, so this DA fires pretty late (best for measure page load time)*


## Demo Application
https://apex.oracle.com/pls/apex/f?p=ANALYTICS_DEMO


## Changelog

#### 1.0.6 - Performance improvements dashboard page / Extended max row count on Analytics Data IG / Include new app favicons

#### 1.0.5 - Added option (application setting) to enable colored bar charts on dashboard / Allow percentage values also for world map region

#### 1.0.4 - Added optional background image to login page (can be configured in app settings) / Created a native APEX plugin for amCharts world map region / Some dashboard enhancements

#### 1.0.3 - Added world map region to dashboard page

#### 1.0.2 - Changed dashboard chart refresh to a debouncing mechanism (much less round trips to DB and better performance)

#### 1.0.1 - Added JET zoom feature to some dashboard charts / enhanced ipstack geolocation job to make less REST calls

#### 1.0.0 - Initial Release


## License
MIT
