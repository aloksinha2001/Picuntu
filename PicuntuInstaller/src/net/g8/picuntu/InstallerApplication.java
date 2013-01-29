package net.g8.picuntu;

import net.g8.picuntu.config.InstallConfig;
import android.app.Application;

/**
 * Android application class for Picuntu Installer.
 * @author linuxerwang@gmail.com
 */
public class InstallerApplication extends Application {

  private InstallConfig installConfig = new InstallConfig();

  public InstallConfig getInstallConfig() {
    return installConfig;
  }
}
