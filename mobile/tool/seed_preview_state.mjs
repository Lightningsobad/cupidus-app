#!/usr/bin/env node
// Seeds a paired dev couple with just enough state for the 37 design-fidelity
// preview screens to render meaningfully. Runs over the existing public HTTP
// API only (never Postgres directly, never a new backend endpoint) per
// coding-plan/master-plan.md §4.3 DEC-3.
//
// Usage: node mobile/tool/seed_preview_state.mjs
// Env overrides: CUPID_API_BASE_URL, PREVIEW_FIREBASE_API_KEY,
//   PREVIEW_EMAIL_A/PREVIEW_PASSWORD_A, PREVIEW_EMAIL_B/PREVIEW_PASSWORD_B

const BASE_URL = process.env.CUPID_API_BASE_URL || 'http://127.0.0.1:3005';
// Same GCP project as mobile/lib/firebase_options.dart (android.apiKey); the
// Identity Toolkit REST endpoint is not platform-restricted for this project.
const FIREBASE_API_KEY =
  process.env.PREVIEW_FIREBASE_API_KEY || 'AIzaSyBExAvVfUek8eZA80xj6i-Wx4u--FrSHU4';
const IDENTITY_TOOLKIT_URL = 'https://identitytoolkit.googleapis.com/v1/accounts';

const ACCOUNT_A = {
  label: 'A',
  email: process.env.PREVIEW_EMAIL_A || 'preview.dev.a@cupid.test',
  password: process.env.PREVIEW_PASSWORD_A || 'CupidPreview!Dev1',
};
const ACCOUNT_B = {
  label: 'B',
  email: process.env.PREVIEW_EMAIL_B || 'preview.dev.b@cupid.test',
  password: process.env.PREVIEW_PASSWORD_B || 'CupidPreview!Dev2',
};

function section(title) {
  console.log(`\n=== ${title} ===`);
}

async function checkBackendReachable() {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 5000);
  try {
    await fetch(BASE_URL, { signal: controller.signal });
  } catch (e) {
    throw new Error(
      `Backend not reachable at ${BASE_URL}. Start it before seeding. (${e.message})`,
    );
  } finally {
    clearTimeout(timeout);
  }
}

async function identityToolkit(action, payload) {
  const res = await fetch(`${IDENTITY_TOOLKIT_URL}:${action}?key=${FIREBASE_API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  const data = await res.json();
  if (!res.ok) {
    const err = new Error(data?.error?.message || `identitytoolkit ${action} failed`);
    err.code = data?.error?.message;
    err.status = res.status;
    throw err;
  }
  return data;
}

async function signInOrCreate({ email, password }) {
  try {
    const data = await identityToolkit('signInWithPassword', {
      email,
      password,
      returnSecureToken: true,
    });
    return { idToken: data.idToken, firebaseCreated: false };
  } catch (e) {
    // Identity Toolkit returns INVALID_LOGIN_CREDENTIALS for both a
    // non-existent email and a wrong password (account-enumeration
    // hardening), so EMAIL_NOT_FOUND is no longer reliably distinct. Try
    // sign-up; if the account turns out to already exist, the seed
    // password is genuinely wrong for it, which is a real blocker.
    if (e.code !== 'EMAIL_NOT_FOUND' && e.code !== 'INVALID_LOGIN_CREDENTIALS') throw e;
    try {
      const data = await identityToolkit('signUp', {
        email,
        password,
        returnSecureToken: true,
      });
      return { idToken: data.idToken, firebaseCreated: true };
    } catch (signUpErr) {
      if (signUpErr.code === 'EMAIL_EXISTS') {
        throw new Error(
          `Account ${email} already exists in Firebase but the seed password doesn't match it. ` +
            'Set PREVIEW_EMAIL_A/PREVIEW_PASSWORD_A (or _B) to the correct credentials.',
        );
      }
      throw signUpErr;
    }
  }
}

async function api(method, path, token, body) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let data;
  try {
    data = text ? JSON.parse(text) : undefined;
  } catch {
    data = text;
  }
  if (!res.ok) {
    const err = new Error(
      `${method} ${path} -> ${res.status}: ${typeof data === 'string' ? data : JSON.stringify(data)}`,
    );
    err.status = res.status;
    err.body = data;
    throw err;
  }
  return data;
}

async function ensureBackendUser(token) {
  try {
    return await api('POST', '/auth/login', token);
  } catch (e) {
    if (e.status !== 404) throw e;
    return await api('POST', '/auth/register', token);
  }
}

async function ensurePaired(a, b) {
  let userA = await api('GET', '/users/me', a.token);
  let userB = await api('GET', '/users/me', b.token);
  if (userA.partnerId === userB.id && userB.partnerId === userA.id) {
    return { userA, userB, paired: false };
  }
  const invite = await api('POST', '/invitations/generate', a.token);
  try {
    await api('POST', '/invitations/accept', b.token, { code: invite.code });
  } catch (e) {
    if (e.status !== 409) throw e;
  }
  userA = await api('GET', '/users/me', a.token);
  userB = await api('GET', '/users/me', b.token);
  return { userA, userB, paired: true };
}

async function seedGallery(a) {
  const desired = [
    { filename: 'preview-seed-photo-1.jpg', mimeType: 'image/jpeg' },
    { filename: 'preview-seed-photo-2.jpg', mimeType: 'image/jpeg' },
    { filename: 'preview-seed-photo-3.jpg', mimeType: 'image/jpeg' },
  ];
  const existing = await api('GET', '/gallery', a.token);
  const existingNames = new Set(existing.map((i) => i.filename));
  const created = [];
  for (const item of desired) {
    if (!existingNames.has(item.filename)) {
      created.push(await api('POST', '/gallery', a.token, item));
    }
  }
  const final = await api('GET', '/gallery', a.token);
  return { created, final };
}

async function seedTimeline(a) {
  const desired = [
    {
      title: 'Preview Seed: First Date',
      description: 'Seeded memory for design-fidelity preview capture.',
      icon: '💕',
    },
    {
      title: 'Preview Seed: Weekend Trip',
      description: 'Seeded memory for design-fidelity preview capture.',
      icon: '✈️',
    },
  ];
  const existing = await api('GET', '/timeline', a.token);
  const existingTitles = new Set(existing.map((i) => i.title));
  const created = [];
  for (const item of desired) {
    if (!existingTitles.has(item.title)) {
      created.push(await api('POST', '/timeline', a.token, item));
    }
  }
  const final = await api('GET', '/timeline', a.token);
  return { created, final };
}

async function seedDreamJar(a) {
  const jarName = 'Preview Seed: Trip to Paris';
  const existingJars = await api('GET', '/dream-jar', a.token);
  let jar = existingJars.find((j) => j.name === jarName);
  let jarCreated = false;
  if (!jar) {
    jar = await api('POST', '/dream-jar', a.token, {
      name: jarName,
      targetAmount: 5000000,
      currency: 'VND',
    });
    jarCreated = true;
  }

  const desiredContributions = [
    { amount: 300000, note: 'Preview seed contribution 1' },
    { amount: 200000, note: 'Preview seed contribution 2' },
  ];
  const existingContributions = await api('GET', `/dream-jar/${jar.id}/contributions`, a.token);
  const existingNotes = new Set(existingContributions.map((c) => c.note));
  const createdContributions = [];
  for (const contribution of desiredContributions) {
    if (!existingNotes.has(contribution.note)) {
      createdContributions.push(
        await api('POST', `/dream-jar/${jar.id}/contributions`, a.token, contribution),
      );
    }
  }

  const finalJar = await api('GET', `/dream-jar/${jar.id}`, a.token);
  const finalContributions = await api('GET', `/dream-jar/${jar.id}/contributions`, a.token);
  return { jar: finalJar, jarCreated, createdContributions, finalContributions };
}

async function seedExpenses(a) {
  const today = new Date().toISOString().slice(0, 10);
  const desired = [
    { category: 'food', amount: 250000, description: 'Preview Seed: Dinner', date: today },
    { category: 'date', amount: 500000, description: 'Preview Seed: Movie night', date: today },
  ];
  const existing = await api('GET', '/expenses', a.token);
  const existingDescriptions = new Set(existing.map((e) => e.description));
  const created = [];
  for (const item of desired) {
    if (!existingDescriptions.has(item.description)) {
      created.push(await api('POST', '/expenses', a.token, item));
    }
  }
  const final = await api('GET', '/expenses', a.token);
  return { created, final };
}

async function seedMessages(a, b, userAId, userBId) {
  const desired = [
    { from: 'A', content: 'Preview seed message 1: hey love, seeded for design QA' },
    { from: 'B', content: 'Preview seed message 2: got it! looks great' },
    { from: 'A', content: "Preview seed message 3: can't wait to see the new screens" },
    { from: 'B', content: 'Preview seed message 4: same here 💕' },
  ];
  const existing = await api('GET', `/messages?partnerId=${userBId}`, a.token);
  const existingContents = new Set(existing.map((m) => m.content));
  const created = [];
  for (const item of desired) {
    if (!existingContents.has(item.content)) {
      const sender = item.from === 'A' ? a : b;
      const receiverId = item.from === 'A' ? userBId : userAId;
      created.push(
        await api('POST', '/messages', sender.token, {
          receiverId,
          content: item.content,
          type: 'text',
        }),
      );
    }
  }
  const final = await api('GET', `/messages?partnerId=${userBId}`, a.token);
  return { created, final };
}

async function seedAlarm(a) {
  const time = new Date(Date.now() + 24 * 60 * 60 * 1000);
  time.setHours(7, 0, 0, 0);
  const alarm = await api('POST', '/alarms', a.token, { time: time.toISOString() });
  return alarm;
}

async function seedVibe(a) {
  const today = await api('GET', '/vibes/today', a.token);
  if (today) {
    return { vibe: today, created: false };
  }
  const created = await api('POST', '/vibes', a.token, {
    mood: 'happy',
    note: 'Preview seed vibe',
  });
  return { vibe: created, created: true };
}

async function main() {
  section('Backend reachability');
  await checkBackendReachable();
  console.log(`Backend reachable at ${BASE_URL}`);

  section('Firebase auth');
  const authA = await signInOrCreate(ACCOUNT_A);
  const authB = await signInOrCreate(ACCOUNT_B);
  console.log(
    `Account A (${ACCOUNT_A.email}): ${authA.firebaseCreated ? 'created' : 'signed in'}`,
  );
  console.log(
    `Account B (${ACCOUNT_B.email}): ${authB.firebaseCreated ? 'created' : 'signed in'}`,
  );

  const a = { token: authA.idToken };
  const b = { token: authB.idToken };

  section('Backend user records');
  const dbUserA = await ensureBackendUser(a.token);
  const dbUserB = await ensureBackendUser(b.token);
  console.log(`User A: id=${dbUserA.id} email=${dbUserA.email}`);
  console.log(`User B: id=${dbUserB.id} email=${dbUserB.email}`);

  section('pairing');
  const pairing = await ensurePaired(a, b);
  console.log(
    pairing.paired
      ? `Paired A(${pairing.userA.id}) <-> B(${pairing.userB.id})`
      : `Already paired A(${pairing.userA.id}) <-> B(${pairing.userB.id})`,
  );

  section('gallery');
  const gallery = await seedGallery(a);
  console.log(
    `Created ${gallery.created.length} new item(s): ${gallery.created.map((i) => i.filename).join(', ') || 'none'}`,
  );
  console.log(`Gallery now has ${gallery.final.length} item(s) for User A.`);

  section('timeline');
  const timeline = await seedTimeline(a);
  console.log(
    `Created ${timeline.created.length} new event(s): ${timeline.created.map((i) => i.title).join(', ') || 'none'}`,
  );
  console.log(`Timeline now has ${timeline.final.length} event(s) for the couple.`);

  section('jar');
  const jar = await seedDreamJar(a);
  console.log(
    `Dream Jar "${jar.jar.name}" (${jar.jar.id}) ${jar.jarCreated ? 'created' : 'already existed'} — ` +
      `${jar.jar.currentAmount}/${jar.jar.targetAmount} ${jar.jar.currency}`,
  );
  console.log(
    `Created ${jar.createdContributions.length} new contribution(s); ${jar.finalContributions.length} total.`,
  );

  section('expense');
  const expenses = await seedExpenses(a);
  console.log(
    `Created ${expenses.created.length} new expense(s): ${expenses.created.map((e) => e.description).join(', ') || 'none'}`,
  );
  console.log(`Expenses now has ${expenses.final.length} entrie(s) for the couple.`);

  section('message');
  const messages = await seedMessages(a, b, dbUserA.id, dbUserB.id);
  console.log(`Created ${messages.created.length} new message(s).`);
  console.log(`Conversation now has ${messages.final.length} message(s).`);

  section('alarm');
  const alarm = await seedAlarm(a);
  console.log(`Alarm ${alarm.id} set to ${alarm.time} (status: ${alarm.status}).`);

  section('vibe');
  const vibe = await seedVibe(a);
  console.log(
    vibe.created
      ? `Created today's vibe: ${vibe.vibe.mood} — "${vibe.vibe.note}"`
      : `Today's vibe already existed: ${vibe.vibe.mood}`,
  );

  section('done');
  console.log('Seeding complete.');
}

main().catch((err) => {
  console.error(`\nSeeding failed: ${err.message}`);
  process.exit(1);
});
