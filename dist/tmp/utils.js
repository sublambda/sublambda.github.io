'use strict';

import * as THREE from 'three';
import { FBXLoader } from "./jsm/loaders/FBXLoader.js";
import { GLTFLoader } from "./jsm/loaders/GLTFLoader.js";
import { DRACOLoader } from "./jsm/loaders/DRACOLoader.js";
import { RGBELoader } from "./jsm/loaders/RGBELoader.js";
import { Tween, Easing, update,  removeAll } from 'es6-tween';
//import * as TWEEN from "@tweenjs/tween.js";
//import gsap from "gsap";

//window.TWEEN = TWEEN;
//window.gsap = gsap;
window.Easing = Easing;

let fmt = (x) => x.toLocaleString();

export function* map(iterable, fn) {
  let i = 0;
  for (let item of iterable)
    yield fn(item, i++);
}

export function* filter(iterable, pred) {
  let i = 0;
  for (let item of iterable)
    if (pred(item, i++))
      yield item;
}

export default function tween(x,nostart) {
  let t = new Tween(x).easing(Easing.Cubic.InOut);
  if (!nostart)
    t.start();
  return t;
}

export function linear(x,nostart) {
  let t = new Tween(x).easing(Easing.Linear);
  if (!nostart) {
    t.start();
  }
  return t;
}

export function tweenupdate() {
  try {
    //TWEEN.update();
    update();
  } catch (e) {
    console.warn("tween update lossage",e);
    removeAll();
  }
}
window.tween = tween;
window.tweenupdate = tweenupdate;

export function tweenrunning() {
  return TWEEN.isRunning();
}

export function chain(t1, t2) {
  return t1.chain(t2);
}



export function elt(sel) {
  return document.querySelector(sel);
}

export function vec3(x,y,z) {
  return new THREE.Vector3(x,y,z);
}
window.vec3 = vec3;

export function quat(x,y,z,w) {
  return new THREE.Quaternion(x,y,z,w);
}

export function pos(obj) {
  return obj.position;
}


function burstylimiter(fn, burstsize, burstdelay) {
  burstsize = burstsize || 10;
  burstdelay = burstdelay || 50;

  let active = false,
      worklist = [];
  const run = function() {
    if (worklist.length && !active) {
      active = true;
      for (let i=0; i < burstsize && worklist.length; i++)
        worklist.shift().call();
      setTimeout(function() {
        active = false;
        run();
      }, burstdelay);
    }
  };
  return function() {
    worklist.push(fn.bind(this, ...arguments));
    run();
  };
}

function _syncfn(obj, interval, force) {
  if (obj.modelsync)
    obj.modelsync(force);      // in qcell, sync viewobj back to model
}

// these values are magic and probably dependent on update size
let syncfn = burstylimiter(_syncfn,20,50);



// croquet specific: V -> M
function orig_syncfn(obj, interval, force) {
  if (!obj.modelsync)
    return (obj) => obj;

  let t0 = Date.now();
  interval = interval || 51;
  return function() {
    let t = Date.now();
    if (t - t0 > interval) { // (partially effective, per object) throttle
      obj.modelsync(force);  // in qcell, sync viewobj back to model
      t0 = t;
    }
  }
}

export function slide(obj,x,y,z,d, nostart) {
  return tween(obj.position, nostart).to({x: x, y: y, z: z}, d)
    .on("update", syncfn(obj));
}

window.slide = slide;

export function grow(obj,s,d) {
  return tween(obj.scale).to({x:s, y:s, z:s}, d || 1000)
    .on("update", syncfn(obj));
}
window.grow = grow;

export function ygrow(obj,sy,d) {
  let sx = obj.scale.x, sz = obj.scale.z;
  return tween(obj.scale).to({x: sx, y: sy, z: sz}, d);
}

export function toquat(obj,x,y,z,w,d) {
  return tween(obj.quaternion).to({x: x, y: y, z: z, w: w}, d || 1000)
    .on("update", syncfn(obj));
}
window.toquat = toquat;

export function rot(obj,x,y,z,d) {
  return tween(obj.rotation).to({x: x, y: y, z: z}, d || 1000)
    .on("update", syncfn(obj));
}
window.rot = rot;


/*
let tweenrotateonaxis = function() {
    // axis is assumed to be normalized
    // angle is in radians
  let q0 = new THREE.Quaternion(),
      tmp = new THREE.Object3D();
  return function tweenrotateonaxis(obj, axis, angle, dt, onupdate) {
    let qend, t0 = { t : 0 };
    q0.copy(obj.quaternion);
    tmp.quaternion.copy(q0);
    tmp.rotateOnAxis(axis, angle);
    qend = tmp.quaternion;
    return tween(t0)
      .to({t : 1}, dt)
      .easing(Easing.Linear.None)
      .on("update", function() {
        obj.quaternion.slerpQuaternions(q0, qend, t0.t);
        if (onupdate)
          onupdate();
      });
  }
}();
*/

function tweenrotateonaxis(obj, axis, angle, dt, onupdate) {
  // axis is assumed to be normalized
  // angle is in radians
  let q0 = new THREE.Quaternion(),
      tmp = new THREE.Object3D();
  let qend, t0 = { t : 0 };
  q0.copy(obj.quaternion);
  tmp.quaternion.copy(q0);
  tmp.rotateOnAxis(axis, angle);
  qend = tmp.quaternion;
  return tween(t0)
    .to({t : 1}, dt)
    .easing(Easing.Linear.None)
    .on("update", function() {
      obj.quaternion.slerpQuaternions(q0, qend, t0.t);
      if (onupdate)
        onupdate();
    });
}

export function roty(obj, angle, dt) {
  return tweenrotateonaxis(obj, vec3(0,1,0), angle, dt, syncfn(obj))
}
export function badroty(obj,s,d) {
  return tween(obj.rotation).to({y: s}, d || 1000)
    .on("update", syncfn(obj)); //,20,true));
}
export function rroty(obj,ry,d) {
  let r = obj.rotation;
  return rot(obj,r.x,ry,r.z,d);
}
window.roty = roty;

export function log(x,y) {
  var args = [""].concat(Array.prototype.slice.call(arguments,0));
  console.log.apply(console,arguments);
}

export function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}


function curtime() {
  return Date.now();
}
function unixtime() {
  return curtime() / 1000;
}

export function ldmodule(url, callback) {
  var s = document.createElement("script");
  s.type = "module";
  if (s.readyState) {           // ie
    s.onreadystatechange = function() {
      log("ldmodule ready", s);
      if (s.readyState == "loaded" || s.readyState == "complete") {
        s.onreadystatechange = null;
        if (callback) callback(s);
      }

    };
  } else {
    if (callback)
      s.onload = function(){callback(s);};
  }
  s.src = url;
  document.getElementsByTagName("head")[0].appendChild(s);
}

export function ld(url, callback) {
  var s = document.createElement("script");
  s.type = "application/javascript";
  if (s.readyState) {           // ie
    s.onreadystatechange = function() {
      log("ldready", s);
      if (s.readyState == "loaded" || s.readyState == "complete") {
        s.onreadystatechange = null;
        if (callback) callback(s);
      }

    };
  } else {
    if (callback)
      s.onload = function(){callback(s);};
  }
  s.src = url;
  document.getElementsByTagName("head")[0].appendChild(s);
}
window.ld = ld;

export function lookto(p, dz, dy, dt) {
  dz = dz || .8;
  dy = dy == undefined ? 0.1 : dy;
  dt = dt || 1000;
  let app = lim;
  let ctrl = app.orbitcontrols,
      cam = app.camera;

  if (p.position) {          // instanceof THREE.Object3D may not work
    let pos = p.position.clone();
    //p.localToWorld(pos);
    p = pos;
  }

  tween(ctrl.target).to({ x : p.x, y : p.y, z : p.z}, dt/2)
    .on("update", function() { 
      ctrl.update();
    });
  return tween(cam.position).delay(10+dt/2).to({ x : p.x, y : p.y+dy, z : p.z+dz}, dt)
    .on("update", function() { 
      ctrl.update();
    });
}
export function lookto0(obj, dz, dy, dt) {
  let bb = new THREE.Box3().setFromObject(obj),
      h = bb.max.y - bb.min.y,
      pos = vec3(0,h/2,0).add(obj.position);
  return lookto(pos, h * 1.1, h/4);
}
window.lookto = lookto; 

export function camto(x,y,z,tx,ty,tz) {
  let app = window.app,
      ctrl = app.orbitcontrols,
      cam = app.camera,
      dt = 1000;
  if (tx||ty||tz) {
    tween(ctrl.target).to({ x : tx, y : ty, z : tz}, dt)
      .on("update", () => ctrl.update());
  }
  return tween(cam.position).to({ x : x, y : y, z : z}, dt)
    .on("update", () => ctrl.update());
}
window.camto = camto;

export function pp(x) {
  return JSON.stringify(x);
}

export function togglefullscreen(e, el) {
  el = el || (e.path ? e.path[0] : e.srcElement);
  if (!document.fullscreenElement) {
    if (el.requestFullscreen)
      el.requestFullscreen();
    else if (el.webkitRequestFullscreen)
      el.webkitRequestFullscreen();
  } else {
    if (document.exitFullscreen)
      document.exitFullscreen(); 
    if (el.exitFullscreen)
      el.exitFullscreen(); 
  }
}
window.togglefullscreen = togglefullscreen;

export function togglefullscreen0(e) {
  if (!document.fullscreenElement) {
    if (document.documentElement.requestFullscreen)
      document.documentElement.requestFullscreen();
    else if (document.documentElement.webkitRequestFullscreen)
      document.documentElement.webkitRequestFullscreen();
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen(); 
    }
  }
}

function repeat(n,fn) {
  for (let i=0; i<n; i++)
    fn(i);
}

function trepeat(n,fn,delay) {
  delay = delay || 0;
  let i=0;
  function rep() {
    fn(i++);
    if (i < n)
      setTimeout(rep,delay)
  }
  rep();
}

function time(fn) {
  let t = Date.now();
  fn();
  return Date.now() - t;
}

function wrap(fn, msg) {
  return function() {
    try {
      fn();
    } catch(e) {
      log("wrap", msg, e);
    }
  };
}

export function xhr(url, mime, callback) {
  let req = new XMLHttpRequest;
  //req.withCredentials = true;
  if (mime && req.overrideMimeType)
    req.overrideMimeType(mime);
  req.open("GET", url, true);
  if (callback)
    req.onreadystatechange = function(x) {
      if (req.readyState == 4)
        callback(req);
    };
  req.send(null);
  return req;
}
export function xhrpost(url, data, callback) {
  let req = new XMLHttpRequest;
  req.open("POST", url, true);
  req.setRequestHeader("Content-type", "application/json");
  if (callback)
    req.onreadystatechange = function() {
      if (req.readyState === 4)
        callback(req);
    };
  req.send(data);
  return req;
}

let draco;
export function gltfdraco(file, path, callback) {
  let loader = new GLTFLoader();
  if (!draco) {
    draco = new DRACOLoader();
    draco.setDecoderPath("./draco/");
  }
  loader.setDRACOLoader(draco);
  loader.setPath(path ? path : "./stuff/");
  loader.load(file, function (gltf) {
    if (callback)
      callback(gltf);
  });
}

export function sgltf(name, path, callback) {
  let obj = new THREE.Object3D();
  path = path || "./stuff/";

  gltf(name, path, data => {
    let root = data.scene;
    if (data.animations.length) {
      let mixer = new THREE.AnimationMixer(root);
      data.animations.forEach(anim => mixer.clipAction(anim).play());
    }
    obj.add(root);
    
    root.traverse((n) => {
      n.receiveShadow = false;
      n.castShadow = true;
      n.frustumCulled = false;
      if (n.material) {
        console.warn(n.material);
        n.material.transparent = true;
        //n.material.clearcoat = true;
      }
    });
    if (callback)
      callback(obj);
  });
  return obj;
}


export var gltf = gltfdraco;
window.gltf = gltf;
window.sgltf = sgltf;

export function gltf0(file, path, callback) {
  let loader = new GLTFLoader();
  loader.setPath(path ? path : "./");
  loader.load( file, function (gltf) {
      if (callback)
        callback(gltf);
    });
}

export function fbx(file, callback) {
  let loader = new FBXLoader();
  loader.load(file, data => callback && callback(data));
}

export function timingloop(fn, nloop) {
  let t = Date.now(),
      n = nloop || 1000;
  while (--n)
    fn();
  return Date.now() - t;
}

export function getdatauri(image, scale) {
  let w = image.width, 
      h = image.height;
  if (scale) {
    w *= scale;
    h *= scale;
  }
  let canvas = document.createElement('canvas');
  canvas.width = w;
  canvas.height = h;
  canvas.getContext('2d').drawImage(image, 0, 0, w, h);
  canvas.toDataURL('image/png').replace(/^data:image\/(png|jpg);base64,/, '');
  return canvas.toDataURL('image/png');
}


function gethdrmap() {
  hdrmap = new RGBELoader()
	.setPath( "https://rx.0x.no:8401" +
              "/stuff/textures/equirectangular/" )
	.load( 'royal_esplanade_1k.hdr', function (data) {
      log("HDRMAP", data);
      window.hdrmap = data;
	  window.hdrmap.mapping = THREE.EquirectangularReflectionMapping;
    });
}
//gethdrmap();

export function putimg(img, scale) {
  let ts = Date.now(),
      json = { timestamp: ts, data: img };
  xhrpost("https://"  + localconfig.server + ":" + localconfig.port + "/putimg",
          JSON.stringify(json),
          e=>console.log("putimg",e));
  return ts;
}

export function postimg(img, timestamp) {
  timestamp = timestamp || Date.now();
  let imgdata = { "data" : img,
                  "timestamp" : timestamp };
  xhrpost("https://" + localconfig.server + ":" + localconfig.port + "/rdb/putimg",
          JSON.stringify(imgdata));
  return imgdata;
}

export function objload(file, path, callback) {
  new OBJLoader().setPath(path ? path : "./stuff/")
    .load( file, function (scene) {
      if (callback)
        callback(scene);
    });
}

export function runcamstatus(app, interval) {
  setInterval(() => camstatus(app), interval || 200);
}

export var campos = vec3(-1,-1,-1);
var origin = vec3(0,0,0);

export function camstatus(app) {
  let pos = app.camera.position,
      d = pos.distanceTo(campos),
      d2 = pos.distanceTo(origin);
  if (d < .000001)
    return;
  campos = pos.clone();
  let s = pos.toArray().map(n => n.toFixed(3));
  s.push(d2.toFixed(2));
  app.setstatus(s + "<br>tracking: " + app.trackingstate);
}  

function gumvideo(callback) {
  let v = document.getElementById("vid");
  v.onloadedmetadata = function(e) {
    log("onloadedmetadata");
    v.play();
  };
  let constraints = { video: true, width: 640, height: 480 };
  navigator.mediaDevices.getUserMedia(constraints)
    .then(function success(stream) {
      v.srcObject = stream; 
      if (callback)
        callback(stream);
    });
}

export function videotexture(url) {
  let vid = document.createElement("video"),
      vt = new THREE.VideoTexture(vid);
  vid.style.visible = "hidden";   // wtf
  vid.src = url;
  vid.muted = true;
  vid.autoplay = false;
  vid.playsinline = false;
  vid.webkitPlaysinline = false;
  vid.crossOrigin = "anonymous";
  vt.vid = vid;
  return vt;
}

export function vidbox(url) {
  let tex = new videotexture(url),
      vid = tex.vid,
      box = new THREE.Mesh(
        new THREE.BoxGeometry(1, .8, 1), 
        new THREE.MeshPhysicalMaterial({color: 0xffffff,
                                        map: tex,
                                        transparent: true,
                                        side: THREE.DoubleSide }));
  box.tag = "vidbox";
  box.vid = vid;
  vid.onloadeddata = () => {
    vid.pause();
    vid.currentTime = 0;
    vid.playsinline = true;
    vid.loop = true;
    vid.fullscreen = false;
  };
  box.castShadow = true;
  box.receiveShadow = false;
  return box;
}
window.vidbox = vidbox;

export function wireframe(obj, val) {
  if (val === undefined) val = true;
  obj.traverse(n=>n.material && (n.material.wireframe=val))
}
window.wireframe = wireframe;

export function bindbutton(id, fn) {
  document.getElementById(id).addEventListener("click", fn);
}

export function exports(name, module) {
  Object.keys(module.exports).forEach((x) => {
    window[x] = module.exports[x];
  });
}

export function mk(x) {
  return new x();
}

function getOffset(el) {
  let x = 0, y = 0;
  while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {
    x += el.offsetLeft - el.scrollLeft;
    y += el.offsetTop - el.scrollTop;
    el = el.offsetParent;
  }
  return { top: y, left: x };
}

export function throttle(fn, limit) {
  let lastfn, last;
  return function() {
    const context = this;
    const args = arguments;
    if (!last) {
      fn.apply(context, args)
      last = Date.now();
    } else {
      clearTimeout(lastfn);
      lastfn = setTimeout(function() {
        if ((Date.now() - last) >= limit) {
          fn.apply(context, args);
          last = Date.now();
        }
      }, limit - (Date.now() - last));
    }
  }
}

//function newclass(parent, methodname) {
//  return class extends parent { [methodname]() {console.log('burp');} }
//}
//window.newclass = newclass;


export async function loadjs(f) {
  return await import("./"+f);
}
window.loadjs = loadjs;

function easeInOutQuad (t, b, c, d) {
  if ((t /= d / 2) < 1) return c / 2 * t * t + b;
  return -c / 2 * ((--t) * (t - 2) - 1) + b;
}
window.easeInOutQuad = easeInOutQuad;

function easeInOutCubic (t, b, c, d) {
    if ((t /= d / 2) < 1) return c / 2 * t * t * t + b;
    return c / 2 * ((t -= 2) * t * t + 2) + b;
}
window.easeInOutCubic = easeInOutCubic;


function sandboxframe() {
  let div = document.createElement("iframe");
  div.sandbox ="allow-scripts allow-same-origin";
  div.src = "sandbox.html";
  div.style.visible = false;
  document.body.append(div);

  div.send = (input) => div.contentWindow.postMessage(input);

  return div;
}
window.sandboxframe = sandboxframe;


function blobworker(code) {
  let blob = new Blob([code], {type: 'application/javascript'}),
      worker = new Worker(URL.createObjectURL(blob));
  worker.onmessage = (e) => console.log("worker.onmessage", e.data);
  return worker;
}

window.blobworker = blobworker;
