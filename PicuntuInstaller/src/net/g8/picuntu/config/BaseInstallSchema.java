package net.g8.picuntu.config;

/**
 * Base class for general installation schema.
 * @author linuxerwang@gmail.com
 */
public abstract class BaseInstallSchema implements InstallSchema {
  private KernelConfig kernelConfig;
  private RootfsConfig rootfsConfig;


  public BaseInstallSchema() {}


  @Override
  public KernelConfig getKernelConfig() {
    return kernelConfig;
  }


  @Override
  public void setKernelConfig(KernelConfig kernelConfig) {
    this.kernelConfig = kernelConfig;
  }


  @Override
  public RootfsConfig getRootfsConfig() {
    return rootfsConfig;
  }


  @Override
  public void setRootfsConfig(RootfsConfig rootfsConfig) {
    this.rootfsConfig = rootfsConfig;
  }
}
