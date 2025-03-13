public class Main {
  public static void main(String[] args) {
    String javaVersion = System.getProperty("java.version");
    String jbrVersion = System.getProperty("java.runtime.version");
    String osArch = System.getProperty("os.arch", "");
    String osName = System.getProperty("os.name", "");
    String vmVendor = System.getProperty("java.vendor", "unknown");
    String vmVersion = System.getProperty("java.vm.name", "unknown");
    if (jbrVersion != null) {
      System.out.println("JVM: " + vmVendor + " " + vmVersion + " " + jbrVersion);
      System.out.println(" OS: " + osName + " (" + osArch + ")");
    } else {
      System.out.println("JVM: " + vmVendor + " " + vmVersion + " " + javaVersion);
      System.out.println(" OS: " + osName + " (" + osArch + ")");
    }
    if (args.length > 0) {
      System.out.println("Args:");
      for (String arg : args) {
        System.out.println(arg);
      }
    } else {
      System.out.println("Emptry args");
    }
  }
}