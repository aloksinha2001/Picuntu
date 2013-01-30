package net.g8.picuntu.activities;

import net.g8.picuntu.R;
import net.g8.picuntu.config.InstallSchema;
import net.g8.picuntu.config.LanSchema;
import net.g8.picuntu.config.SdSchema;
import net.g8.picuntu.config.WanSchema;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.RadioButton;

/**
 * Activity to let user select installation source.
 * @author linuxerwang@gmail.com
 */
public class SourceActivity extends BaseActivity {

  private Class<? extends Activity> nextActivity = KernelActivity.class;
  private RadioButton radioFromSdCard;
  private RadioButton radioFromLan;
  private RadioButton radioFromWan;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState, R.layout.activity_source);

		radioFromSdCard = (RadioButton) findViewById(R.id.radioFromSdCard);
		radioFromSdCard.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        nextButton.setEnabled(true);
        nextActivity = KernelActivity.class;
      }
    });

    radioFromLan = (RadioButton) findViewById(R.id.radioFromLan);
    radioFromLan.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        nextButton.setEnabled(true);
        nextActivity = LanActivity.class;
      }
    });

    radioFromWan = (RadioButton) findViewById(R.id.radioFromWan);
    radioFromWan.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        nextButton.setEnabled(true);
        nextActivity = WanActivity.class;
      }
    });

    // Initialize radio buttons according to the saved install schema.
    nextButton.setEnabled(true);
    InstallSchema installSchema = installConfig.getInstallSchema();
		if (installSchema instanceof SdSchema) {
		  radioFromSdCard.setChecked(true);
      nextActivity = KernelActivity.class;
		} else if (installSchema instanceof LanSchema) {
		  radioFromLan.setChecked(true);
      nextActivity = LanActivity.class;
    } else if (installSchema instanceof WanSchema) {
      radioFromWan.setChecked(true);
      nextActivity = WanActivity.class;
		} else {
		  nextButton.setEnabled(false);
		}
	}


  @Override
  protected Class<? extends Activity> getNextActivity() {
    // Create a new schema if it's the first time or the select schema was changed.

    Class<? extends InstallSchema> selectedSchema = null;
    if (radioFromSdCard.isChecked()) {
      selectedSchema = SdSchema.class;
    } else if (radioFromLan.isChecked()) {
      selectedSchema = LanSchema.class;
    } else if (radioFromWan.isChecked()) {
      selectedSchema = WanSchema.class;
    }

    if (installConfig.getInstallSchema() == null ||
        installConfig.getInstallSchema().getClass() != selectedSchema) {
      try {
        installConfig.setInstallSchema(selectedSchema.newInstance());
      } catch (InstantiationException ignored) {
        ignored.printStackTrace();
      } catch (IllegalAccessException ignored) {
        ignored.printStackTrace();
      }
    }

    return nextActivity;
  }
}
