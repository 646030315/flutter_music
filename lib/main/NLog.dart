const loggable = true;

const LOG_LEVER_CLR = 1;

log(int level, Object o) {
  if (loggable) {
    print(o);
  }
}
