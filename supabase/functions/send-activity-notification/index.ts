// Intentionally dependency-free: only Deno Web APIs, fetch and Web Crypto.

type ActivityNotification = {
  id: string;
  recipient_id: string;
  title: string;
  body: string;
  route: string;
  payload: Record<string, unknown>;
};

type WebhookPayload = {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: ActivityNotification | null;
};

type FirebaseServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

type PushDevice = { id: string; token: string };

const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });

const base64Url = (value: string | Uint8Array) => {
  const bytes = typeof value === "string"
    ? new TextEncoder().encode(value)
    : value;
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary)
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");
};

const importPrivateKey = async (pem: string) => {
  const encoded = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll(/\s/g, "");
  const binary = atob(encoded);
  const bytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));
  return crypto.subtle.importKey(
    "pkcs8",
    bytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
};

const firebaseAccessToken = async (account: FirebaseServiceAccount) => {
  const now = Math.floor(Date.now() / 1000);
  const header = base64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = base64Url(JSON.stringify({
    iss: account.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const unsignedToken = `${header}.${claims}`;
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    await importPrivateKey(account.private_key),
    new TextEncoder().encode(unsignedToken),
  );
  const assertion = `${unsignedToken}.${base64Url(new Uint8Array(signature))}`;
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!response.ok) throw new Error("Unable to authorize Firebase messaging");
  const body = await response.json() as { access_token?: string };
  if (!body.access_token) throw new Error("Firebase access token is missing");
  return body.access_token;
};

const supabaseHeaders = (serviceRoleKey: string) => ({
  apikey: serviceRoleKey,
  authorization: `Bearer ${serviceRoleKey}`,
  "content-type": "application/json",
});

const loadDevices = async (
  supabaseUrl: string,
  serviceRoleKey: string,
  userId: string,
) => {
  const url = new URL(`${supabaseUrl}/rest/v1/push_devices`);
  url.searchParams.set("select", "id,token");
  url.searchParams.set("user_id", `eq.${userId}`);
  url.searchParams.set("enabled", "eq.true");
  const response = await fetch(url, {
    headers: supabaseHeaders(serviceRoleKey),
  });
  if (!response.ok) throw new Error("Unable to load notification devices");
  return await response.json() as PushDevice[];
};

const disableDevices = async (
  supabaseUrl: string,
  serviceRoleKey: string,
  ids: string[],
) => {
  if (!ids.length) return;
  const url = new URL(`${supabaseUrl}/rest/v1/push_devices`);
  url.searchParams.set("id", `in.(${ids.join(",")})`);
  const response = await fetch(url, {
    method: "PATCH",
    headers: {
      ...supabaseHeaders(serviceRoleKey),
      prefer: "return=minimal",
    },
    body: JSON.stringify({
      enabled: false,
      updated_at: new Date().toISOString(),
    }),
  });
  if (!response.ok) throw new Error("Unable to disable invalid devices");
};

Deno.serve(async (request) => {
  try {
    if (request.method !== "POST") {
      return jsonResponse({ error: "Method not allowed" }, 405);
    }

    const expectedSecret = Deno.env.get("ACTIVITY_WEBHOOK_SECRET");
    if (
      !expectedSecret ||
      request.headers.get("x-webhook-secret") !== expectedSecret
    ) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")?.replace(/\/$/, "");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const rawServiceAccount = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
    if (!supabaseUrl || !serviceRoleKey || !rawServiceAccount) {
      return jsonResponse({ error: "Missing server configuration" }, 500);
    }

    const webhook = await request.json() as WebhookPayload;
    const notification = webhook.record;
    if (
      webhook.type !== "INSERT" ||
      webhook.table !== "activity_notifications" ||
      !notification
    ) {
      return jsonResponse({ sent: 0, skipped: true });
    }

    const devices = await loadDevices(
      supabaseUrl,
      serviceRoleKey,
      notification.recipient_id,
    );
    if (!devices.length) return jsonResponse({ sent: 0 });

    const serviceAccount = JSON.parse(
      rawServiceAccount,
    ) as FirebaseServiceAccount;
    const accessToken = await firebaseAccessToken(serviceAccount);
    const endpoint =
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;
    let sent = 0;
    const disabledDeviceIds: string[] = [];

    for (const device of devices) {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          authorization: `Bearer ${accessToken}`,
          "content-type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token: device.token,
            notification: {
              title: notification.title,
              body: notification.body,
            },
            data: {
              notification_id: notification.id,
              route: notification.route,
              payload: JSON.stringify(notification.payload ?? {}),
            },
            android: { priority: "high" },
            apns: { payload: { aps: { sound: "default" } } },
          },
        }),
      });
      if (response.ok) {
        sent += 1;
        continue;
      }
      const errorBody = await response.text();
      if (
        response.status === 404 ||
        errorBody.includes("UNREGISTERED") ||
        errorBody.includes("INVALID_ARGUMENT")
      ) {
        disabledDeviceIds.push(device.id);
      }
    }

    await disableDevices(supabaseUrl, serviceRoleKey, disabledDeviceIds);
    return jsonResponse({ sent, disabled: disabledDeviceIds.length });
  } catch (error) {
    console.error(error instanceof Error ? error.message : "Unknown error");
    return jsonResponse({ error: "Notification delivery failed" }, 500);
  }
});
