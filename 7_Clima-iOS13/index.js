// const admin = require("firebase-admin");
// const fs = require("fs");

// const serviceAccount = require("./pushnotificationsample-a93f6-firebase-adminsdk-fbsvc-ea98d5700b.json");

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

// const messaging = admin.messaging();

// // バッジ数を保存するファイル
// const badgeFile = "badge.json";

// // ファイルからバッジ数を読み込む関数
// function loadBadgeCount() {
//   try {
//     if (fs.existsSync(badgeFile)) {
//       const data = fs.readFileSync(badgeFile, "utf8");
//       return JSON.parse(data).badge || 0;
//     }
//   } catch (error) {
//     console.error("バッジ数の読み込みエラー:", error);
//   }
//   return 0;
// }

// // バッジ数を保存する関数
// function saveBadgeCount(count) {
//   try {
//     fs.writeFileSync(badgeFile, JSON.stringify({ badge: count }));
//   } catch (error) {
//     console.error("バッジ数の保存エラー:", error);
//   }
// }

// // 現在のバッジ数を読み込む
// let currentBadge = loadBadgeCount();

// function sendPushNotification() {

//   // バッジ数を1増加
//   currentBadge++;

//   const message = {
//     token: "cF-cIYJ6I0Voj6w7tjoXWj:APA91bHYLDa8bmqV1hlkc94kCixu6HtoqjYTa8C0h-GrpcgY_bNyZBaGzec6RIuQozS-T2faJRMMpJsMQQwhYXLUSSXwuWBuOWrU0xrlpeepFSw0shAQCuQ",
//     notification: {
//       title: "新しいメッセージ",
//       body: "バックグラウンドでデータ取得が可能です"
//     },
//     apns: {
//       payload: {
//         aps: {
//           "content-available": 1,
//           "badge": currentBadge,  // バッジ数を送信
//           "sound": "default"
//         }
//       }
//     }
//   };

//   console.log(`送信時のバッジ数: ${currentBadge}`);  // バッジ数は常に更新

//   return message;  // messageを返す
// }

// // メッセージを送信する
// const message = sendPushNotification();

// messaging.send(message)
//   .then(response => {
//     console.log(`通知送信成功: バッジ数 ${currentBadge}`);
//     saveBadgeCount(currentBadge); // バッジ数を保存
//   })
//   .catch(error => {
//     console.error("通知送信エラー:", error);
//   });

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
const admin = require("firebase-admin");

const serviceAccount = require("./pushnotificationsample-a93f6-firebase-adminsdk-fbsvc-ea98d5700b.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const messaging = admin.messaging();
const badgeDocRef = db.collection("settings").doc("badgeCount");

// Firestore からバッジ数を取得
async function loadBadgeCount() {
  const doc = await badgeDocRef.get();
  return doc.exists ? doc.data().badge : 0;
}

// Firestore にバッジ数を保存
async function saveBadgeCount(count) {
  await badgeDocRef.set({ badge: count });
}

// 現在のバッジ数を取得
let currentBadge = 0;

async function loadBadgeCount() {
  const doc = await badgeDocRef.get();
  if (!doc.exists) {
    console.log("🔴 badgeCount ドキュメントが存在しません。新しく作成します。");
    await saveBadgeCount(0);  // 初回作成時にバッジ数を 0 にする
    return 0;
  }
  return doc.data().badge;
}

async function sendPushNotification() {
  currentBadge = await loadBadgeCount();
  currentBadge++;

  const message = {
    token: "cF-cIYJ6I0Voj6w7tjoXWj:APA91bHYLDa8bmqV1hlkc94kCixu6HtoqjYTa8C0h-GrpcgY_bNyZBaGzec6RIuQozS-T2faJRMMpJsMQQwhYXLUSSXwuWBuOWrU0xrlpeepFSw0shAQCuQ",
    notification: {
      title: "新しいメッセージ",
      body: "バックグラウンドでデータ取得が可能です"
    },
    apns: {
      payload: {
        aps: {
          "content-available": 1,
          "badge": currentBadge,
          "sound": "default"
        }
      }
    }
  };

  console.log(`送信時のバッジ数: ${currentBadge}`);

  try {
    await messaging.send(message);
    console.log(`通知送信成功: バッジ数 ${currentBadge}`);
    await saveBadgeCount(currentBadge);
  } catch (error) {
    console.error("通知送信エラー:", error);
  }
}

// バッジ数をリセットする API エンドポイント
const express = require("express");
const app = express();
app.use(express.json());

app.post("/sendNotification", async (req, res) => {
  try {
    await sendPushNotification();
    res.status(200).send("プッシュ通知送信成功");
  } catch (error) {
    console.error("通知送信エラー:", error);
    res.status(500).send("通知送信エラー");
  }
});

app.post("/resetBadge", async (req, res) => {
  try {
    await saveBadgeCount(0);
    console.log("バッジ数リセット成功");
    res.status(200).send("バッジ数リセット成功");
  } catch (error) {
    console.error("バッジ数リセットエラー:", error);
    res.status(500).send("バッジ数リセットエラー");
  }
});

app.listen(3000, () => {
  console.log("🚀 サーバー起動: http://localhost:3000");
});

 // メッセージを送信する
const message = sendPushNotification();
