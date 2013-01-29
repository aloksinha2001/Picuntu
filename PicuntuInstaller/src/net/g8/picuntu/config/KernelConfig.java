package net.g8.picuntu.config;

/**
 * Kernel installation config.
 * @author linuxerwang@gmail.com
 */
public class KernelConfig {
  public static enum Destination {
    // Install to recovery partition.
    RECOVERY,
    // Install to kernel partition.
    KERNEL,
    // Ignore Kernel installation
    IGNORE
  }


  private Destination destination;


  public Destination getDestination() {
    return destination;
  }


  public void setDestination(Destination destination) {
    this.destination = destination;
  }
}
