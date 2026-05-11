// 

const asyncHandler = require("express-async-handler");
const jwt = require("jsonwebtoken");
require("dotenv").config();

// const validateToken = asyncHandler(async (req, res, next) => {
//     let token;
//     let authHeader = req.headers.Authorization || req.headers.authorization;
//     console.log("Headers received:", req.headers);

//     if (authHeader && authHeader.startsWith("Bearer")) {
//         token = authHeader.split(" ")[1];

//         // Use the synchronous version of verify to keep it simple within the async handler
//         try {
//             const decoded = jwt.verify(token, process.env.ACCESS_TOKEN);

//             // Attach the user data to the request object for use in your controllers
//             req.user = decoded.user;
//             next();
//         } catch (err) {
//             console.error("JWT Verification Error:", err.message);
//             res.status(401);
//             throw new Error("User is not authorized");
//         }
//     } else {
//         res.status(401);
//         throw new Error("User is not authorized or token is missing");
//     }
// });

const validateToken = asyncHandler(async (req, res, next) => {
    let token;
    // Check all possible casing for the authorization header
    let authHeader = req.headers.authorization || req.headers.Authorization || req.header('Authorization');

    console.log("Extracted Auth Header:", authHeader); // Debugging log

    if (authHeader && authHeader.toLowerCase().startsWith("bearer")) {
        token = authHeader.split(" ")[1];

        try {
            const decoded = jwt.verify(token, process.env.ACCESS_TOKEN);
            req.user = decoded.user;
            console.log("Token Verified for User:", req.user.email);
            next();
        } catch (err) {
            console.error("JWT Verification Error:", err.message);
            res.status(401);
            throw new Error("User is not authorized, token expired or invalid");
        }
    } else {
        console.log("No Bearer token found in headers");
        res.status(401);
        throw new Error("User is not authorized or token is missing");
    }
});

module.exports = validateToken;