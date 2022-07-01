var xsenv = require('@sap/xsenv');
var request = require('request');

class DestinationService {
    destinationService;
    xsuaaService;
    accessToken;
    destDetails;
    constructor(destination, xsuaa) {
        xsenv.loadEnv();
        this.destinationService = xsenv.cfServiceCredentials(destination);
        this.xsuaaService = xsenv.cfServiceCredentials(xsuaa);
    }
    async GetDestination(destinationName) {
        const promise = new Promise(async (resolve, reject) => {
            try {
                this.destDetails = await this.getDestinationDetails(destinationName)
                resolve(this.destDetails);
            }
            catch (error) {
                reject(error);
            }
        });
        return promise;
    };

    async GetCertificates(certName) {
        const promise = new Promise(async (resolve, reject) => {
            try {
                resolve(await this.getCertificateDetails(certName));
            }
            catch (error) {
                reject(error);
            }
        });
        return promise;
    };

    async GetAllDestination() {
        const promise = new Promise(async (resolve, reject) => {
            try {
                resolve(await this.getDestinationDetails(undefined, true));
            }
            catch (error) {
                reject(error);
            }
        });
        return promise;
    };
    async TestConnection(url) {
        const promise = new Promise(async (resolve, reject) => {
            try {
                resolve(await this.ping(url));
            }
            catch (error) {
                reject(error);
            }
        });
        return promise;
    }

    async getToken() {
        const promise = new Promise(async (resolve, reject) => {
            if (!this.accessToken) {
                const newUrl = this.destinationService.url;
                var options = {
                    // url: this.destinationService.url + '/oauth/token?client_id=' + this.destinationService.clientid + '&client_secret=' + this.destinationService.clientsecret + '&grant_type=client_credentials'
                    url: newUrl + '/oauth/token?client_id=' + this.destinationService.clientid + '&grant_type=client_credentials'
                };
                let tokenAsJson = Object;
                const that = this;
                await request.get(options, async function (error, response, body) {
                    if (error || !response || response.statusCode !== 200) {
                        reject(response ? `Token request failed with status code ${response.statusCode} ${error ? 'due to ' + error : ""}` : `Token request failed ${error ? 'due to ' + error : ""}`);
                    }
                    try {
                        tokenAsJson = JSON.parse(body);
                        that.accessToken = tokenAsJson["access_token"];
                        resolve(that.accessToken);
                    }
                    catch (e) {
                        reject(error);
                    }
                }).auth(this.destinationService.clientid, this.destinationService.clientsecret, false);
            }
            else {
                resolve(this.accessToken);
            }
        });
        return promise;
    };

    async getDestinationDetails(destinationName, getAllDestination) {

        const promise = new Promise(async (resolve, reject) => {
            if (getAllDestination !== true && (!destinationName || destinationName === "")) {
                reject("Please Provide Valid Destination");
            }
            const accessToken = await this.getToken();
            if (!accessToken) {
                reject("Invalid Bearer Token");
            }
            console.log(this.destinationService);
            const url = this.destinationService.uri + '/destination-configuration/v1/subaccountDestinations';
            const options = {
                url: getAllDestination === true ? url : url + '/' + destinationName,
                headers: {
                    'Authorization': 'Bearer ' + accessToken
                }
            };

            request.get(options, async function (error, response, body) {
                if (error || !response || response.statusCode !== 200) {
                    reject(response ? `Destination request failed with status code ${response.statusCode} ${error ? 'due to ' + error : ""}` : `Destination request failed ${error ? 'due to ' + error : ""}`);
                    return promise;
                }
                try {
                    resolve(JSON.parse(body));
                }
                catch (e) {
                    reject(error);
                }
            });

        });

        return promise;
    };

    async getCertificateDetails(certName) {
        const promise = new Promise(async (resolve, reject) => {
            const accessToken = await this.getToken();
            if (!accessToken) {
                reject("Invalid Bearer Token");
            }
            const options = {
                url: this.destinationService.uri + '/destination-configuration/v1/subaccountCertificates' + `/${certName}`,
                headers: {
                    'Authorization': 'Bearer ' + accessToken
                }
            };
            request.get(options, async function (error, response, body) {
                if (error || !response || response.statusCode !== 200) {
                    reject(response ? `Certificate request failed with status code ${response.statusCode} ${error ? 'due to ' + error : ""}` : `Certificate request failed ${error ? 'due to ' + error : ""}`);
                }
                try {
                    resolve(JSON.parse(body));
                }
                catch (e) {
                    reject(error);
                }
            });
        });
        return promise;
    };

    async ping(url) {
        const promise = new Promise(async (resolve, reject) => {
            const specialRequest = request.defaults({
                strictSSL: false
            });
            const options = {
                url: url,
            };
            specialRequest.get(options, async function (error, response, body) {
                if (error || !response || response.statusCode === 400) {
                    reject(`request failed`);
                }
                try {
                    resolve(true);
                }
                catch (e) {
                    reject(error);
                }
            });
        });
        return promise;
    }

    prepareServiceUrl(url, subdomain) {
        let newUrl = url;
        if (subdomain) {
            const pos1 = url.indexOf("://");
            const pos2 = url.indexOf(".");
            if (pos1 > 0 && pos2 > 0) {
                newUrl = url.substring(0, pos1 + 3) + subdomain + url.substr(pos2);
            }

        }
        return newUrl;
    }
};

module.exports = { DestinationService };