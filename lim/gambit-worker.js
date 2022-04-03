self.confirm = () => true;

self.window = self;

self.importScripts("VM.min.js");

const dev = _os_device_from_basic_console()

dev.use_async_input = () => true;

dev.output_add_buffer = (buffer) => {
  const len = dev.wbuf.length;
  const newbuf = new Uint8Array(len + buffer.length);
  newbuf.set(dev.wbuf);
  newbuf.set(buffer, len);
  dev.wbuf = newbuf;

  const output = dev.decoder.decode(dev.wbuf);
  dev.wbuf = new Uint8Array(0);

  self.postMessage(output)
};

self.onmessage = (e) => {
  const input = e.data

  if (!input.length) return

  const condvar_scm = dev.read_condvar_scm;
  dev.rbuf = dev.encoder.encode(input);
  dev.rlo = 0;
  dev.read_condvar_scm = null;
  _os_condvar_ready_set(condvar_scm, true);
}

_program_start();

