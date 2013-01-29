package net.g8.picuntu.config;

/**
 * Installation schema for local LAN based installation.
 * @author linuxerwang@gmail.com
 */
public class LanSchema extends BaseInstallSchema {
  private String url = "";

  public LanSchema() {}


  public String getUrl() {
    return url;
  }


  public void setUrl(String url) {
    if (url.endsWith("/")) {
      this.url = url.substring(0, url.length() - 1);
    } else {
      this.url = url;
    }
  }


  @Override
  public String getPrefix() {
    return url;
  }
}
