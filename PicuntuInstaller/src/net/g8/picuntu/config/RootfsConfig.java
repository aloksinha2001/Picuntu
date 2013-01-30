package net.g8.picuntu.config;

/**
 * Rootfs installation config.
 * @author linuxerwang@gmail.com
 */
public class RootfsConfig {
  public static enum Destination {
    // Install to internal SD card.
    INTERNAL_SD,
    // Install to external SD card or any other places.
    EXTERNAL_SD,
    // Ignore rootfs installation
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
