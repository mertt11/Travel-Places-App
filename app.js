const admin = require('firebase-admin');
const serviceAccount = require('./travel-places-20b0f-firebase-adminsdk-edlae-fcf137c660.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://travel-places-20b0f.firebaseio.com',
});


  async function deleteUserByEmail(email) {
    try {
      const user = await admin.auth().getUserByEmail(email);
      await admin.auth().deleteUser(user.uid);
      console.log(`User with email ${email} deleted successfully.`);
    } catch (error) {
      console.error(`Error deleting user: ${error}`);
    }
  }

//deleteUserByEmail('e@outlook.com');