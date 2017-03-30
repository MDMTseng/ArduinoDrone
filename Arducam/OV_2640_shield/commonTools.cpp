
#include "commonTools.h"
#include <stdio.h>
#include "Arduino.h"
#include <stdarg.h>
void printfx(const char *format, ...)
{
  char buf[200];
  va_list ap;
  va_start(ap, format);
  vsnprintf(buf, sizeof(buf), format, ap);
  Serial.print(buf);
  va_end(ap);
}
