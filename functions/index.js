const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Function to send notification to all users
exports.sendNotificationToAll = functions.https.onCall(async (data, context) => {
  // Check if the user is authenticated and has admin privileges
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  const { title, body, type = 'general', data: notificationData = {} } = data;

  if (!title || !body) {
    throw new functions.https.HttpsError('invalid-argument', 'Title and body are required.');
  }

  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: type,
        timestamp: new Date().toISOString(),
        ...notificationData
      },
      topic: 'general_announcements'
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);

    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending message:', error);
    throw new functions.https.HttpsError('internal', 'Error sending notification.');
  }
});

// Function to send notification to specific topic
exports.sendNotificationToTopic = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  const { title, body, topic, type = 'general', data: notificationData = {} } = data;

  if (!title || !body || !topic) {
    throw new functions.https.HttpsError('invalid-argument', 'Title, body, and topic are required.');
  }

  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: type,
        timestamp: new Date().toISOString(),
        ...notificationData
      },
      topic: topic
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message to topic:', topic, response);

    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending message to topic:', error);
    throw new functions.https.HttpsError('internal', 'Error sending notification.');
  }
});

// Function to send notification to specific user
exports.sendNotificationToUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  const { title, body, userId, type = 'general', data: notificationData = {} } = data;

  if (!title || !body || !userId) {
    throw new functions.https.HttpsError('invalid-argument', 'Title, body, and userId are required.');
  }

  try {
    // Get user's FCM token from Firestore
    const userTokenDoc = await admin.firestore().collection('user_tokens').doc(userId).get();
    
    if (!userTokenDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User token not found.');
    }

    const token = userTokenDoc.data().token;

    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: type,
        timestamp: new Date().toISOString(),
        ...notificationData
      },
      token: token
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message to user:', userId, response);

    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending message to user:', error);
    throw new functions.https.HttpsError('internal', 'Error sending notification.');
  }
});

// Function to send route update notifications
exports.sendRouteUpdate = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  const { routeName, updateMessage, affectedRoutes = [] } = data;

  if (!routeName || !updateMessage) {
    throw new functions.https.HttpsError('invalid-argument', 'Route name and update message are required.');
  }

  try {
    const message = {
      notification: {
        title: `Route Update: ${routeName}`,
        body: updateMessage,
      },
      data: {
        type: 'route_update',
        routeName: routeName,
        affectedRoutes: JSON.stringify(affectedRoutes),
        timestamp: new Date().toISOString(),
      },
      topic: 'route_updates'
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent route update:', response);

    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending route update:', error);
    throw new functions.https.HttpsError('internal', 'Error sending route update.');
  }
});

// Function to send schedule change notifications
exports.sendScheduleChange = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  const { title, scheduleDetails, effectiveDate } = data;

  if (!title || !scheduleDetails) {
    throw new functions.https.HttpsError('invalid-argument', 'Title and schedule details are required.');
  }

  try {
    const message = {
      notification: {
        title: title,
        body: scheduleDetails,
      },
      data: {
        type: 'schedule_change',
        scheduleDetails: scheduleDetails,
        effectiveDate: effectiveDate || new Date().toISOString(),
        timestamp: new Date().toISOString(),
      },
      topic: 'schedule_changes'
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent schedule change:', response);

    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending schedule change:', error);
    throw new functions.https.HttpsError('internal', 'Error sending schedule change.');
  }
});

// Function to automatically clean up old user tokens
exports.cleanupOldTokens = functions.pubsub.schedule('every 7 days').onRun(async (context) => {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - 30); // Remove tokens older than 30 days

  try {
    const tokensRef = admin.firestore().collection('user_tokens');
    const oldTokens = await tokensRef.where('updatedAt', '<', cutoffDate).get();

    const batch = admin.firestore().batch();
    oldTokens.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Cleaned up ${oldTokens.size} old tokens`);
  } catch (error) {
    console.error('Error cleaning up old tokens:', error);
  }
});
