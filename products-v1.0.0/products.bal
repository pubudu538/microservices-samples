import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerinax/istio;
import ballerinax/kubernetes;

type Product record {
    string name;
    int productId;
    string price;
};
Product product1 = {name: "Apples", productId: 101, price: "$1.49 / lb" };
Product product2 = {name: "Macaroni & Cheese", productId: 151, price: "$7.69" };
Product product3 = {name: "ABC Smart TV", productId: 301, price: "$399.99" };
Product product4 = {name: "Motor Oil", productId: 401, price: "$22.88" };
Product product5 = {name: "Floral Sleeveless Blouse", productId: 501, price: "$21.50" };
map<Product> productsList = { "101" : product1 , "151": product2, "301": product3, "401": product4, "501": product5 };


@istio:Gateway{
}
@istio:VirtualService{
}
@kubernetes:Service {
    name: "products"
}
@kubernetes:Deployment {
    livenessProbe: true,
    image: "pubudu/products:1.0.0",
    labels: { "version": "1.0.0" }
}
service products on new http:Listener(9090) {

	@http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function getProducts(http:Caller caller, http:Request req) {

        http:Response res = new;
        json[] jProdList = [];
        int counter = 0;

        foreach var (k, product) in productsList {
        
            json jProduct = {name: product.name, id: product.productId, price: product.price};
            jProdList[counter] = jProduct;
            counter = counter + 1;
        }

        json productsJson = { products: jProdList};
        io:println(productsJson);

        res.setJsonPayload(untaint productsJson);
        var result = caller->respond(res);

        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/{productId}"
    }
    resource function getProductsById(http:Caller caller, http:Request req, int productId) {

        http:Response res = new;
        string productIdValue = string.convert(productId);

        if (productsList.hasKey(productIdValue)) {
            Product? product = productsList[productIdValue];
            string reviewValue = getReviews(untaint productIdValue);
            boolean stockAvailability = getStockAvailability(untaint productIdValue);
            json jProduct = {name: product.name, id: product.productId, price: product.price, 
            reviewScore: reviewValue, stockAvailability: stockAvailability};
            res.setJsonPayload(untaint jProduct);
            io:println(jProduct);
        } else {
            res.statusCode = 404;
            res.setContentType("application/json");
            res.setJsonPayload({});
        }

        var result = caller->respond(res);

        if (result is error) {
            log:printError("Error sending response", err = result);
        }
      
    }
}

function getReviews(string productId) returns string {

    string endpoint = "http://review:8080";
    string path = "/review/" + productId;

    http:Client clientEP = new(endpoint);
    var response = clientEP->get(path);

    if (response is http:Response) {
        json|error msg = response.getJsonPayload();

        if (msg is json) {
            json prodReview = msg["Review"];
            string reviewScore = prodReview.reviewScore.toString();
            return reviewScore;
        }
    } 
    return "0";    
}

function getStockAvailability(string productId) returns boolean {

    string endpoint = "http://inventory:80";
    string path = "/inventory/" + productId;

    http:Client clientEP = new(endpoint);
    var response = clientEP->get(path);

    if (response is http:Response) {
        json|error msg = response.getJsonPayload();

        if (msg is json) {
            json prodReview = msg["data"];
            boolean result;
            result = boolean.convert(prodReview.toString());
            return result;
        }
    } 
    return false;    
}