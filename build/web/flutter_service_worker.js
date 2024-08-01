'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "5a81d393efddda51f64fe880cf2b3118",
"index.html": "a3504199eb06b9abbeef430994041623",
"/": "a3504199eb06b9abbeef430994041623",
"main.dart.js": "4b126830245e069f84c0c3a09a0ad8c1",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/favicon-16x16.png": "83caa13a40cfc225e770b8b189561e84",
"icons/favicon.ico": "7237f3ac2628a006a380ec2a6ae43d39",
"icons/apple-icon.png": "2b67337771e2a9fb65dcbe6645a531d7",
"icons/apple-icon-144x144.png": "b4a411c2e86c5e18bc7ec16499f80aca",
"icons/android-icon-192x192.png": "d721997d764cfd5696f829ec2fe3df48",
"icons/apple-icon-precomposed.png": "2b67337771e2a9fb65dcbe6645a531d7",
"icons/apple-icon-114x114.png": "2ec9ce9b884be2ce8867cb741661b773",
"icons/ms-icon-310x310.png": "d6b94e92112e61c0f615142b21aa85a0",
"icons/ms-icon-144x144.png": "ff2b538f3ed650552aef01589a18be70",
"icons/apple-icon-57x57.png": "66a4db3746d2b6722df46d2ab3ffa23c",
"icons/apple-icon-152x152.png": "eeffcb15819d422b14e002a2eb4b1665",
"icons/ms-icon-150x150.png": "ac743a11c3294aea85710b8555da22d4",
"icons/android-icon-72x72.png": "745d4b93a5495be34c6ec40acc747e3f",
"icons/android-icon-96x96.png": "6a88f49fa2391466a18f102785207a94",
"icons/android-icon-36x36.png": "0d4417676e85ac3441cda43c643d54f6",
"icons/apple-icon-180x180.png": "8e8f9a7eb5b2ed902937ae0b4da8a812",
"icons/favicon-96x96.png": "72ae033f4e7ea97f96949dde0b17ce89",
"icons/manifest.json": "b58fcfa7628c9205cb11a1b2c3e8f99a",
"icons/android-icon-48x48.png": "c022855cfc4bbca4f278acdab7a349c3",
"icons/apple-icon-76x76.png": "ed6aaa052e8c9fa6009ac52635122a1c",
"icons/apple-icon-60x60.png": "dde154c2b95349088c63373ae19bd61c",
"icons/browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"icons/android-icon-144x144.png": "b4a411c2e86c5e18bc7ec16499f80aca",
"icons/apple-icon-72x72.png": "745d4b93a5495be34c6ec40acc747e3f",
"icons/apple-icon-120x120.png": "6a71ec49f041e6a4c7f67794c2b129d6",
"icons/favicon-32x32.png": "9e616d76188213b455660daa26250a01",
"icons/ms-icon-70x70.png": "883f7a6674cfa45e4fdc3d0b00d4a533",
"manifest.json": "0394cb6755dcd1ef3665adc736143586",
"assets/AssetManifest.json": "e0bfd8184a6f093510011f869053c86a",
"assets/NOTICES": "e986be290b5ca3d43096c7f1a8f8dcf2",
"assets/FontManifest.json": "8cfe0c43faebe49da37ecbbc2e486e46",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/AssetManifest.bin": "58b6ea1404df0b192bdbf99158318be9",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/assets/images/switch_button.png": "5602d5ce3f06fa6b653e46df93e94637",
"assets/assets/images/claw_zombie_spritesheet_2.png": "9d6d268ed19869770b6d57a972685463",
"assets/assets/images/ui/joystick_tutorial.png": "4c5c47d80575e16d14ffd8ffa6a6bde1",
"assets/assets/images/ui/keyboard_tutorial.png": "7211b410827471d027c989d6b1f7786e",
"assets/assets/images/ui/Title%2520Screen.png": "a8b18bd2f24a543c0a21dce10be56293",
"assets/assets/images/ui/Game%2520Over%2520Game%2520Complete%2520and%2520Pause%2520Board.png": "89f89b57b8d67c37af8b5e596777b193",
"assets/assets/images/ui/Instruction%2520Board.png": "491c7dd33f24537c81f5fc5f6991d1b4",
"assets/assets/images/ui/close_button.png": "73ae52f52c3e00d84011a59a41393e8a",
"assets/assets/images/ui/Button.png": "56f3f167f93d13e094acc9928e347a6a",
"assets/assets/images/ui/Arion%2520Title.png": "0e8a44622f43fda1b6f5d9c50f99cbed",
"assets/assets/images/tilemap.png": "1cb396476ae9102f064aacf17d957039",
"assets/assets/images/arrow_3.png": "0be9df87186be4a57394dcdc80f46870",
"assets/assets/images/zombie/Idle.png": "c0f759a3c31e92569de0d51b88ee0f75",
"assets/assets/images/zombie/Walk.png": "dafd230711df0ffa500b190908ab546a",
"assets/assets/images/zombie/Attack.png": "104da282bb8b8c05d0a35b24c56ff556",
"assets/assets/images/zombie/Death.png": "1afe4cb074ad25e5bc30623b7db4ffd4",
"assets/assets/images/rayworld_background.png": "0feabc21b5c894db582440cf4817e958",
"assets/assets/images/map.png": "208e8bce652883d75170c9edbb85c474",
"assets/assets/images/crossbow.png": "072ca58946a2025fb5c5a0e3285daa7d",
"assets/assets/images/sword_button.png": "d9301beb33b855c91aec1234b18aeb12",
"assets/assets/images/mistery_box.png": "344ba4c6ea778a8f4cd8c8e9042ef406",
"assets/assets/images/sword.png": "2917ad4381687ea6553c769d33e089b0",
"assets/assets/images/map/RPGW_Caves_v2.1/MainLev2.0.png": "7cfa9bdf9d765e78e3debc016ada5450",
"assets/assets/images/map/EPIC%2520RPG%2520World%2520Pack%2520-%2520Ancient%2520Ruins%2520V%25201.9.1/Props/Atlas-Props%25202.png": "dbd278130dbc19641c9b2ae0e94e39bf",
"assets/assets/images/map/EPIC%2520RPG%2520World%2520Pack%2520-%2520Ancient%2520Ruins%2520V%25201.9.1/Props/Atlas-Props.png": "4028a63cfde7f2d73b66a1409f75ba8c",
"assets/assets/images/map/EPIC%2520RPG%2520World%2520Pack%2520-%2520Ancient%2520Ruins%2520V%25201.9.1/Tilesets/water%2520to%2520grass1.png": "0b9ae317566bb4ab2e39c5f08635492b",
"assets/assets/images/map/EPIC%2520RPG%2520World%2520Pack%2520-%2520Ancient%2520Ruins%2520V%25201.9.1/Tilesets/grass-mid%2520tone-transp.png": "a082e4fb8b7b140165999c49b97ec523",
"assets/assets/images/map/EPIC%2520RPG%2520World%2520Pack%2520-%2520Ancient%2520Ruins%2520V%25201.9.1/Tilesets/Tileset-Terrain.png": "c47caebe52b039e6a3b3d0c679b10d5d",
"assets/assets/images/map/EPIC%2520RPG%2520World%2520Pack%2520-%2520Ancient%2520Ruins%2520V%25201.9.1/Tilesets/grass-light-transp.png": "d571c8f12e2e10a76dec362b97486358",
"assets/assets/images/map/EPIC%2520RPG%2520World%2520Pack%2520-%2520Ancient%2520Ruins%2520V%25201.9.1/Tilesets/Tileset-Terrain2.png": "67669d1707153ce73047e8c2ae318413",
"assets/assets/images/map/collectible/stone-active-large.png": "15f416750a998c232a4f721a4b369668",
"assets/assets/images/map/collectible/stone-active-small.png": "36686215de64f923f60d443da0a881f6",
"assets/assets/images/map/collectible/bridge.png": "2ac21d6f9cfdb6429ba0129a67099485",
"assets/assets/images/map/collectible/put.png": "cf3c9779f0f8a253cc9e7b22d4f34dee",
"assets/assets/images/map/collectible/pick.png": "bdb2111a24aba8383e8c14d00bc3e752",
"assets/assets/images/map/collectible/stone-pickable-small.png": "b0c8e5dfcf593d6e039a7265723e8015",
"assets/assets/images/map/collectible/stone-indicator-small.png": "ddf97b9881822e4c350042d44f48b1ec",
"assets/assets/images/map/collectible/stone-indicator-large.png": "57952b7eb7cc890ef84efaa63c3bfde7",
"assets/assets/images/map/collectible/stone-pickable-large.png": "de7ad0dbcbfae71ddbb5f75d717577ac",
"assets/assets/images/claw_zombie_spritesheet.png": "ab7e5f0521c9043e3b224de2d91065f3",
"assets/assets/images/sword_spritesheet.png": "23ac6d44ec329bf92f0ec635e7efd1a5",
"assets/assets/images/tilemap_secondary.png": "52327d49f2ed496f397b792c2dedfa37",
"assets/assets/images/tilemap_packed.png": "db783149e54e9ee8912a22887ae19e0e",
"assets/assets/images/player_spritesheet.png": "284ddc25658720ea0c2dcff889362e3d",
"assets/assets/images/pause_button.png": "1318fc9ad8965676ece81c29dafbe796",
"assets/assets/images/potion/rage_potion_button.png": "1967fc0a80744a40925da53ce1d73b5f",
"assets/assets/images/potion/health_potion.png": "52ff653c99b4cebf1cff4a1c1a79f3bb",
"assets/assets/images/potion/rage_potion.png": "a2170a21059946f0d155e2e717dafb05",
"assets/assets/images/potion/health_potion_button.png": "3c0182bb0990e6bc194604f68789c5e2",
"assets/assets/images/demon/Idle.png": "d55081d555b48e90ca9e25071c47473d",
"assets/assets/images/demon/Burst.png": "b7d464cd8267fee1a22a982bba47f8f0",
"assets/assets/images/demon/Poison.png": "15895e44ea2a17f30dbe2cd8615e524b",
"assets/assets/images/demon/Walk.png": "bb7391e3856e9b7590a5f05a2da60f55",
"assets/assets/images/demon/Attack.png": "c87f24224eab0f1545cabfb9262f1a87",
"assets/assets/images/demon/Death.png": "7b501a90d34b30126d42cac9f811b173",
"assets/assets/images/player.png": "907fdf65b07f51ac9835904f4b82b247",
"assets/assets/images/player/Bullet.png": "c3922617d4b48ab9b5de286f1f62d567",
"assets/assets/images/player/Idle.png": "931b1529ffe9bf31dcbb349f9fd5b01e",
"assets/assets/images/player/Crossbow.png": "cb99f586627266858271fb1637874fee",
"assets/assets/images/player/Arrow.png": "336777e8148d0d59c0186dc8a3739018",
"assets/assets/images/player/ArrowDiagonal.png": "2fcae92b34e4b8326ee0639f5f76efc2",
"assets/assets/images/player/Walk.png": "1cb00d17333dad8b518eadd02ff16247",
"assets/assets/images/player/Death.png": "cb38a0cdb1e9e092db37e18838901568",
"assets/assets/images/player/Shoot.png": "631dfd1d206188e474ba2df95601a85d",
"assets/assets/images/player/Stab.png": "efa249591368550c6845fdb19946a13c",
"assets/assets/tiles/mistery_box.tsx": "d26ba31955e24dd20ac5185286a91470",
"assets/assets/tiles/chapter_1.tmx": "96a526cbc131d9dcd747d18dbb31272e",
"assets/assets/tiles/era1-zone1.tmx": "45af87d54459ad7e8797c40d02138297",
"assets/assets/tiles/tilesets/grass-mid%2520tone-transp.tsx": "52418e1e98aa11f2ddc8bceda3fa1aad",
"assets/assets/tiles/tilesets/water%2520to%2520grass1.tsx": "24f7f0b8b162aecc2bca13d50e0c5cd6",
"assets/assets/tiles/tilesets/grass-light-transp.tsx": "0da4e59a309e3b3f534d06b30910d96a",
"assets/assets/tiles/tilesets/cave.tsx": "72efbc569bf41afbfde7d13a2697999e",
"assets/assets/tiles/tilesets/tileset-terrain2.tsx": "cbb265da05e8122f20b070dd2278ed4f",
"assets/assets/tiles/tilesets/atlas-props.tsx": "1755cafee892500574542607c51ee27a",
"assets/assets/tiles/tilesets/atlas-props2.tsx": "024dff010036669c566dcb7cc511f2a6",
"assets/assets/audio/crossbow.wav": "4711ef20a5cb9b18c37265d9b15528ad",
"assets/assets/audio/back-sound.wav": "5e2480d2f08b9d60e0bc515f638b9455",
"assets/assets/audio/zombie_attack.wav": "cf59c6e7b4111ab514b2fcdec321fca1",
"assets/assets/audio/button.mp3": "55aa47879b4d3a222f8be7a52c41252f",
"assets/assets/audio/running-text.mp3": "0cdd1a411acc13e2093b575cd8e197be",
"assets/assets/audio/player-walk.wav": "354c46ee74aea82117e9bf32359c230f",
"assets/assets/audio/sword.wav": "c8c4dc83eda00e3d771ac14b715b2967",
"assets/assets/fonts/pixelify_medium.ttf": "2081a0b1dd9a57d373839da37ef2bedd",
"assets/assets/fonts/pixelify_bold.ttf": "efc12ef1e774941865527ec2c0a3636c",
"assets/assets/fonts/pixelify_regular.ttf": "d6b4fe0a9425d5e9b459d654109498b4",
"assets/assets/fonts/pixelify_semibold.ttf": "43dddc46855022399125a476c93a69cd",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "d1fde2560be92c0b07ad9cf9acb10d05",
"canvaskit/chromium/canvaskit.js": "ffb2bb6484d5689d91f393b60664d530",
"canvaskit/chromium/canvaskit.wasm": "393ec8fb05d94036734f8104fa550a67",
"canvaskit/canvaskit.js": "5caccb235fad20e9b72ea6da5a0094e6",
"canvaskit/canvaskit.wasm": "d9f69e0f428f695dc3d66b3a83a4aa8e",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
