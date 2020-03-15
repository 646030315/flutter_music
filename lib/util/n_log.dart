const loggable = true;

const LOG_LEVER_CLR = 1;

nLog(Object o, {int level}) {
  if (loggable) {
    print(o);
  }
}
