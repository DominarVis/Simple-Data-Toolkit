var databases = { };

(function () {
    // https://docs.snowflake.com/en/developer-guide/sql-api/submitting-requests.html#using-bind-variables-in-a-statement
    // https://docs.snowflake.com/en/developer-guide/sql-api/authenticating.html
    // snowsql -a <account_identifier> -u <user> --private-key-path <path>/rsa_key.p8


    var keys = { };
    var callbacks = { };
    var checkHandler = null;
    var checkTimeout = 1000;

    var snowflake = {
        init: function () {
            sessionStorage.clear();
        },
        getKey: async function (key) {
            var pemKey;
            if (key.trim().indexOf("-----BEGIN") == 0) {
                pemKey = key;
            }
            if (!pemKey && !keys[key]) {
                var newKey = await crypto.subtle.generateKey(
                    {
                        name: 'RSASSA-PKCS1-v1_5',
                        modulusLength: 4096,
                        publicExponent: new Uint8Array([1, 0, 1]),
                        hash: 'SHA-256',
                    },
                    true,
                    ['sign', 'verify']
                );

                function arrayBufferToBase64(arrayBuffer) {
                    var byteArray = new Uint8Array(arrayBuffer);
                    var byteString = "";
                    byteArray.forEach((byte) => {
                        byteString += String.fromCharCode(byte);
                    });
                    return btoa(byteString);
                }

                function breakPemIntoMultipleLines(pem) {
                    var charsPerLine = 64;
                    let pemContents = "";
                    while (pem.length > 0) {
                        pemContents += `${pem.substring(0, charsPerLine)}\n`;
                        pem = pem.substring(64);
                    }
                    return pemContents;
                }

                function toPem(key, type) {
                    var pemContents = breakPemIntoMultipleLines(arrayBufferToBase64(key));
                    return "-----BEGIN " + type.toUpperCase() + " KEY-----\n" + pemContents + "-----END " + type.toUpperCase() + " KEY-----";
                }

                pemKey = toPem(await crypto.subtle.exportKey('pkcs8', newKey.privateKey), "private")
                + "\n\n"
                + toPem(await crypto.subtle.exportKey('spki', newKey.publicKey), "public");
                keys[key] = pemKey;
                
                return newKey;
            } else {
                if (!pemKey) {
                    pemKey = keys[key];
                }
                pemKey = pemKey.trim().split("-----");
                function remWhite(s) {
                    s = s.replaceAll("\n", "");
                    return s;
                }
                function base64ToArrayBuffer(b64) {
                    var byteString = window.atob(b64);
                    var byteArray = new Uint8Array(byteString.length);
                    for(var i=0; i < byteString.length; i++) {
                        byteArray[i] = byteString.charCodeAt(i);
                    }

                    return byteArray;
                }

                var privateI = -1;
                var publicI = -1;

                privateI = pemKey[1].toUpperCase().indexOf("PRIVATE") >= 0 ? 2 : 6;
                publicI = pemKey[1].toUpperCase().indexOf("PUBLIC") >= 0 ? 2 : 6;

                pemKey = [base64ToArrayBuffer(remWhite(pemKey[privateI])), base64ToArrayBuffer(remWhite(pemKey[publicI]))];
                var importedKey = {
                    privateKey: await crypto.subtle.importKey("pkcs8", pemKey[0], { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, true, ["sign"]),
                    publicKey: await crypto.subtle.importKey("spki", pemKey[1], { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, true, ["verify"])
                };
                return importedKey;
            }
        },
        jwtEncode: async function (payload, key) {
            const header = {
                alg: 'RS256',
                typ: 'JWT',
            };

            function base64ToUint8Array(base64Contents) {
                base64Contents = base64Contents.replace(/-/g, '+').replace(/_/g, '/').replace(/\s/g, '');
                const content = atob(base64Contents);
                return new Uint8Array(content.split('').map((c) => c.charCodeAt(0)));
            }

            function stringToUint8Array(contents) {
                const encoded = btoa(unescape(encodeURIComponent(contents)));
                return base64ToUint8Array(encoded);
            }

            function uint8ArrayToString(unsignedArray) {
                const base64string = btoa(String.fromCharCode(...unsignedArray));
                return base64string.replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
            }

            const stringifiedHeader = JSON.stringify(header);
            const stringifiedPayload = JSON.stringify(payload);

            const headerBase64 = uint8ArrayToString(stringToUint8Array(stringifiedHeader));
            const payloadBase64 = uint8ArrayToString(stringToUint8Array(stringifiedPayload));
            const headerAndPayload = `${headerBase64}.${payloadBase64}`;

            const messageAsUint8Array = stringToUint8Array(headerAndPayload);

            const signature = await crypto.subtle.sign(
                {
                name: 'RSASSA-PKCS1-v1_5',
                hash: 'SHA-256',
                },
                key.privateKey,
                messageAsUint8Array
            );

            const base64Signature = uint8ArrayToString(new Uint8Array(signature));
            return `${headerAndPayload}.${base64Signature}`;
        },
        login: async function (account, user, key) {
            var key = await this.getKey(key);

            // Get the raw bytes of the public key.
            public_key_raw = await crypto.subtle.exportKey('spki', key.publicKey);

            // Get the sha256 hash of the raw bytes.
            function arrayBufferToBase64(arrayBuffer) {
                var byteArray = new Uint8Array(arrayBuffer);
                var byteString = "";
                byteArray.forEach((byte) => {
                    byteString += String.fromCharCode(byte);
                });
                return btoa(byteString);
            }
            const sha256hash = await crypto.subtle.digest('SHA-256', public_key_raw);

            // Base64-encode the value and prepend the prefix 'SHA256:'.
            const public_key_fp = 'SHA256:' + arrayBufferToBase64(sha256hash);

            // Get the account identifier without the region, cloud provider, or subdomain.
            if (account.indexOf(".global") < 0) {
                var idx = account.indexOf('.')
                if (idx > 0) {
                    account = account.substr(0, idx);
                } else {
                    // Handle the replication case.
                    idx = account.indexOf('-');
                    if (idx > 0) {
                        account = account.substr(0,idx);
                    }
                }
            }

            // Use uppercase for the account identifier and user name.
            account = account.toUpperCase();
            user = user.toUpperCase();
            var qualified_username = account + "." + user;


            var iat = Math.floor(Date.now() / 1000) - 360;
            // Specify the length of time during which the JWT will be valid. You can specify at most 1 hour.
            var lifetime = iat + (60 * 60);

            // Create the payload for the token.
            var payload = {

                // Set the issuer to the fully qualified username concatenated with the public key fingerprint (calculated in the  previous step).
                "iss": qualified_username + '.' + public_key_fp,

                // Set the subject to the fully qualified username.
                "sub": qualified_username,

                // Set the expiration time, based on the lifetime specified for this object.
                "exp": lifetime,

                "iat": iat,
            }

            // Generate the JWT. private_key is the private key that you read from the private key file in the previous step when you generated the public key fingerprint.
            token = await this.jwtEncode(payload, key);

            return token;
        },
        send: function (url, method, body, headers, callback) {
            var a = true;
            let xhr = new XMLHttpRequest();
            xhr.open(method, url, a);
            if (!!headers) {
                for (var header in headers) {
                    xhr.setRequestHeader(header, headers[header]);
                }
            }
            if (a == true) {
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === 4) {
                        callback(xhr.status, xhr.responseText);
                    }
                };
            }

            try {
                xhr.send(JSON.stringify(body));
            } catch (ex) { }

            if (a == false) {
                callback(xhr.responseText);
            }

            return xhr;
        },
        getBindingType: function (v) {
            // TODO - Check all of these
            try {
                if (v == parseInt(v)) {
                    return "FIXED";
                }
            } catch (ex) { }
            try {
                if (v == parseFloat(v)) {
                    return "REAL";
                }
            } catch (ex) { }
            try {
                if (v == true || v == false) {
                    return "BOOLEAN";
                }
            } catch (ex) { }
            // TODO - Add DATE/Date
            // TODO - Add TIME/TIMESTAMP
            // TODO - Add BINARY/Blob
            return "TEXT";
        },
        getBindings: function (bindings) {
            var obj = { };
            if (!!bindings) {
                for (var i in bindings) {
                    try {
                        i = parseInt(i);
                        obj["" + i] = {
                            "type": self.getBindingType(bindings[i]),
                            "value": bindings[i],
                        };
                    } catch (ex) { }
                }
            }
            return obj;
        },
        execute: function (jwt, account, statement, timeout, database, schema, warehouse, role, bindings, callback) {
            this.send("https://" + account + ".snowflakecomputing.com/api/v2/statements?async=true", "POST", 
            {
                "statement": statement,
                "timeout": timeout,
                "database": database,
                "schema": schema,
                "warehouse": warehouse,
                "role": role,
                "bindings": this.getBindings(bindings), 
            },
            {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + jwt,
                "Accept": "application/json",
                "X-Snowflake-Authorization-Token-Type": "KEYPAIR_JWT",
            }, function (status, result) {
                snowflake.processResult(JSON.parse(result), callback, account, jwt, null, null);
            });
        },
        checkStatements: function () {
            checkHandler = null;
            for (var statementHandle in callbacks) {
                var obj = callbacks[statementHandle];
                if (obj.partition == null || obj.partition <= 0) {
                    snowflake.send("https://" + obj.account + ".snowflakecomputing.com" + obj.url, "GET", null, {
                        "Content-Type": "application/json",
                        "Authorization": "Bearer " + obj.jwt,
                        "Accept": "application/json",
                        "X-Snowflake-Authorization-Token-Type": "KEYPAIR_JWT",
                    }, function (status, result) {
                        snowflake.processResult(JSON.parse(result), obj.callback, obj.account, obj.jwt, statementHandle, null);
                    });
                } else {
                    if (obj.pending != true) {
                        obj.pending = true;
                        obj.requests = [];
                        for (var partition = obj.partition; partition < obj.partitions; partition++) {
                            (function (partition) {
                                obj.requests.push(snowflake.send("https://" + obj.account + ".snowflakecomputing.com" + obj.url + "?partition=" + partition, "GET", null, {
                                    "Content-Type": "application/json",
                                    "Authorization": "Bearer " + obj.jwt,
                                    "Accept": "application/json",
                                    "X-Snowflake-Authorization-Token-Type": "KEYPAIR_JWT",
                                }, function (status, result) {
                                    snowflake.processResult(JSON.parse(result), obj.callback, obj.account, obj.jwt, statementHandle, partition);
                                }));
                            })(partition);
                        }
                    }
                }
            }
        },
        removeResult: function (obj) {
            if (!!obj) {
                delete callbacks[obj.statementHandle];
                if (!!(obj.requests)) {
                    for (var r in obj.requests) {
                        r = obj.requests[r];
                        try {
                            r.abort();
                        } catch (ex) { }
                    }
                    obj.requests = null;
                }
                if (typeof obj.data[0] === 'string' || obj.data[0] instanceof String) {
                    for (var partition in obj.data) {
                        window.sessionStorage.removeItem(obj.data[partition]);
                    }
                }
            }
        },
        getResult: function (data, i) {
            if (typeof data[i] === 'string' || data[i] instanceof String) {
                return JSON.parse(window.sessionStorage.getItem(data[i]));
            } else {
                return data[i];
            }
        },
        startIteration: function (obj, i) {
            obj.currentPartitionI = 0;
            obj.currentPartitionData = this.getResult(obj.data, obj.currentPartitionI);
            obj.currentRow = 0;
            obj.currentPartitionStart = 0;
        },
        nextRow: function (obj) {
			if (obj.currentPartitionStart === null) {
				snowflake.startIteration(obj, 0);
			}            
            var i = obj.currentRow - obj.currentPartitionStart;
            if (i >= obj.currentPartitionData.length) {
                obj.currentPartitionStart += obj.currentPartitionData.length;
                obj.currentPartitionI++;
                obj.currentPartitionData = this.getResult(obj.data, obj.currentPartitionI);
                i = 0;
            }
            obj.currentRow++;
            return obj.currentPartitionData[i];
        },
        processResult: function (result, callback, account, jwt, statementHandle, partition) {
            if (result.code == null) {
                result.code = "090001";
                result.statementHandle = statementHandle;
            }
            switch (parseInt(result.code)) {
                case 090001:
                    var statementHandle = result.statementHandle.trim();
                    var obj = callbacks[statementHandle];
                    var partitions = 0;
                    if (partition == null) {
                        partition = 0;
                    }
                    try {
                        partitions = result.resultSetMetaData.partitionInfo.length;
                    } catch (ex) {
                        partitions = obj.partitions;
                    }
                    var data = obj.data;
                    var fileId = statementHandle + "-" + partition;
                    var inMem = true;
                    try {
                        if (!!(window.sessionStorage)) {
                            window.sessionStorage.setItem(fileId, JSON.stringify(result.data));
                            data[partition] = fileId;
                            inMem = false;
                        }
                    } catch (ex) {
                        ex.toString();
                    }
                    if (inMem) {
                        data[partition] = result.data;
                    }
                    if (obj.columns == null) {
                        obj.columns = result.resultSetMetaData.rowType;
                    }
                    obj.rows += result.data.length;
                    if (partitions == null || partitions <= 1 || obj.partition >= partitions) {
                        delete callbacks[statementHandle];
                        callback(obj);
                        // column: {byteLength, collation, database, length, name, nullable, precision, scale, schema, table, type}
                    } else {
                        obj.partition++;
                        obj.partitions = partitions;
                        if (checkHandler == null) {
                            checkHandler = setTimeout(this.checkStatements, checkTimeout);
                        }
                    }
                    break;
                case 333334:
                    callbacks[result.statementHandle.trim()] = {partition: 0, partitions: 1, data: [], columns: null, statementHandle: result.statementHandle.trim(), account: account, jwt: jwt, url: result.statementStatusUrl, callback: callback, currentPartitionData: null, currentPartitionStart: null, currentPartitionI: null, currentRow: null, rows: 0};
                    if (checkHandler == null) {
                        checkHandler = setTimeout(this.checkStatements, checkTimeout);
                    }
                    break;
                default:
                    snowflake.removeResult(callbacks[statementHandle]);
                    callback({error: result.message, result: {partition: 0, partitions: 0, data: null, columns: null, statementHandle: null, account: account, jwt: jwt, url: null, callback: callback, currentPartitionData: null, currentPartitionStart: null, currentPartitionI: null, currentRow: null, rows: 0}});
                    break;
            }
        },
    };
    databases.snowflake = snowflake;
})();