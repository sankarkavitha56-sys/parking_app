require("dotenv").config();

const mongoose = require("mongoose");
const User = require("./models/User");

// Fix the variable name here
mongoose.connect(process.env.MONGODB_URI)
    .then(() => {
        console.log("Connected to MongoDB...");
        createAdmin(); // Run the function only after a successful connection
    })
    .catch(err => {
        console.error("Database connection error:", err);
    });

async function createAdmin() {
    try {
        const exists = await User.findOne({ username: "admin" });

        if (exists) {
            console.log("Admin already exists");
            process.exit(0);
        }

        const admin = new User({
            username: "admin",
            password: "Admin@123",
            role: "admin"
        });

        await admin.save();

        console.log("Admin created successfully");
        process.exit(0);
    } catch (error) {
        console.error("Error creating admin:", error);
        process.exit(1);
    }
}