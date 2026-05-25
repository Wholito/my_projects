const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions } = require('firebase-functions/v2');
const admin = require('firebase-admin');

admin.initializeApp();

setGlobalOptions({ region: 'europe-central2' });

async function sendToUser(uid, notification, data = {}) {
  const userDoc = await admin.firestore().collection('users').doc(uid).get();
  const token = userDoc.data()?.fcmToken;
  if (!token) return;

  await admin.messaging().send({
    token,
    notification,
    data: Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)]),
    ),
    android: {
      priority: 'high',
      notification: {
        channelId: 'shadow_find_default',
        icon: 'ic_notification',
        defaultSound: true,
        visibility: 'public',
      },
    },
  });
}

exports.onFriendRequestCreated = onDocumentCreated(
  'users/{uid}/friend_requests/{fromUid}',
  async (event) => {
    const toUid = event.params.uid;
    const data = event.data?.data();
    if (!data) return;

    await sendToUser(
      toUid,
      {
        title: 'Приглашение в друзья',
        body: `${data.fromName || 'Игрок'} хочет добавить тебя в друзья`,
      },
      {
        type: 'friend_request',
        fromUid: data.fromUid || event.params.fromUid,
      },
    );
  },
);

exports.onFeedItemCreated = onDocumentCreated(
  'users/{uid}/feed/{roundId}',
  async (event) => {
    const toUid = event.params.uid;
    const roundId = event.params.roundId;

    const roundDoc = await admin.firestore().collection('rounds').doc(roundId).get();
    if (!roundDoc.exists) return;

    const round = roundDoc.data();
    if (round.authorUid === toUid) return;

    await sendToUser(
      toUid,
      {
        title: 'Новое фото',
        body: `${round.authorName || 'Друг'} отправил(а) тебе фото для угадывания`,
      },
      { type: 'new_photo', roundId, fromUid: round.authorUid },
    );
  },
);
