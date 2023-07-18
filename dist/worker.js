console.log("gvm worker");
let t0 = Date.now();

window = self;

self.importScripts("VM.min.js");

function rungvm() {
  console.log("rungvm");

  self.confirm = () => true;

  self.window = self;           // ???

  const dev = _os_device_from_basic_console()

  dev.use_async_input = () => true;

  // receiving output from gvm
  dev.output_add_buffer = (buffer) => {
    let len = dev.wbuf.length,
        newbuf = new Uint8Array(len + buffer.length);
    newbuf.set(dev.wbuf);
    newbuf.set(buffer, len);
    dev.wbuf = newbuf;

    let output = dev.decoder.decode(dev.wbuf);
    dev.wbuf = new Uint8Array(0);

    if (output.startsWith("Gambit"))
      console.log("dt", Date.now()-t0);
    else
      console.log(";;", output);
    //if (mainwindow) mainwindow.postMessage(output);
  };

  // sending input to gvm
  self.onmessage = (e) => {
    let input = e.data
    if (!input.length) return
    let condvar_scm = dev.read_condvar_scm;
    dev.rbuf = dev.encoder.encode(input);
    dev.rlo = 0;
    dev.read_condvar_scm = null;
    _os_condvar_ready_set(condvar_scm, true);
  }

  _program_start();
  
}

rungvm();

