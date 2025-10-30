const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const db = process.env.MONGO_URI || 'mongodb://mongodb:27017/devconnector';
    await mongoose.connect(db, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });

    console.log('MongoDB Connected...');
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
};

module.exports = connectDB;
