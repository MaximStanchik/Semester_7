const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { onCall, HttpsError } = require('firebase-functions/v2/https');

admin.initializeApp();

function _requireString(map, key) {
  const v = map[key];
  if (typeof v !== 'string' || v.trim().length === 0) {
    throw new HttpsError('invalid-argument', `Missing ${key}`);
  }
  return v.trim();
}

function _getProviderConfig(provider) {
  const cfg = functions.config();

  if (provider === 'yandex') {
    const y = cfg.yandex || {};
    return {
      clientId: _requireString(y, 'client_id'),
      clientSecret: _requireString(y, 'client_secret'),
      authorizeUrl: 'https://oauth.yandex.ru/authorize',
      tokenUrl: 'https://oauth.yandex.ru/token',
      scope: 'login:email login:info',
    };
  }

  if (provider === 'mailru') {
    const m = cfg.mailru || {};
    return {
      clientId: _requireString(m, 'client_id'),
      clientSecret: _requireString(m, 'client_secret'),
      authorizeUrl: 'https://oauth.mail.ru/login',
      tokenUrl: 'https://oauth.mail.ru/token',
      scope: 'userinfo',
    };
  }

  throw new HttpsError('invalid-argument', 'Unknown provider');
}

function _safeUid(provider, providerUserId) {
  const raw = `${provider}:${providerUserId}`;
  return raw.replace(/[^a-zA-Z0-9:_-]/g, '_').slice(0, 128);
}

async function _exchangeCodeForToken({ tokenUrl, clientId, clientSecret, code, redirectUri }) {
  const body = new URLSearchParams({
    grant_type: 'authorization_code',
    client_id: clientId,
    client_secret: clientSecret,
    code,
    redirect_uri: redirectUri,
  });

  const resp = await fetch(tokenUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body,
  });

  const text = await resp.text();
  let json;
  try {
    json = JSON.parse(text);
  } catch {
    json = null;
  }

  if (!resp.ok || !json) {
    throw new HttpsError('internal', `Token exchange failed: ${resp.status} ${text}`);
  }

  const accessToken = json.access_token;
  if (!accessToken) {
    throw new HttpsError('internal', `No access_token in response: ${text}`);
  }

  return json;
}

async function _fetchUserInfo(provider, accessToken) {
  if (provider === 'yandex') {
    const url = `https://login.yandex.ru/info?format=json&oauth_token=${encodeURIComponent(accessToken)}`;
    const resp = await fetch(url, { method: 'GET' });
    const text = await resp.text();
    let json;
    try {
      json = JSON.parse(text);
    } catch {
      json = null;
    }
    if (!resp.ok || !json) {
      throw new HttpsError('internal', `Yandex userinfo failed: ${resp.status} ${text}`);
    }

    const id = json.id || json.client_id || json.uid;
    const email = json.default_email || json.email || null;
    const displayName = json.real_name || json.display_name || json.login || 'Yandex User';

    if (!id) {
      throw new HttpsError('internal', 'Yandex userinfo missing id');
    }

    return { providerUserId: id.toString(), email, displayName };
  }

  if (provider === 'mailru') {
    const url = `https://oauth.mail.ru/userinfo?access_token=${encodeURIComponent(accessToken)}`;
    const resp = await fetch(url, { method: 'GET' });
    const text = await resp.text();
    let json;
    try {
      json = JSON.parse(text);
    } catch {
      json = null;
    }
    if (!resp.ok || !json) {
      throw new HttpsError('internal', `Mail.ru userinfo failed: ${resp.status} ${text}`);
    }

    const id = json.id || json.uid || json.user_id;
    const email = json.email || null;
    const displayName = json.name || json.nickname || json.first_name || 'Mail.ru User';

    if (!id) {
      throw new HttpsError('internal', 'Mail.ru userinfo missing id');
    }

    return { providerUserId: id.toString(), email, displayName };
  }

  throw new HttpsError('invalid-argument', 'Unknown provider');
}

exports.oauthGetAuthUrl = onCall({ cors: true }, async (request) => {
  const provider = _requireString(request.data, 'provider');
  const redirectUri = _requireString(request.data, 'redirectUri');

  const cfg = _getProviderConfig(provider);

  const state = Math.random().toString(36).slice(2);
  const url = new URL(cfg.authorizeUrl);
  url.searchParams.set('response_type', 'code');
  url.searchParams.set('client_id', cfg.clientId);
  url.searchParams.set('redirect_uri', redirectUri);
  url.searchParams.set('scope', cfg.scope);
  url.searchParams.set('state', state);

  return { url: url.toString(), state };
});

exports.oauthCustomToken = onCall({ cors: true }, async (request) => {
  const provider = _requireString(request.data, 'provider');
  const code = _requireString(request.data, 'code');
  const redirectUri = _requireString(request.data, 'redirectUri');

  const cfg = _getProviderConfig(provider);

  const tokenJson = await _exchangeCodeForToken({
    tokenUrl: cfg.tokenUrl,
    clientId: cfg.clientId,
    clientSecret: cfg.clientSecret,
    code,
    redirectUri,
  });

  const accessToken = tokenJson.access_token;
  const userInfo = await _fetchUserInfo(provider, accessToken);

  const uid = _safeUid(provider, userInfo.providerUserId);

  try {
    await admin.auth().getUser(uid);
  } catch (e) {
    await admin.auth().createUser({
      uid,
      email: userInfo.email || undefined,
      displayName: userInfo.displayName || undefined,
    });
  }

  if (userInfo.email || userInfo.displayName) {
    await admin.auth().updateUser(uid, {
      email: userInfo.email || undefined,
      displayName: userInfo.displayName || undefined,
    });
  }

  const customToken = await admin.auth().createCustomToken(uid, {
    provider,
  });

  return { token: customToken };
});
