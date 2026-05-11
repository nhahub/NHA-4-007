const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose'); // Add mongoose to access connection state
const Product = require('./models/productModel'); // Import your Product Model
const productsData = require('./products.json'); // Import your JSON file

const app = express();

require('dotenv').config();
require('./config/db_conn');
const port = process.env.PORT || 9000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- SEEDING LOGIC START ---
const seedDB = async () => {
    try {
        const count = await Product.countDocuments();
        if (count === 0) {
            console.log("Database is empty. Seeding products...");

            // --- FIX START ---
            // Flatten $oid and $date if they exist in your JSON
            const cleanedData = productsData.map(item => {
                const newItem = { ...item };

                // If _id is an object with $oid, convert it to a string
                if (newItem._id && newItem._id.$oid) {
                    newItem._id = newItem._id.$oid;
                }

                return newItem;
            });
            // --- FIX END ---

            await Product.insertMany(cleanedData); // Use cleanedData instead
            console.log("Successfully seeded database!");
        } else {
            console.log("Database already has data. Skipping seed.");
        }
    } catch (err) {
        console.error("Error seeding database:", err);
    }
};

// Only run the seed once the Mongoose connection is ready
mongoose.connection.once('open', () => {
    seedDB();
});
// --- SEEDING LOGIC END ---

app.use("/products", require("./routes/productRouter"));
app.use("/filter", require("./routes/filterRouter"));

app.listen(port, "0.0.0.0", () => {
    console.log(`Server running on port ${port}`);
});