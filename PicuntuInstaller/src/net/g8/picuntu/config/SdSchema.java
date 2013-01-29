package net.g8.picuntu.config;

/**
 * Installation schema for external SD card based installation.
 * @author linuxerwang@gmail.com
 */
public class SdSchema extends BaseInstallSchema {
  private String device = "/mnt/ext_sdcard";


  public SdSchema() {}


  public String getDevice() {
    return device;
  }


  public void setDevice(String device) {
    this.device = device;
  }


  @Override
  public String getPrefix() {
    return device;
  }
}
