"use strict";
const nodemailer = require("nodemailer");
const fetch = require("node-fetch");


// async..await is not allowed in global scope, must use a wrapper
async function main() {
  const data = await fetch(
    "https://simpleanalytics.com/api/export/datapoints?version=5&format=json&hostname=de.serlo.org" +
      "&start=today&end=today&robots=false&timezone=Europe%2FBerlin&fields=datapoint&type=events",
    {
      headers: {
        "Api-Key": process.env.API_KEY,
      },
    }
  );

  const json = await data.json();
  const numberofThanks = json.datapoints.filter(
    (x) => x.datapoint == "thank_you_article"
  ).length;

  console.log("Anzahl Danke", numberofThanks);

  const mailBase = {
    from: '"Serlo" <quinn@serlo.org>', // sender address
    subject: "Danke!",
    text: "Heute haben " + numberofThanks + " Serlo-Nutzer*innen Danke gesagt!",
    html: `
    
        <img style="display:block;margin-left:auto;margin-right:auto;" src="cid:serlo@serlo.org" />
  
        <p style="margin-top: 24px; margin-bottom:8px; text-align:center; font-size: 16px;">
          Heute haben
        </p>
  
        
        <p style="margin-top: 8px; margin-bottom: 8px; text-align:center; font-size:32px;">
          <strong>${numberofThanks}</strong>
        </p>
  
        
        <p style="margin-top: 8px; text-align:center; font-size:16px;">
          Serlo-Nutzer*innen Danke gesagt!
        </p>
  
        <img style="display:block;margin-top:20px;margin-left:auto;margin-right:auto" src="cid:smiley@serlo.org" />
  
        <small style="display: block;margin-top:100px; margin-bottom: 12px; color: gray; font-size:12px;text-align:center">
          Schreibe an <a href="mailto:quinn@serlo.org">quinn@serlo.org</a> oder antworte auf diese E-Mail, um Feedback zu geben bzw. den Verteiler zu verlassen.
        </small>
    
    `,
    attachments: [
      {
        filename: "serlo_logo.png",
        path: __dirname + "/Serlo_Logo.svg.png",
        cid: "serlo@serlo.org", //same cid value as in the html img src
        contentDisposition: "inline",
      },
      {
        filename: "smiley.png",
        path: __dirname + "/smiley.png",
        cid: "smiley@serlo.org", //same cid value as in the html img src
        contentDisposition: "inline",
      },
    ],
  };

  // create reusable transporter object using the default SMTP transport
  let transporter = nodemailer.createTransport($SMTP_URI);

  let info = await transporter.sendMail({
    ...mailBase,
    to: $EMAIL_DISTRIBUTOR
  });

  console.log("Message sent: %s", info.messageId);
  // Message sent: <b658f8ca-6296-ccf4-8306-87d57a0b4321@example.com>
}

main().catch(console.error);
