const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
  response.send("Hello Ty, from Firebase!");
});

exports.newPlayer = functions.database.ref('/Players/{playerId}').onCreate((snapshot, context) => {
    const playerId = context.params.playerId
    console.log('Added Player: ' + playerId)
    
    const playerData = snapshot.val()
    const name = playerData.name
    const team = playerData.team
    console.log('Name: ' + name)
    console.log('Team: ' + team)
});
