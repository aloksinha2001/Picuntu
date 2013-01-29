package net.g8.picuntu.activities;

import net.g8.picuntu.InstallerApplication;
import net.g8.picuntu.R;
import net.g8.picuntu.config.InstallConfig;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

/**
 * Base activity for activities with prev/next buttons.
 * @author linuxerwang@gmail.com
 */
public abstract class BaseActivity extends Activity {

  protected InstallConfig installConfig;
  protected Button prevButton;
  protected Button nextButton;

  protected void onCreate(Bundle savedInstanceState, int layoutResID) {
    super.onCreate(savedInstanceState);

    setContentView(layoutResID);

    InstallerApplication app = (InstallerApplication) getApplication();
    installConfig = app.getInstallConfig();

    prevButton = (Button) findViewById(R.id.prevButton);
    if (prevButton != null) {
      prevButton.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View view) {
          getNextActivity();
          finish();
        }
      });
    }

    nextButton = (Button) findViewById(R.id.nextButton);
    if (nextButton != null) {
      nextButton.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View view) {
          final Class<? extends Activity> nextActivity = getNextActivity();
          if (nextActivity != null) {
            startActivity(new Intent(getApplicationContext(), nextActivity));
          }
        }
      });
    }
  }


  protected Class<? extends Activity> getNextActivity() {
    return null;
  }
}
