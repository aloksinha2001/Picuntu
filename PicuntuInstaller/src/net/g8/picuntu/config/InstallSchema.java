package net.g8.picuntu.config;
/**
 * Interface for general installation schema.
 * @author linuxerwang@gmail.com
 */
public interface InstallSchema {
  KernelConfig getKernelConfig();
  RootfsConfig getRootfsConfig();
  void setKernelConfig(KernelConfig kernelConfig);
  void setRootfsConfig(RootfsConfig rootfsConfig);
  String getPrefix();
}
