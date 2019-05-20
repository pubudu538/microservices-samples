import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerinax/kubernetes;

type Review record {
    int id;
    int score;
};
Review review1 = {id: 101, score: 7 };
Review review2 = {id: 151, score: 8 };
Review review3 = {id: 301, score: 6 };
Review review4 = {id: 401, score: 8 };
Review review5 = {id: 501, score: 9 };
map<Review> reviewList = { "101" : review1 , "151": review2, "301": review3, "401": review4, "501": review5 };

@kubernetes:Service {
    name: "review"
}
@kubernetes:Deployment {
    livenessProbe: true,
    image: "pubudu/review:1.0.0"
}
service review on new http:Listener(8080) {

	@http:ResourceConfig {
        methods: ["GET"],
        path: "/{productId}"
    }
    resource function getReview(http:Caller caller, http:Request req, int productId) {

        http:Response res = new;
        string productIdValue = string.convert(productId);

        if (reviewList.hasKey(productIdValue)) {

            Review? reviewOutput = reviewList[productIdValue];
            json reviewResult = { Review: { productId: productId, reviewScore: reviewOutput.score} } ;    
            
            io:println(reviewResult);
            res.setJsonPayload(untaint reviewResult);
         
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

