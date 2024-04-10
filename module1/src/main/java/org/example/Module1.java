package org.example;

import java.util.Comparator;
import java.util.List;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import javax.annotation.Nullable;

public class Module1 {

  public static void main2(String[] args) {
    List<String> list = Stream.of("b", "c", "a")
      .collect(Collectors.toList());
    list.sort(Comparator.comparing(Function.identity()));
    System.out.println(list);
  }

  public static void main(String[] args) {
    List<String> list = Stream.of("b", "c", "a")
      .toList();
    list.sort(Comparator.comparing(Function.identity()));
    System.out.println(list);
  }

  @Nullable
  @Deprecated(since = "1.0")
  public static String get() {
    return "Hello World!";
  }
}
