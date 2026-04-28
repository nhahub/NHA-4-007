// const mongoose = require('mongoose');
// const redis = require('redis');
// require('dotenv').config();

// const redisClient = redis.createClient();

// // Promisify Redis functions for async/await usage
// // const getAsync = promisify(redisClient.get).bind(redisClient);
// // const setAsync = promisify(redisClient.set).bind(redisClient);

// const mongo_username = process.env.MONGO_USERNAME;
// const mongo_password = process.env.MONGO_PASSWORD;
// const mongo_cluster = process.env.MONGO_CLUSTER;
// const mongo_database = process.env.MONGO_DBNAME;


// mongoose.connect(`mongodb+srv://${mongo_username}:${mongo_password}@${mongo_cluster}/${mongo_database}?retryWrites=true&w=majority`
// , { useNewUrlParser: true, useUnifiedTopology: true })
// .then(() => console.log(`Connected to: ${mongoose.connection.name}`))
// .catch(err => console.log(err));



// // async function getDataFromDatabase(id) {
// //     // Check if the data is already cached
// //     const cachedData = await getAsync(id);
// //     if (cachedData) {
// //       console.log('Fetching data from cache');
// //       return JSON.parse(cachedData);
// //     }

// //     // If not cached, fetch data from the database
// //     console.log('Fetching data from the database');
// //     const data = await MyModel.findById(id).exec();

// //     // Cache the fetched data
// //     await setAsync(id, JSON.stringify(data));

// //     return data;
// //   }



// //   async function main() {
// //     const data1 = await getDataFromDatabase();
// //     console.log(data1);

// //     // Fetch the same data again to demonstrate caching
// //     const data2 = await getDataFromDatabase();
// //     console.log(data2);
// //   }

// //   main().catch(console.error);


// // mongoose.connect(`mongodb://localhost:27017`
// // , { useNewUrlParser: true, useUnifiedTopology: true })
// // .then(() => console.log(`Connected to: DB`))
// // .catch(err => console.log(err));


// module.exports = mongoose;

// const mongoose = require('mongoose');
// const redis = require('redis');
// require('dotenv').config();

// const redisClient = redis.createClient();

// // Promisify Redis functions for async/await usage
// // const getAsync = promisify(redisClient.get).bind(redisClient);
// // const setAsync = promisify(redisClient.set).bind(redisClient);

// const mongo_username = process.env.MONGO_USERNAME;
// const mongo_password = process.env.MONGO_PASSWORD;
// const mongo_cluster = process.env.MONGO_CLUSTER;
// const mongo_database = process.env.MONGO_DBNAME;


// mongoose.connect(`mongodb+srv://${mongo_username}:${mongo_password}@${mongo_cluster}/${mongo_database}?retryWrites=true&w=majority`
// , { useNewUrlParser: true, useUnifiedTopology: true })
// .then(() => console.log(`Connected to: ${mongoose.connection.name}`))
// .catch(err => console.log(err));



// // async function getDataFromDatabase(id) {
// //     // Check if the data is already cached
// //     const cachedData = await getAsync(id);
// //     if (cachedData) {
// //       console.log('Fetching data from cache');
// //       return JSON.parse(cachedData);
// //     }

// //     // If not cached, fetch data from the database
// //     console.log('Fetching data from the database');
// //     const data = await MyModel.findById(id).exec();

// //     // Cache the fetched data
// //     await setAsync(id, JSON.stringify(data));

// //     return data;
// //   }



// //   async function main() {
// //     const data1 = await getDataFromDatabase();
// //     console.log(data1);

// //     // Fetch the same data again to demonstrate caching
// //     const data2 = await getDataFromDatabase();
// //     console.log(data2);
// //   }

// //   main().catch(console.error);


// // mongoose.connect(`mongodb://localhost:27017`
// // , { useNewUrlParser: true, useUnifiedTopology: true })
// // .then(() => console.log(`Connected to: DB`))
// // .catch(err => console.log(err));


// module.exports = mongoose;

// const mongoose = require('mongoose');
// const redis = require('redis');
// require('dotenv').config();

// const redisClient = redis.createClient();

// // Promisify Redis functions for async/await usage
// // const getAsync = promisify(redisClient.get).bind(redisClient);
// // const setAsync = promisify(redisClient.set).bind(redisClient);

// const mongo_username = process.env.MONGO_USERNAME;
// const mongo_password = process.env.MONGO_PASSWORD;
// const mongo_cluster = process.env.MONGO_CLUSTER;
// const mongo_database = process.env.MONGO_DBNAME;


// mongoose.connect(`mongodb+srv://${mongo_username}:${mongo_password}@${mongo_cluster}/${mongo_database}?retryWrites=true&w=majority`
// , { useNewUrlParser: true, useUnifiedTopology: true })
// .then(() => console.log(`Connected to: ${mongoose.connection.name}`))
// .catch(err => console.log(err));



// // async function getDataFromDatabase(id) {
// //     // Check if the data is already cached
// //     const cachedData = await getAsync(id);
// //     if (cachedData) {
// //       console.log('Fetching data from cache');
// //       return JSON.parse(cachedData);
// //     }

// //     // If not cached, fetch data from the database
// //     console.log('Fetching data from the database');
// //     const data = await MyModel.findById(id).exec();

// //     // Cache the fetched data
// //     await setAsync(id, JSON.stringify(data));

// //     return data;
// //   }



// //   async function main() {
// //     const data1 = await getDataFromDatabase();
// //     console.log(data1);

// //     // Fetch the same data again to demonstrate caching
// //     const data2 = await getDataFromDatabase();
// //     console.log(data2);
// //   }

// //   main().catch(console.error);


// // mongoose.connect(`mongodb://localhost:27017`
// // , { useNewUrlParser: true, useUnifiedTopology: true })
// // .then(() => console.log(`Connected to: DB`))
// // .catch(err => console.log(err));


// module.exports = mongoose;

const mongoose = require('mongoose');
const redis = require('redis');
require('dotenv').config();

// Standard DevOps approach: Use a single URI variable.
// If MONGO_URI is missing in .env, it defaults to your local Docker MongoDB.
const connectionString = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/user_db';

mongoose.connect(connectionString, {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log(`Connected to MongoDB at: ${connectionString.split('@').pop()}`)) // Logs location without showing password
    .catch(err => {
        console.error('Database connection error:', err.message);
    });

// Redis setup (Keep this for when you run a Redis container later)
const redisClient = redis.createClient({
    url: process.env.REDIS_URL || 'redis://127.0.0.1:6379'
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));

// Note: In newer redis versions, you need to call .connect()
// redisClient.connect().catch(console.error);

module.exports = mongoose;