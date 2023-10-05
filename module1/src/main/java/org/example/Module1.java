package org.example;

import javax.annotation.Nullable;

public class Module1 {
  @Nullable
  @Deprecated(since = "1.0")
  public static String get() {
    return "Hello World!";
  }
}
