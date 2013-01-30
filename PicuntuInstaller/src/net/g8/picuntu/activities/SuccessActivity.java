package net.g8.picuntu.activities;

import net.g8.picuntu.R;
import android.app.Activity;
import android.os.Bundle;

/**
 * Activity to show success and congratulations after installation.
 * @author linuxerwang@gmail.com
 */
public class SuccessActivity extends BaseActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState, R.layout.activity_success);
  }


  @Override
  protected Class<? extends Activity> getNextActivity() {
    return null;
  }

}
