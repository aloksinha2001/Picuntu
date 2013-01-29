package net.g8.picuntu.activities;

import net.g8.picuntu.R;
import net.g8.picuntu.config.KernelConfig;
import net.g8.picuntu.config.RootfsConfig;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.RadioButton;

/**
 * Activity to collect kernel installation information.
 * @author linuxerwang@gmail.com
 */
public class KernelActivity extends BaseActivity {

  private KernelConfig kernelConfig;
  private RadioButton radioToRecovery;
  private RadioButton radioToKernel;
  private RadioButton radioIgnore;


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState, R.layout.activity_kernel);

    radioToRecovery = (RadioButton) findViewById(R.id.radioRecoveryPartition);
    radioToRecovery.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        nextButton.setEnabled(true);
      }
    });

    radioToKernel = (RadioButton) findViewById(R.id.radioKernelPartition);
    radioToKernel.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        nextButton.setEnabled(true);
      }
    });

    radioIgnore = (RadioButton) findViewById(R.id.radioIgnore);
    radioIgnore.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        nextButton.setEnabled(true);
      }
    });

    kernelConfig = installConfig.getInstallSchema().getKernelConfig();
    if (kernelConfig != null) {
      if (kernelConfig.getDestination() == KernelConfig.Destination.RECOVERY) {
        radioToRecovery.setChecked(true);
        nextButton.setEnabled(true);
      } else if (kernelConfig.getDestination() == KernelConfig.Destination.KERNEL) {
        radioToKernel.setChecked(true);
        nextButton.setEnabled(true);
      } else if (kernelConfig.getDestination() == KernelConfig.Destination.IGNORE) {
        radioIgnore.setChecked(true);
        nextButton.setEnabled(true);
      } else {
        nextButton.setEnabled(false);
      }
    }
  }


  @Override
  protected Class<? extends Activity> getNextActivity() {
    if (kernelConfig == null) {
      kernelConfig = new KernelConfig();
      installConfig.getInstallSchema().setKernelConfig(kernelConfig);
    }

    if (radioToRecovery.isChecked()) {
      // If linux kernel was installed to recovery NAND partition, the rootfs can not be installed
      // to internal SD because otherwise Android might not boot correctly while we rely on Android
      // before booting to Picuntu.
      kernelConfig.setDestination(KernelConfig.Destination.RECOVERY);
      if (installConfig.getInstallSchema().getRootfsConfig() == null) {
        installConfig.getInstallSchema().setRootfsConfig(new RootfsConfig());
      }
      installConfig.getInstallSchema().getRootfsConfig().setDestination(
          RootfsConfig.Destination.EXTERNAL_SD);
      // And then we should jump to overview activity.
      return OverviewActivity.class;
    } else if (radioToKernel.isChecked()) {
      kernelConfig.setDestination(KernelConfig.Destination.KERNEL);
      return RootfsActivity.class;
    } else if (radioIgnore.isChecked()) {
      kernelConfig.setDestination(KernelConfig.Destination.IGNORE);
      return RootfsActivity.class;
    }

    // Won't happen. Exactly one choice need to be selected before going to next step.
    return null;
  }
}
