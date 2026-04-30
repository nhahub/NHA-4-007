const express = require('express');
const cors = require('cors');
const app = express();


require('dotenv').config();
require('./config/db_conn');
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));



app.use("/users", require("./routes/userRouter"))



app.listen(port, "0.0.0.0", () => {
    console.log(`Server running on port ${port}`);
});
