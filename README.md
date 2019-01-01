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
	- [Plugin settings](#plugin-settings)
		- [Application settings](#application-settings)
		- [Component settings](#component-settings)
		- [Plugin Events](#plugin-events)
		- [How to use](#how-to-use)
	- [Demo Application](#demo-application)
	- [Changelog](#changelog)
	- [License](#license)


##How it works
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

### ORDS RESTful service

When your schema is already REST enabled then just import the RESTful export script from *path/to/unzipped/apex-plugin-analytics/app/ORDS_REST_APEX_ANALYTICS_ALL.sql*

Otherwise first REST enable your schema either by using APEX SQL Workshop > RESTful Services or Oracle SQL Developer or using the PL/SQL API *ORDS.enable_schema*

### APEX Dynamic Action plugin
- Import plugin file "dynamic_action_plugin_de_danielh_apexanalytics.sql" from **plugin/dist** directory into your application
- *Optional:* Deploy the JS/CSS files from **plugin/src/files** directory on your web server and change the "Plugin File Prefix" to web servers folder path.
- *Optional:* Compile the plugin PL/SQL package in your APEX parsing schema and change the plugin render/ajax function to include the package object name. The package files are located in **plugin/src/db** directory.


## Plugin settings

### Application settings
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

#### 1.0.0 - Initial Release


## License
MIT
