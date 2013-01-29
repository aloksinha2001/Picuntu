package net.g8.picuntu.activities;

import net.g8.picuntu.R;
import net.g8.picuntu.config.KernelConfig;
import net.g8.picuntu.config.LanSchema;
import net.g8.picuntu.config.RootfsConfig;
import net.g8.picuntu.config.SdSchema;
import net.g8.picuntu.config.WanSchema;
import android.app.Activity;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.widget.TextView;

/**
 * Activity to show installation overview before real installation.
 * @author linuxerwang@gmail.com
 */
public class OverviewActivity extends BaseActivity {

  private static final String NOTHING_TO_DO = "Nothing to do.";
  private static final String INSTALL_FROM_SD = "You selected to install from your external " +
  		"SD card.\n\n";
  private static final String INSTALL_FROM_LAN = "You selected to install from your local " +
      "network \"%s\".\n\n";
  private static final String INSTALL_FROM_WAN = "You selected to install from Picuntu download " +
  		"website \"%s\".\n\n";
  private static final String INSTALL_TO_RECOVERY = "Picuntu linux kernel will be installed to " +
  		"the recovery NAND partition of your TV Box, so that you can still boot to Android. " +
  		"To boot to Picuntu linux, the system will first boot to Android and automatically run a " +
  		"script to reboot to Picuntu.\n\n";
  private static final String INSTALL_TO_KERNEL = "Picuntu linux kernel will be installed to " +
  		"the kernel NAND partition of your TV Box. The system will boot directly to Picuntu linux " +
  		"and you will not be able to boot to Adroid!!!\n\n";
  private static final String INSTALL_TO_INTERNAL_SD = "Picuntu linux rootfs will be installed " +
      "to the internal SD card.\n\n";
  private static final String INSTALL_TO_EXTERNAL_SD = "Picuntu linux rootfs will be installed " +
      "to the external SD card.\n\n";
  private static final String WARNING = "Click \"Next\" button to start install Picuntu " +
  		"linux. Once the installation starts you can not stop it!!! There are changes that the " +
  		"installation fails. If so, please following the directions on the Picuntu linux website" +
  		" to recover.";

  private TextView overviewView;


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState, R.layout.activity_overview);

    overviewView = (TextView) findViewById(R.id.installOverview);
    overviewView.setMovementMethod(new ScrollingMovementMethod());

    StringBuilder overview = new StringBuilder();

    KernelConfig kernelConfig = installConfig.getInstallSchema().getKernelConfig();
    RootfsConfig rootfsConfig = installConfig.getInstallSchema().getRootfsConfig();

    if (kernelConfig.getDestination() == KernelConfig.Destination.IGNORE &&
        rootfsConfig.getDestination() == RootfsConfig.Destination.IGNORE) {
      // Both ignored, nothing to do.
      overview.append(NOTHING_TO_DO);
      nextButton.setEnabled(false);
    } else {
      nextButton.setEnabled(true);

      if (installConfig.getInstallSchema() instanceof SdSchema) {
        overview.append(INSTALL_FROM_SD);
      } else if (installConfig.getInstallSchema() instanceof LanSchema) {
        LanSchema schema = (LanSchema) installConfig.getInstallSchema();
        overview.append(String.format(INSTALL_FROM_LAN, schema.getUrl()));
      } else if (installConfig.getInstallSchema() instanceof WanSchema) {
        WanSchema schema = (WanSchema) installConfig.getInstallSchema();
        overview.append(String.format(INSTALL_FROM_WAN, schema.getUrl()));
      }

      if (kernelConfig.getDestination() == KernelConfig.Destination.RECOVERY) {
        overview.append(String.format(INSTALL_TO_RECOVERY));
      } else if (kernelConfig.getDestination() == KernelConfig.Destination.KERNEL) {
        overview.append(String.format(INSTALL_TO_KERNEL));
      }

      if (rootfsConfig.getDestination() == RootfsConfig.Destination.INTERNAL_SD) {
        overview.append(String.format(INSTALL_TO_INTERNAL_SD));
      } else if (rootfsConfig.getDestination() == RootfsConfig.Destination.EXTERNAL_SD) {
        overview.append(String.format(INSTALL_TO_EXTERNAL_SD));
      }

      overview.append(WARNING);
    }

    overviewView.setText(overview);
  }


  @Override
  protected Class<? extends Activity> getNextActivity() {
    return InstallNowActivity.class;
  }
}
