import * as request from 'request'


//Authentication Re
const consumer_key: string = "A1ioxcl5sTd1EiSFcyDEiEGv9cfmrkXo"
const consumer_secret: string = "yoDHG0QOzkzp2rBw"
const url: string = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
const auth: string = "Basic " + new Buffer(consumer_key + ":" + consumer_secret).toString("base64")

request(
    {
      url : url,
      headers : {
        "Authorization" : auth
      }
    },
    function (error, response, body) {
      // TODO: Use the body object to extract OAuth access token
      console.log(response.body)
    }
)
