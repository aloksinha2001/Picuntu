package net.g8.picuntu.activities;

import net.g8.picuntu.R;
import net.g8.picuntu.config.RootfsConfig;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.RadioButton;

/**
 * Activity to collect rootfs installation information.
 * @author linuxerwang@gmail.com
 */
public class RootfsActivity extends BaseActivity {

  private RootfsConfig rootfsConfig;
  private RadioButton radioToInternalSd;
  private RadioButton radioToExternalSd;
  private RadioButton radioIgnore;


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState, R.layout.activity_rootfs);

    radioToInternalSd = (RadioButton) findViewById(R.id.radioToInternalSd);
    radioToInternalSd.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        nextButton.setEnabled(true);
      }
    });

    radioToExternalSd = (RadioButton) findViewById(R.id.radioToExternalSd);
    radioToExternalSd.setOnClickListener(new View.OnClickListener() {
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

    rootfsConfig = installConfig.getInstallSchema().getRootfsConfig();
    if (rootfsConfig != null) {
      if (rootfsConfig.getDestination() == RootfsConfig.Destination.INTERNAL_SD) {
        radioToInternalSd.setChecked(true);
        nextButton.setEnabled(true);
      } else if (rootfsConfig.getDestination() == RootfsConfig.Destination.EXTERNAL_SD) {
        radioToExternalSd.setChecked(true);
        nextButton.setEnabled(true);
      } else if (rootfsConfig.getDestination() == RootfsConfig.Destination.IGNORE) {
        radioIgnore.setChecked(true);
        nextButton.setEnabled(true);
      } else {
        nextButton.setEnabled(false);
      }
    }
  }


  @Override
  protected Class<? extends Activity> getNextActivity() {
    if (rootfsConfig == null) {
      rootfsConfig = new RootfsConfig();
      installConfig.getInstallSchema().setRootfsConfig(rootfsConfig);
    }

    if (radioToInternalSd.isChecked()) {
      rootfsConfig.setDestination(RootfsConfig.Destination.INTERNAL_SD);
    } else if (radioToExternalSd.isChecked()) {
      rootfsConfig.setDestination(RootfsConfig.Destination.EXTERNAL_SD);
    } else if (radioIgnore.isChecked()) {
      rootfsConfig.setDestination(RootfsConfig.Destination.IGNORE);
    }

    return OverviewActivity.class;
  }
}
