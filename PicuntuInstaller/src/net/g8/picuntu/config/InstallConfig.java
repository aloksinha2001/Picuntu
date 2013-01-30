package net.g8.picuntu.config;

/**
 * Installation config.
 * @author linuxerwang@gmail.com
 */
public class InstallConfig {
  private InstallSchema installSchema;


  public InstallConfig() {}


  public InstallSchema getInstallSchema() {
    return installSchema;
  }


  public void setInstallSchema(InstallSchema installSchema) {
    this.installSchema = installSchema;
  }
}
