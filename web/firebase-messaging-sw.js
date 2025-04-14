// Import the Firebase app and messaging scripts (adjust version if needed)
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js"); // Use compat version for service worker
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js"); // Use compat version for service worker

// --- IMPORTANT: Initialize Firebase ---
// You need your Firebase config here. These values MUST match those
// used when you initialized Firebase in your main app (found in firebase_options.dart).
// DO NOT hardcode sensitive keys directly if possible, but for localhost testing
// this is often the simplest way to start.
const firebaseConfig = {
    apiKey: "AIzaSyBQXAJgV5jBx_bGVeFQMYj9IWJRAcBLZVI", // Get from firebase_options.dart or Firebase Console
    authDomain: "tackle4loss-888b5.firebaseapp.com",
    projectId: "tackle4loss-888b5",
    storageBucket: "tackle4loss-888b5.firebasestorage.app",
    messagingSenderId: "429372303044",
    appId: "1:429372303044:web:bdd68bb053c580125f0b91",
    measurementId: "G-VT26J7TC05", // Optional
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Retrieve an instance of Firebase Messaging so that it can handle background messages.
const messaging = firebase.messaging();

// Optional: Handle background messages here if needed (e.g., show custom notification)
// If you only want FCM to display the notification automatically when app is backgrounded,
// you might not need much code here beyond initialization.
messaging.onBackgroundMessage((payload) => {
    console.log(
        '[firebase-messaging-sw.js] Received background message ',
        payload,
    );
    // Customize notification here
    // IMPORTANT: If you handle the message here, FCM might not display
    // its automatic notification. You'd need to use the browser's
    // self.registration.showNotification() API.
    // For simplicity now, let FCM handle the display.

    // Example: Customize notification display
    // const notificationTitle = payload.notification?.title || 'Background Message';
    // const notificationOptions = {
    //   body: payload.notification?.body || 'You have a new message.',
    //   icon: '/favicon.png' // Optional: Path to an icon in your web folder
    //   // Add other options like 'data' to handle clicks
    // };
    //
    // self.registration.showNotification(notificationTitle, notificationOptions);
});

console.log('[firebase-messaging-sw.js] Service worker initialized.');