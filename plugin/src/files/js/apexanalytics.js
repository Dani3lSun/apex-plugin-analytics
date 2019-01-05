/**
 * APEX Analytics
 * Author: Daniel Hochleitner
 * Version: 1.0.4
 */

/**
 * Extend apex.da
 */
apex.da.apexAnalytics = {
  /**
   * Plugin handler - called from plugin render function
   * @param {object} pOptions
   */
  pluginHandler: function(pOptions) {
    /**
     * Main Namespace
     */
    var apexAnalytics = {
      /**
       * Call APEX Analytics REST web service
       * @param {string} pAnalyticsRestUrl
       * @param {object} pData
       * @param {function} callback
       */
      callAnalyticsWebservice: function(pAnalyticsRestUrl, pData, callback) {
        try {
          $.ajax({
            url: pAnalyticsRestUrl,
            type: 'POST',
            data: JSON.stringify(pData),
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            success: function(data) {
              if (data.success) {
                apex.event.trigger('body', 'apexanalytics-ajax-success', data);
                apex.debug.log('apexAnalytics.callAnalyticsWebservice AJAX Success', data);
                callback({
                  "success": true
                });
              } else {
                apex.event.trigger('body', 'apexanalytics-ajax-error', {
                  "message": data.message
                });
                apex.debug.log('apexAnalytics.callAnalyticsWebservice AJAX Error', data.message);
                callback({
                  "success": false
                });
              }
            },
            error: function(jqXHR, textStatus, errorThrown) {
              apex.event.trigger('body', 'apexanalytics-ajax-error', {
                "message": errorThrown
              });
              apex.debug.log('apexAnalytics.callAnalyticsWebservice AJAX Error', errorThrown);
              callback({
                "success": false
              });
            }
          });
        } catch (err) {
          apex.event.trigger('body', 'apexanalytics-ajax-error', {
            "message": err
          });
          apex.debug.log('apexAnalytics.callAnalyticsWebservice AJAX Error', err);
          callback({
            "success": false
          });
        }
      },
      /**
       * Save analytics error count in browsers session storage (apexAnalytics.<app_id>.<app_session>.errorCount)
       * @param {number} pErrorCount
       */
      setAnalyticsErrorSessionStorage: function(pErrorCount) {
        if (apex.storage.hasSessionStorageSupport()) {
          var apexSession = $v('pInstance');
          var sessionStorage = apex.storage.getScopedSessionStorage({
            prefix: 'apexAnalytics',
            useAppId: true
          });

          sessionStorage.setItem(apexSession + '.errorCount', pErrorCount);
        }
      },
      /**
       * Get analytics error count from browsers session storage (apexAnalytics.<app_id>.<app_session>.errorCount)
       * @return {string}
       */
      getAnalyticsErrorSessionStorage: function() {
        var storageValue;

        if (apex.storage.hasSessionStorageSupport()) {
          var apexSession = $v('pInstance');
          var sessionStorage = apex.storage.getScopedSessionStorage({
            prefix: 'apexAnalytics',
            useAppId: true
          });

          storageValue = sessionStorage.getItem(apexSession + '.errorCount');
        }
        return storageValue || '0';
      },
      /**
       * Raise error count is session storage + 1
       */
      setErrorCountUp: function() {
        var errorCount = parseInt(apexAnalytics.getAnalyticsErrorSessionStorage()) + 1;
        apexAnalytics.setAnalyticsErrorSessionStorage(errorCount);
      },
      /**
       * Check if error count in session storage exceed max allowed error count
       * @param {number} pMaxErrorCount
       * @return {boolean}
       */
      checkErrorCount: function(pMaxErrorCount) {
        var errorCount = parseInt(apexAnalytics.getAnalyticsErrorSessionStorage()) + 1;
        var boolVal = false;
        if (errorCount <= pMaxErrorCount) {
          boolVal = true;
        } else {
          boolVal = false;
        }
        return boolVal;
      },
      /**
       * Check if browser has touch support
       * @return {string}
       */
      hasTouchSupport: function() {
        var returnVal = 'N';
        var hasTouchSupport = (('ontouchstart' in window) || (navigator.msMaxTouchPoints > 0));
        if (hasTouchSupport) {
          returnVal = 'Y';
        } else {
          returnVal = 'N';
        }
        return returnVal;
      },
      /**
       * Get screen width of window / browser
       * @return {number}
       */
      getScreenWidth: function() {
        var screenWidth = window.screen.width;
        return screenWidth || 0;
      },
      /**
       * Get screen height of window / browser
       * @return {number}
       */
      getScreenHeight: function() {
        var screenheight = window.screen.height;
        return screenheight || 0;
      },
      /**
       * Get main language of browser
       * @return {string}
       */
      getBrowserLanguage: function() {
        var browserLanguage = navigator.languages ? navigator.languages[0] : (navigator.language || navigator.userLanguage);
        return browserLanguage;
      },
      /**
       * Get page load time in seconds for document ready event
       * @param {string} pEvent
       * @return {number}
       */
      getPageLoadTime: function(pEvent) {
        var pageLoadTime;
        if (pEvent == 'ready') {
          var now = new Date().getTime();
          pageLoadTime = (now - performance.timing.navigationStart) / 1000;
        } else {
          pageLoadTime = 0;
        }
        return pageLoadTime || 0;
      },
      /**
       * Check if DoNotTrack browser setting is active
       * @return {boolean}
       */
      isDoNotTrackActive: function() {
        var isActive = false;
        // check if browser support DNT
        if (window.doNotTrack || navigator.doNotTrack || navigator.msDoNotTrack || 'msTrackingProtectionEnabled' in window.external) {
          // is active
          if (window.doNotTrack == "1" || navigator.doNotTrack == "yes" || navigator.doNotTrack == "1" || navigator.msDoNotTrack == "1" || window.external.msTrackingProtectionEnabled()) {
            isActive = true;
            // is not active
          } else {
            isActive = false;
          }
          // does not support DNT
        } else {
          isActive = false;
        }
        return isActive;
      },
      /**
       * Check if DoNotTrack browser setting is active + activated in plugin settings
       * @param {string} pRespectDoNotTrack
       * @return {boolean}
       */
      isDoNotTrackCompleteActive: function(pRespectDoNotTrack) {
        var isActive = false;
        if (pRespectDoNotTrack == 'Y') {
          if (apexAnalytics.isDoNotTrackActive()) {
            isActive = true;
          } else {
            isActive = false;
          }
        } else {
          isActive = false;
        }
        return isActive;
      },
      /**
       * Build JSON for Analytics REST Call
       * @param {string} pAnaliticsId
       * @param {string} pEventName
       * @param {string} pAdditionalInfoItem
       * @param {string} pEncodeWebserviceCall
       * @return {object}
       */
      buildAnalyticsJson: function(pAnaliticsId, pEventName, pAdditionalInfoItem, pEncodeWebserviceCall) {
        // get client info
        var parser = new UAParser();
        var parserResult = parser.getResult();
        // build JSON
        var analyticsJson = {};
        var encodedString = '';
        var stringDivider = ':::';
        // only if user agent parsing has some values
        if (parserResult.browser.name && parserResult.browser.version && parserResult.os.name && parserResult.os.version) {
          // not encoded
          if (pEncodeWebserviceCall == 'N') {
            analyticsJson = {
              "encodeWebserviceCall": pEncodeWebserviceCall,
              "analyticsId": pAnaliticsId,
              "agentName": parserResult.browser.name,
              "agentVersion": parserResult.browser.version,
              "agentLanguage": apexAnalytics.getBrowserLanguage(),
              "osName": parserResult.os.name,
              "osVersion": parserResult.os.version,
              "hasTouchSupport": apexAnalytics.hasTouchSupport(),
              "pageLoadTime": apexAnalytics.getPageLoadTime(pEventName),
              "screenWidth": apexAnalytics.getScreenWidth(),
              "screenHeight": apexAnalytics.getScreenHeight(),
              "apexAppId": $v('pFlowId'),
              "apexPageId": $v('pFlowStepId'),
              "eventName": pEventName,
              "additionalInfo": $v(pAdditionalInfoItem)
            };
            // base64 encoded
          } else {
            encodedString = pAnaliticsId + stringDivider;
            encodedString += parserResult.browser.name + stringDivider;
            encodedString += parserResult.browser.version + stringDivider;
            encodedString += apexAnalytics.getBrowserLanguage() + stringDivider;
            encodedString += parserResult.os.name + stringDivider;
            encodedString += parserResult.os.version + stringDivider;
            encodedString += apexAnalytics.hasTouchSupport() + stringDivider;
            encodedString += apexAnalytics.getPageLoadTime(pEventName) + stringDivider;
            encodedString += apexAnalytics.getScreenWidth() + stringDivider;
            encodedString += apexAnalytics.getScreenHeight() + stringDivider;
            encodedString += $v('pFlowId') + stringDivider;
            encodedString += $v('pFlowStepId') + stringDivider;
            encodedString += pEventName + stringDivider;
            encodedString += $v(pAdditionalInfoItem);
            analyticsJson = {
              "encodeWebserviceCall": pEncodeWebserviceCall,
              "encodedString": btoa(encodedString)
            };
          }
        }
        return analyticsJson;
      },
      /**
       * Real Plugin handler - called from outer pluginHandler function
       * @param {object} pOptions
       */
      pluginHandler: function(pOptions) {
        // plugin attributes
        var analyticsId = pOptions.analyticsId;
        var eventName = pOptions.eventName;

        var analyticsRestUrl = pOptions.analyticsRestUrl;

        var additionalInfoItem = pOptions.additionalInfoItem;
        var encodeWebserviceCall = pOptions.encodeWebserviceCall;
        var stopOnMaxError = pOptions.stopOnMaxError;
        var respectDoNotTrack = pOptions.respectDoNotTrack;

        // debug
        apex.debug.log('apexAnalytics.pluginHandler - analyticsId', analyticsId);
        apex.debug.log('apexAnalytics.pluginHandler - eventName', eventName);

        apex.debug.log('apexAnalytics.pluginHandler - analyticsRestUrl', analyticsRestUrl);

        apex.debug.log('apexAnalytics.pluginHandler - additionalInfoItem', additionalInfoItem);
        apex.debug.log('apexAnalytics.pluginHandler - encodeWebserviceCall', encodeWebserviceCall);
        apex.debug.log('apexAnalytics.pluginHandler - stopOnMaxError', stopOnMaxError);
        apex.debug.log('apexAnalytics.pluginHandler - respectDoNotTrack', respectDoNotTrack);

        // check if DoNotTrack is not active
        if (!(apexAnalytics.isDoNotTrackCompleteActive(respectDoNotTrack))) {
          // call analytics web service (only if max error count is not exceeded)
          if (apexAnalytics.checkErrorCount(stopOnMaxError)) {
            var analyticsData = apexAnalytics.buildAnalyticsJson(analyticsId, eventName, additionalInfoItem, encodeWebserviceCall);
            // only process if analytics JSON has been built
            if (analyticsData) {
              apexAnalytics.callAnalyticsWebservice(analyticsRestUrl, analyticsData, function(data) {
                // set error counter in session storage if call is not successful
                if (!(data.success)) {
                  apexAnalytics.setErrorCountUp();
                }
              });
              // if no analytics JSON can be built --> also set error counter is session storage
            } else {
              apexAnalytics.setErrorCountUp();
            }
          }
        }
      }
    }; // end namespace apexAnalytics

    // call real pluginHandler function
    try {
      apexAnalytics.pluginHandler(pOptions);
    } catch (err) {
      apex.debug.log('apexAnalytics.pluginHandler error', err);
      apexAnalytics.setErrorCountUp();
    }
  }
};
