/*global angular*/

/*
 * An HTTP Plugin for PhoneGap.
 */

var exec = require('cordova/exec');

var http = {
    useBasicAuth: function(username, password, success, failure) {
        return exec(success, failure, "CordovaHttpPlugin", "useBasicAuth", [username, password]);
    },
    setHeader: function(header, value, success, failure) {
        return exec(success, failure, "CordovaHttpPlugin", "setHeader", [header, value]);
    },
    enableSSLPinning: function(enable, success, failure) {
        return exec(success, failure, "CordovaHttpPlugin", "enableSSLPinning", [enable]);
    },
    acceptAllCerts: function(allow, success, failure) {
        return exec(success, failure, "CordovaHttpPlugin", "acceptAllCerts", [allow]);
    },
    post: function(url, params, headers, success, failure) {
        return exec(success, failure, "CordovaHttpPlugin", "post", [url, params, headers]);
    },
    get: function(url, params, headers, success, failure) {
        // If second arg is a function we assume get is called
        // without any params or headers. This simplifies
        // calling get in the basic case.
        if (typeof params == "function") {
            success = params;
            failure = headers;
            params = {};
            headers = {};
        }
        return exec(success, failure, "CordovaHttpPlugin", "get", [url, params, headers]);
    },
    uploadFile: function(url, params, headers, filePath, name, success, failure) {
        throw "Function uploadFile is not supported by Evothings Viewer";
    },

    downloadFile: function(url, params, headers, filePath, success, failure) {
        throw "Function downloadFile is not supported by Evothings Viewer";
    }
};

module.exports = http;

if (typeof angular !== "undefined") {
    angular.module('cordovaHTTP', []).factory('cordovaHTTP', function($timeout, $q) {
        function makePromise(fn, args, async) {
            var deferred = $q.defer();

            var success = function(response) {
                if (async) {
                    $timeout(function() {
                        deferred.resolve(response);
                    });
                } else {
                    deferred.resolve(response);
                }
            };

            var fail = function(response) {
                if (async) {
                    $timeout(function() {
                        deferred.reject(response);
                    });
                } else {
                    deferred.reject(response);
                }
            };

            args.push(success);
            args.push(fail);

            fn.apply(http, args);

            return deferred.promise;
        }

        var cordovaHTTP = {
            useBasicAuth: function(username, password) {
                return makePromise(http.useBasicAuth, [username, password]);
            },
            setHeader: function(header, value) {
                return makePromise(http.setHeader, [header, value]);
            },
            enableSSLPinning: function(enable) {
                return makePromise(http.enableSSLPinning, [enable]);
            },
            acceptAllCerts: function(allow) {
                return makePromise(http.acceptAllCerts, [allow]);
            },
            post: function(url, params, headers) {
                return makePromise(http.post, [url, params, headers], true);
            },
            get: function(url, params, headers) {
                return makePromise(http.get, [url, params, headers], true);
            },
            uploadFile: function(url, params, headers, filePath, name) {
                return makePromise(http.uploadFile, [url, params, headers, filePath, name], true);
            },
            downloadFile: function(url, params, headers, filePath) {
                return makePromise(http.downloadFile, [url, params, headers, filePath], true);
            }
        };
        return cordovaHTTP;
    });
} else {
    window.cordovaHTTP = http;
}
