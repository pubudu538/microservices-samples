/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const express = require("express");

const service = express();
const port = process.env.SERVICE_PORT || 3002;

service.use(express.json());

/**
 * Handle a success response from the API invocation.
 *
 * @param res The express response object
 * @param data The returned data from the API invocation
 */
const handleSuccess = (res, data) => {
    const response = {
        status: "SUCCESS"
    };
    if (data) {
        response.data = data;
    }
    res.send(response);
};

/**
 * Handle an error which occurred during the API invocation.
 *
 * @param res The express response object
 * @param message The error message
 */
const handleError = (res, message) => {
    console.log("[ERROR] " + message);
    res.status(500).send({
        status: "ERROR",
        message: message
    });
};

/*
 * Get inventory information
 */
service.get("/inventory/:productId", (req, res) => {
   

        var productMap = new Map();
        productMap.set("101", "true");
        productMap.set("151", "false");
        productMap.set("301", "true");
        productMap.set("401", "false");
        productMap.set("501", "true");

        var productId = req.params.productId;
        if (productMap.get(productId)) {
            handleSuccess(res, productMap.get(productId));
        } else {
            handleError(res, "Product item not found");   
        }
         
});

/*
 * Starting the server
 */
const server = service.listen(port, () => {
    const host = server.address().address;
    const port = server.address().port;

    console.log("[INFO] Pet Store Customers Service listening at http://%s:%s", host, port);
});
